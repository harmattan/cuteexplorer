#include <QtGui/QApplication>
#include "core.h"
#include "qiconitem.h"
#include <QDebug>
#include <QProcessEnvironment>
#include <QtCore/QtGlobal>
#include <QDeclarativeView>
#include <qdeclarative.h>

#ifdef MEEGO_EDITION_HARMATTAN
#include <MDeclarativeCache>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qmlRegisterType<QIconItem>("org.kde.qtextracomponents", 0, 1, "QIconItem");
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
    return ret;
}
