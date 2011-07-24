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
    Q_ENUMS(Action)

public:
    enum Action {
        NoAction = 0,
        Cut,
        Copy,
        Paste,
        Delete,
        Share
    };

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

    void invokeAction(Action a);

private slots:
    void declarativeErrors(const QList<QDeclarativeError> &errors);


private:
    void actionCut();
    void actionCopy();
    void actionPaste();
    void actionDelete();
    void actionShare();

    QFileSystemModel *m_fileSystemModel;
    QDeclarativeView *m_declarativeView;
    QModelIndexList m_selection;
    QModelIndexList m_itemsForAction;
    Action m_currentAction;

};

#endif // MAINWINDOW_H
