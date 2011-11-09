#include "core.h"
#include <QMessageBox>
#include <QDeclarativeContext>
#include <QDeclarativeEngine>
#include <QDeclarativeItem>
#include <QFileSystemModel>
#include <QDesktopServices>
#include <QDeclarativeView>
#include <QDebug>
#include <QApplication>
#include <QTimer>
#include <QAction>

#ifdef MEEGO_EDITION_HARMATTAN
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#endif

Q_DECLARE_METATYPE(QModelIndex)

Core::Core(QDeclarativeView *parent) :
    QObject(parent)
  , m_declarativeView(parent)
  , m_currentAction(NoAction)
{
    qmlRegisterUncreatableType<Core>("Core", 0, 1, "Core", QString("You cant create Core!"));
    m_declarativeView->setResizeMode(QDeclarativeView::SizeRootObjectToView);
    m_declarativeView->setAttribute(Qt::WA_AutoOrientation);

    m_fileSystemModel = new QFileSystemModel(this);
    m_fileSystemModel->setRootPath("/");
    m_declarativeView->rootContext()->setContextProperty("fileSystemModel", m_fileSystemModel);
    m_declarativeView->rootContext()->setContextProperty("coreObject", this);
    m_declarativeView->setSource(QUrl("qrc:/Ui.qml"));

    connect(m_declarativeView->engine(), SIGNAL(warnings(QList<QDeclarativeError>)),
            this, SLOT(declarativeErrors(QList<QDeclarativeError>)));

    openPath(QDesktopServices::storageLocation(QDesktopServices::HomeLocation));

    QAction *actionQuit = new QAction(this);
    connect(actionQuit, SIGNAL(triggered()), m_declarativeView, SLOT(close()));
    actionQuit->setShortcut(QKeySequence::Quit);
    m_declarativeView->addAction(actionQuit);
}

Core::~Core()
{

}

void Core::showHelp()
{

}

void Core::showAbout()
{

}

void Core::openFile(const QModelIndex &index)
{
    QFileInfo file = m_fileSystemModel->fileInfo(index);
    const QString filePath = m_fileSystemModel->filePath(index);
    if (filePath == "")
        return;
    if (file.isDir()) {
        //        qDebug() << "Opening path" << filePath;
        m_fileSystemModel->setRootPath(filePath);
        QObject *viewModel =
                m_declarativeView->rootObject()->findChild<QObject*>("viewModel");
        viewModel->setProperty("rootIndex", qVariantFromValue<QModelIndex>(index));
        emit currentPathChanged(filePath);
        clearSelection();
    } else {
        //        qDebug() << "QDesktopServices::openUrl(" << QUrl::fromLocalFile(filePath) << ")";
        QDesktopServices::openUrl(QUrl::fromLocalFile(filePath));
    }
}

void Core::openPath(const QString &path)
{
    QFileInfo file(path);
    if (!file.exists() && !file.isDir())
        return;
    openFile(m_fileSystemModel->index(path));
}

void Core::declarativeErrors(const QList<QDeclarativeError> &errors)
{
    foreach (QDeclarativeError err, errors) {
        qDebug() << err.toString();
    }
}

void Core::fileSelected(const QModelIndex &index, bool selected)
{
    if (selected && !m_selection.contains(index))
        m_selection.append(index);
    else if (!selected)
        m_selection.removeAll(index);

    emit filesSelectedChanged(!m_selection.isEmpty());
}

bool Core::fileIsSelected(const QModelIndex &index)
{
    return m_selection.contains(index);
}

void Core::clearSelection()
{
    m_selection.clear();
    emit filesSelectedChanged(false);
}

int Core::stateChange(QDeclarativeItem *item)
{
    const QDeclarativeItem *openArea =
            m_declarativeView->rootObject()->findChild<QDeclarativeItem*>("openArea");
    const QDeclarativeItem *selectionArea =
            m_declarativeView->rootObject()->findChild<QDeclarativeItem*>("selectionArea");
    if (item->collidesWithItem(openArea))
        return 1;
    if (item->collidesWithItem(selectionArea))
        return 2;

    return 0;
}

void Core::invokeAction(Core::Action a)
{
    switch (a) {
    case Cut: return actionCut();
    case Copy: return actionCopy();
    case Paste: return actionPaste();
    case Delete: m_itemsForAction = m_selection; return actionDelete();
    case Share: return actionShare();
    default: qDebug() << "Invalid action" << a;
    }
}

void Core::actionCut()
{
    m_currentAction = Cut;
    m_itemsForAction = m_selection;
    emit filesInClipboardChanged(true);
    qDebug() << "cut";
}

void Core::actionCopy()
{
    m_currentAction = Copy;
    m_itemsForAction = m_selection;
    emit filesInClipboardChanged(true);
    qDebug() << "copy";
}

void Core::actionPaste()
{
    if (m_currentAction != Cut
            && m_currentAction != Copy)
        return;
    qDebug() << "paste";
    clearSelection();
    QStringList failed;
    QModelIndexList actionItems = m_itemsForAction;
    m_itemsForAction.clear();
    if (m_currentAction == Cut) {
        foreach (const QModelIndex &index, actionItems) {
            if (!index.isValid())
                continue;
            QFileInfo file = m_fileSystemModel->fileInfo(index);
            QString newFileName =
                    m_fileSystemModel->rootPath().append(QLatin1Char('/')).append(file.fileName());
            if (!QFile::copy(file.absoluteFilePath(),
                             newFileName)) {
                failed.append(file.absoluteFilePath());
            } else {
                m_itemsForAction.append(index);
                fileSelected(m_fileSystemModel->index(newFileName));
            }
        }
        m_currentAction = NoAction;
        actionDelete();
    } else {
        foreach (const QModelIndex &index, actionItems) {
            if (!index.isValid())
                continue;
            QFileInfo file = m_fileSystemModel->fileInfo(index);
            QString newFileName =
                    m_fileSystemModel->rootPath().append(QLatin1Char('/')).append(file.fileName());
            if (!QFile::copy(file.absoluteFilePath(),
                             newFileName))
                failed.append(file.absoluteFilePath());
            else
                fileSelected(m_fileSystemModel->index(newFileName));
        }
        m_currentAction = NoAction;
    }
    emit filesInClipboardChanged(false);
    if (!failed.isEmpty()) {
        qDebug() << "Paste failed for:";
        qDebug() << failed;
    }
}

void Core::actionDelete()
{
    qDebug() << "delete";
    QStringList failed;
    foreach (const QModelIndex &index, m_itemsForAction) {
        if(!index.isValid())
            continue;

        bool success = false;
        if (m_fileSystemModel->isDir(index))
            success = m_fileSystemModel->rmdir(index);
        else
            success = m_fileSystemModel->remove(index);

        if (!success)
            failed.append(m_fileSystemModel->filePath(index));
        else
            m_selection.removeAll(index);
    }
    m_itemsForAction.clear();

    if (!failed.isEmpty()) {
        qDebug() << "Delete failed for:";
        qDebug() << failed;
    }
}

void Core::actionShare()
{
    qDebug() << "share";
    QStringList filesToShare;
    foreach (const QModelIndex &index, m_selection) {
        if (index.isValid())
            filesToShare.append(m_fileSystemModel->fileInfo(index).canonicalFilePath().prepend("file://"));
    }

#ifdef MEEGO_EDITION_HARMATTAN
    // does not work for all files???...
    ShareUiInterface shareIf("com.nokia.ShareUi");
    shareIf.share(filesToShare);
#else
    qWarning() << "No support for current platform";
#endif
}

bool Core::showHidden() const
{
    return m_fileSystemModel->filter() & QDir::Hidden;
}

void Core::setShowHidden(bool show)
{
    m_fileSystemModel->setFilter(show ?
                                     m_fileSystemModel->filter() | QDir::Hidden
                                   : m_fileSystemModel->filter() &~QDir::Hidden);
    emit showHiddenChanged(show);
}

QString Core::currentPath() const
{
    return m_fileSystemModel->rootPath();
}




