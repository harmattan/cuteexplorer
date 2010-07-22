#include <QtGui/QApplication>
#include <QTranslator>
#include <QLocale>
#include "mainwindow.h"
#include <QDebug>
#include <QProcessEnvironment>
int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    QTranslator translator;

    /* For some reason QLocale::system() returns
    locale by LC_NUMERIC environment variable in linux which is
    meant for numerics like thousand separator etc.

    In this solution we get locale from LANG environment variable
    and use QLocale::system() as fallback.
      */
    if(QProcessEnvironment::systemEnvironment().contains("LANG"))
        translator.load(":/cuteexplorertranslation_"+QLocale(QProcessEnvironment::systemEnvironment().value("LANG")).name());
    else
        translator.load(":/cuteexplorertranslation_"+QLocale::system().name());

    a.installTranslator(&translator);

    MainWindow w;
    w.show();
    return a.exec();
}
