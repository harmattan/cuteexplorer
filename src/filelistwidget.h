#ifndef FILELISTWIDGET_H
#define FILELISTWIDGET_H

#include <QListView>
#include <QFileSystemModel>
#include <QDir>
#include <QMessageBox>
#include <QKeyEvent>

class FileListWidget : public QListView
{
Q_OBJECT
public:
    explicit FileListWidget(QWidget *parent = 0);

    QString getPath();

signals:
    void pathChanged(QString newPath);

public slots:
    void changePath(QString path);
    void changePathUp();

    void actionDelete();
    void actionCut();
    void actionCopy();
    void actionPaste();
    void actionSwitchMode(bool iconmode=true);
    void actionRename();
    void actionShowHidden(bool show=true);
    void actionSendFiles();

    void setSelectMode(bool mode=true);
private slots:
    void handleItemActivation(QModelIndex index);

private:
    QFileSystemModel *fileSystemModel;
    QDir currentDir;
    QModelIndexList selectedFiles;
    bool mode_cut;
    bool mode_copy;
    bool select;
};

#endif // FILELISTWIDGET_H
