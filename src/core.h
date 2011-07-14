#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QObject>
#include <QModelIndexList>
#include <QIcon>
class QFileSystemModel;
class QDeclarativeView;
class QDeclarativeError;
class QDeclarativeItem;
class QModelIndex;
class Core : public QObject {
    Q_OBJECT
public:
    explicit Core(QDeclarativeView *parent = 0);
    ~Core();

public slots:
    void showHelp();
    void showAbout();
    void fileSelected(const QModelIndex &index, bool selected=true);
    bool fileIsSelected(const QModelIndex &index);
    void clearSelection();
    void openFile(const QModelIndex &index);
    void openPath(const QString &path);
    int stateChange(QDeclarativeItem* item);
    QIcon iconFromTheme(const QString &iconName);

private slots:
   void declarativeErrors(const QList<QDeclarativeError> &errors);


private:
    QFileSystemModel *m_fileSystemModel;
    QDeclarativeView *m_declarativeView;
    QModelIndexList m_selection;


};

#endif // MAINWINDOW_H
