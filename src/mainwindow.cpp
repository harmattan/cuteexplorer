#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    connect(ui->actionExit, SIGNAL(triggered()), this, SLOT(close()));
    connect(ui->upButton, SIGNAL(clicked()), ui->fileListWidget, SLOT(changePathUp()));
    connect(ui->locationLine, SIGNAL(returnPressed()), this, SLOT(locationLineEnterKeyHandler()));
    connect(ui->fileListWidget, SIGNAL(pathChanged(QString)), ui->locationLine, SLOT(setText(QString)));
    connect(ui->actionDelete, SIGNAL(triggered()), ui->fileListWidget, SLOT(actionDelete()));
    connect(ui->actionMode, SIGNAL(toggled(bool)), ui->fileListWidget, SLOT(actionSwitchMode(bool)));
    connect(ui->actionCopy, SIGNAL(triggered()), ui->fileListWidget, SLOT(actionCopy()));
    connect(ui->actionCut, SIGNAL(triggered()), ui->fileListWidget, SLOT(actionCut()));
    connect(ui->actionPaste, SIGNAL(triggered()), ui->fileListWidget, SLOT(actionPaste()));
    connect(ui->actionShow_hidden, SIGNAL(toggled(bool)), ui->fileListWidget, SLOT(actionShowHidden(bool)));
    connect(ui->actionRename, SIGNAL(triggered()), ui->fileListWidget, SLOT(actionRename()));
    connect(ui->actionSend, SIGNAL(triggered()), ui->fileListWidget, SLOT(actionSendFiles()));

    connect(ui->actionHelp, SIGNAL(triggered()), this, SLOT(showHelp()));
    connect(ui->actionAbout, SIGNAL(triggered()), this, SLOT(showAbout()));

    ui->locationLine->setText(ui->fileListWidget->getPath());

    ui->actionExit->setShortcut(QKeySequence::Quit);

    ui->actionCopy->setShortcut(QKeySequence::Copy);
    ui->actionCut->setShortcut(QKeySequence::Cut);
    ui->actionPaste->setShortcut(QKeySequence::Paste);
    ui->actionDelete->setShortcut(QKeySequence("Ctrl+D"));
    ui->actionRename->setShortcut(QKeySequence("Ctrl+R"));
    ui->actionSend->setShortcut(QKeySequence::Save);
    ui->fileListWidget->addAction(ui->actionCopy);
    ui->fileListWidget->addAction(ui->actionCut);
    ui->fileListWidget->addAction(ui->actionPaste);
    ui->fileListWidget->addAction(ui->actionDelete);
    ui->fileListWidget->addAction(ui->actionRename);
    ui->fileListWidget->addAction(ui->actionSend);
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::locationLineEnterKeyHandler()
{
    ui->fileListWidget->changePath(ui->locationLine->text());
}
void MainWindow::keyPressEvent(QKeyEvent *e)
{
    if(e->key() == Qt::Key_Control || e->key() == Qt::Key_Shift)
        ui->fileListWidget->setSelectMode(true);
    else
        QMainWindow::keyPressEvent(e);
}
void MainWindow::keyReleaseEvent(QKeyEvent *e)
{
    if(e->key() == Qt::Key_Control || e->key() == Qt::Key_Shift)
        ui->fileListWidget->setSelectMode(false);
    else
        QMainWindow::keyPressEvent(e);
}

void MainWindow::changeEvent(QEvent *e)
{
    QMainWindow::changeEvent(e);
    switch (e->type()) {
    case QEvent::LanguageChange:
        ui->retranslateUi(this);
        break;
    default:
        break;
    }
}

void MainWindow::showHelp()
{
    QString helpText;

    helpText.append("<h2>CuteExplorer "+tr("Help") +"</h2>");
    helpText.append("<p>"+ tr("Cut, copy, delete, rename, paste and send files")+"<br/>");
    helpText.append(tr("commands can be found from context menu (click and hold on maemo).")+"<br/>");
    helpText.append(tr("To select files, use ctrl and shift")+"<br/>");
    QMessageBox::about(this, tr("Help"),
                       helpText);
}
void MainWindow::showAbout()
{
    QString about;
    about.append("<h2>CuteExplorer</h2>");
    about.append(tr("<p>Version %1<br/>").arg(QString(CUTE_VERSION)));
    about.append(tr("Using Qt %1<br/>").arg(QString(QT_VERSION_STR)));
    about.append(tr("Copyright") + " 2010 Tommi \"tomma\" Asp &lt;tomma.asp@gmail.com&gt;<br/>");

    about.append(tr("<p>CuteExplorer is file manager mainly for maemo5.<br/>"));
    about.append(tr("This is still under development so please visit<br/>"));
    about.append(tr("<a href=http://cuteexplorer.garage.maemo.org>http://cuteexplorer.garage.maemo.org</a><br/>"));
    about.append(tr("to report bugs or leave feature requests. Thanks!</p>"));

    QMessageBox::about(this, tr("About CuteExplorer"),
                       about);
}

