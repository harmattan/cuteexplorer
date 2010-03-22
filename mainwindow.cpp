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
    ui->locationLine->setText(ui->fileListWidget->getPath());
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

