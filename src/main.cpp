#include <QtGui/QApplication>
#include <QTranslator>
#include <QLocale>
#include "core.h"
#include <QDebug>
#include <QProcessEnvironment>
#include <QtCore/QtGlobal>
//remove when working
#include <QDeclarativeView>

#ifdef MEEGO_EDITION_HARMATTAN
#include <MDeclarativeCache>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
#ifndef MEEGO_EDITION_HARMATTAN
    QApplication *a = new QApplication(argc, argv);
#else
    QApplication *a = MDeclarativeCache::qApplication(argc, argv);
#endif
//    QTranslator translator;

//    /* For some reason QLocale::system() returns
//    locale by LC_NUMERIC environment variable in linux which is
//    meant for numerics like thousand separator etc.

//    In this solution we get locale from LANG environment variable
//    and use QLocale::system() as fallback.
//      */
//    if(QProcessEnvironment::systemEnvironment().contains("LANG"))
//        translator.load(":/cuteexplorertranslation_"+QLocale(QProcessEnvironment::systemEnvironment().value("LANG")).name());
//    else
//        translator.load(":/cuteexplorertranslation_"+QLocale::system().name());

//    a->installTranslator(&translator);
#ifdef MEEGO_EDITION_HARMATTAN
    QDeclarativeView *v = MDeclarativeCache::qDeclarativeView();
#else
    QDeclarativeView *v = new QDeclarativeView;
#endif
    Core *c = new Core(v);
    v->show();
    int ret = a->exec();
    delete a;
    return ret;
}
