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


#ifdef MEEGO_EDITION_HARMATTAN
#include <MDeclarativeCache>
#endif

Q_DECLARE_METATYPE(QModelIndex)
Core::Core(QDeclarativeView *parent) :
    QObject(parent)
  , m_declarativeView(parent)
{
    qmlRegisterUncreatableType<Core>("Core", 0, 1, "Core", QString("You cant create Core!"));
    m_declarativeView->setResizeMode(QDeclarativeView::SizeRootObjectToView);

    m_fileSystemModel = new QFileSystemModel(this);
    m_fileSystemModel->setRootPath("/");
    m_declarativeView->rootContext()->setContextProperty("fileSystemModel", m_fileSystemModel);
    m_declarativeView->rootContext()->setContextProperty("coreObject", this);
    m_declarativeView->setSource(QUrl("qrc:/qml/view.qml"));

    connect(m_declarativeView->engine(), SIGNAL(warnings(QList<QDeclarativeError>)),
            this, SLOT(declarativeErrors(QList<QDeclarativeError>)));

//    QDeclarativeItem *fileViewObj =
//    m_declarativeView->rootObject()->findChild<QDeclarativeItem*>("fileViewObj");

    m_declarativeView->resize(854,480);

    openPath(QDesktopServices::storageLocation(QDesktopServices::HomeLocation));
}

Core::~Core()
{

}

void Core::showHelp()
{

}

void Core::showAbout()
{

    QFile txt(":/about.txt");
    txt.open(QFile::ReadOnly);
    QString about(txt.readAll());
    about.replace("%CUTEVERSION%", "1.2");
    about.replace("%QTVERSION%", QT_VERSION_STR);
    QMessageBox msg(QMessageBox::Information, tr("About CuteExplorer"), about, QMessageBox::Ok);
    msg.exec();
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
        QObject *locationText =
                m_declarativeView->rootObject()->findChild<QObject*>("locationText");
        locationText->setProperty("text", filePath);
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

//    qDebug() << "Selection:";
//    foreach (const QModelIndex &index, m_selection)
//        qDebug() << index.data();
}

bool Core::fileIsSelected(const QModelIndex &index)
{
    return m_selection.contains(index);
}

void Core::clearSelection()
{
    m_selection.clear();
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

QIcon Core::iconFromTheme(const QString &iconName)
{
    return QIcon::fromTheme(iconName, QIcon(":/icons/icon-m-startup-back.png"));
}




