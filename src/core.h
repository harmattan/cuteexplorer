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

    // Property bool showHidden
public:
    Q_PROPERTY(bool showHidden READ showHidden WRITE setShowHidden NOTIFY showHiddenChanged)
    bool showHidden() const;
public slots:
    void setShowHidden(bool show = true);
signals:
    void showHiddenChanged(bool show);


    // Property QString currentPath
public:
    Q_PROPERTY(QString currentPath READ currentPath WRITE openPath NOTIFY currentPathChanged)
    QString currentPath() const;
public slots:
    void openPath(const QString &path);
signals:
    void currentPathChanged(const QString &path);

    // Property bool filesSelected
public:
    Q_PROPERTY(bool filesSelected READ filesSelected NOTIFY filesSelectedChanged)
    bool filesSelected() const { return !m_selection.isEmpty(); }
signals:
    void filesSelectedChanged(bool selected);

    // Property bool filesInClipboard
public:
    Q_PROPERTY(bool filesInClipboard READ filesInClipboard NOTIFY filesInClipboardChanged)
    bool filesInClipboard() const { return !m_itemsForAction.isEmpty(); }
signals:
    void filesInClipboardChanged(bool inClipboard);


public slots:
    void showHelp();
    void showAbout();
    void fileSelected(const QModelIndex &index, bool selected = true);
    bool fileIsSelected(const QModelIndex &index);
    void clearSelection();
    void openFile(const QModelIndex &index);
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
