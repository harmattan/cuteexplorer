#include <QtGui/QApplication>
#include "core.h"
#include <QDebug>
#include <QProcessEnvironment>
#include <QtCore/QtGlobal>
#include <QDeclarativeView>

#ifdef MEEGO_EDITION_HARMATTAN
#include <MDeclarativeCache>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{

#ifndef MEEGO_EDITION_HARMATTAN
    QApplication *a = new QApplication(argc, argv);
    QDeclarativeView *v = new QDeclarativeView;
    v->showFullScreen();
#else
    QApplication *a = MDeclarativeCache::qApplication(argc, argv);
    QDeclarativeView *v = MDeclarativeCache::qDeclarativeView();
    v->showFullScreen();
#endif

    Core *c = new Core(v);

    int ret = a->exec();
    delete v;
    delete a;
    delete c;
    return ret;
}
