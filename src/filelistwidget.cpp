#include "filelistwidget.h"
#include <QHeaderView>
#include <QMessageBox>
#include <QInputDialog>
#include <QDesktopServices>
#include <QUrl>
#include <QProcess>
#include <QDBusInterface>
#ifdef Q_WS_MAEMO_5
#   include <hildon-mime.h>
#   include <dbus/dbus.h>
#endif
/*!
Widget that shows filesystemmodel and handles navigation
in directory tree and opening files with assosiated programs

@todo in symbian and windows filesystems navigating to "/" wont show drives
  */
FileListWidget::FileListWidget(QWidget *parent) :
    QListView(parent),
    fileSystemModel( new QFileSystemModel(this)),
    currentDir(QDir::homePath()),
    mode_cut(false),
    mode_copy(false),
    select(false)
{
    this->setModel(fileSystemModel);
    this->setRootIndex(fileSystemModel->index(currentDir.absolutePath()));
    fileSystemModel->setRootPath(currentDir.absolutePath());
    fileSystemModel->setFilter(fileSystemModel->filter() | QDir::System);
    connect(this, SIGNAL(activated(QModelIndex)), this, SLOT(handleItemActivation(QModelIndex)));

}

/**
  Switches view mode
  @param iconmode true shows iconview, false shows listview
  */
void FileListWidget::actionSwitchMode(bool iconmode)
{
    if(iconmode) {
        this->setViewMode(QListView::IconMode);
        this->setWordWrap(true);
        this->setGridSize(QSize(80,80));
    } else {
        this->setViewMode(QListView::ListMode);
        this->setWordWrap(false);
        this->setGridSize(QSize());
    }
}
/**
  Switches show hidden
  @param show true shows hidden files
  */
void FileListWidget::actionShowHidden(bool show)
{
    if(show)
        fileSystemModel->setFilter(fileSystemModel->filter() | QDir::Hidden);
    else
        fileSystemModel->setFilter(fileSystemModel->filter() &~ QDir::Hidden);

    this->clearSelection();
}

/**
  Rename selected file
  */
void FileListWidget::actionRename()
{
    QFileInfo file = fileSystemModel->fileInfo(this->selectedIndexes().first());
    QString newName = QInputDialog::getText(this, tr("Rename"), tr("New filename: "), QLineEdit::Normal, file.fileName());
    if(newName != file.fileName())
    {
        if(QFile::rename(file.absoluteFilePath(), file.absolutePath()+"/"+newName))
            return;
        else
            QMessageBox::critical(this,tr("Error!")
                                  ,tr("Renaming file %1 failed")
                                    .arg(file.fileName())
                                  ,QMessageBox::Ok);
    }
}
/**
  Selected files will be moved when actionPaste is called
  */
void FileListWidget::actionCut()
{
    mode_cut = true;
    mode_copy = false;
    selectedFiles = this->selectedIndexes();
}
/**
  Selected files will be copied when actionPaste is called
  */
void FileListWidget::actionCopy()
{
    mode_cut = false;
    mode_copy = true;
    selectedFiles = this->selectedIndexes();
}

/**
  Moves or copies files that were selected when actionCut or actionCopy called
  */
void FileListWidget::actionPaste()
{
    fileSystemModel->setReadOnly(false);
    if(mode_copy) {
        //Copy files until filelist is empty or error occured
        while(!selectedFiles.isEmpty()) {
            if(QFile::copy(fileSystemModel->fileInfo(selectedFiles.first()).absoluteFilePath()
                        , fileSystemModel->rootPath()+"/"+fileSystemModel->fileName(selectedFiles.first()))) {
                selectedFiles.removeFirst();
            }
            else if(QFile::copy(fileSystemModel->fileInfo(selectedFiles.first()).absoluteFilePath()
                    , fileSystemModel->rootPath()+"/copy_"+fileSystemModel->fileName(selectedFiles.first()))) {
                selectedFiles.removeFirst();
            } else {
                QMessageBox::critical(this,tr("Error!")
                                      ,tr("Copying file %1 failed")
                                        .arg(fileSystemModel->fileName(selectedFiles.first()))
                                      ,QMessageBox::Ok);
                break;
            }
        }
        if(selectedFiles.isEmpty())
            mode_copy = false;
    } else if(mode_cut) {
        //Move files until filelist is empty or error occured
        while(!selectedFiles.isEmpty()) {
            if(QFile::rename(fileSystemModel->fileInfo(selectedFiles.first()).absoluteFilePath()
                        , fileSystemModel->rootPath()+"/"+fileSystemModel->fileName(selectedFiles.first()))) {
                    selectedFiles.removeFirst();
            } else {
                QMessageBox::critical(this,tr("Error!")
                                      ,tr("Moving file %1 failed")
                                        .arg(fileSystemModel->fileName(selectedFiles.first()))
                                      ,QMessageBox::Ok);
                break;
            }
        }
        if(selectedFiles.isEmpty())
            mode_cut = false;
    }
    fileSystemModel->setReadOnly(true);
    this->clearSelection();
}

/**
  Deletes selected files
  */
void FileListWidget::actionDelete()
{
    mode_cut = false;
    mode_copy = false;
    if(QMessageBox::Yes == QMessageBox::warning(this, tr("Deleting file")
                            ,tr("You are about to delete %1 file(s).\nAre you sure you want to continue?")
                                .arg(this->selectedIndexes().count())
                            , QMessageBox::Yes, QMessageBox::No)) {
        fileSystemModel->setReadOnly(false);
        selectedFiles = this->selectedIndexes();
        //delete files until filelist empty or error occured
        while(!selectedFiles.isEmpty()) {
            if(fileSystemModel->remove(selectedFiles.first())) {
                selectedFiles.removeFirst();
            } else {
                QMessageBox::critical(this,tr("Error!")
                                      ,tr("Deleting file %1 failed")
                                        .arg(fileSystemModel->fileName(selectedFiles.first()))
                                      ,QMessageBox::Ok);
                break;
            }
        }
        fileSystemModel->setReadOnly(true);
        this->clearSelection();
    }
}

/**
  @return Current directory
  */
QString FileListWidget::getPath()
{
    return currentDir.absolutePath();
}

/**
  Changes current directory
  @param path directory to change to
  */
void FileListWidget::changePath(QString path)
{
    currentDir.cd(path);
    QString newPath = currentDir.absolutePath();
    fileSystemModel->setRootPath(newPath);
    this->clearSelection();
    this->setRootIndex(fileSystemModel->index(newPath));
    emit pathChanged(newPath);
}

/**
  Equivalent to changePath("..")
  */
void FileListWidget::changePathUp()
{
    changePath("..");
}

void FileListWidget::handleItemActivation(QModelIndex index)
{
    if(!select) {
        QFileInfo file = fileSystemModel->fileInfo(index);
        if(file.isDir()) {
            changePath(file.absoluteFilePath());
        } else if(file.isExecutable()) {
            // Make process
            QProcess::startDetached(file.absoluteFilePath());
        } else {
#ifdef Q_WS_MAEMO_5 // Uses native file opening method
            DBusConnection* conn;
            conn = dbus_bus_get(DBUS_BUS_SESSION, 0);
            hildon_mime_open_file(conn, QUrl::fromLocalFile(file.absoluteFilePath()).toEncoded().constData());
#else
            /*
            Not working with maemo5.
            Uses hildon_uri_open function from
            libhildonmime which should work,
            but all files opened in browser.
            */
            QDesktopServices::openUrl(QUrl::fromLocalFile(file.absoluteFilePath()));
#endif
        }
    }
}
/**
  @param mode true activates file selection
  */
void FileListWidget::setSelectMode(bool mode)
{
    select = mode;
}

void FileListWidget::actionSendFiles()
{
    if(!mode_copy) {
        QMessageBox::information(this,
                                 tr("Sending files"),
                                 tr("To send files, select files you want to send and copy them."),
                                 QMessageBox::Cancel);
    } else {
#ifdef Q_WS_MAEMO_5
        // Create list of file urls
        QStringList files;
        while(!selectedFiles.isEmpty()) {
            files.append(QUrl::fromLocalFile(fileSystemModel->fileInfo(selectedFiles.first()).absoluteFilePath()).toString());
            selectedFiles.removeFirst();
        }

        // Make dbuscall to send files
        QDBusInterface interface("com.nokia.bt_ui", "/com/nokia/bt_ui", "com.nokia.bt_ui",QDBusConnection::systemBus());
        interface.call("show_send_file_dlg", files);
#else
        QMessageBox::information(this,
                                 tr("Sending files"),
                                 tr("Only in maemo5 for now"),
                                 QMessageBox::Cancel);
#endif
    }
}

