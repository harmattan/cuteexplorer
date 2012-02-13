#include <QtGui/QApplication>
#include "core.h"
#include "qiconitem.h"
#include <QDebug>
#include <QProcessEnvironment>
#include <QtCore/QtGlobal>
#include <QDeclarativeView>
#include <qdeclarative.h>
#include <QScopedPointer>

#ifdef MEEGO_EDITION_HARMATTAN
#include <MDeclarativeCache>
#endif

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    qmlRegisterType<QIconItem>("org.kde.qtextracomponents", 0, 1, "QIconItem");
#ifndef MEEGO_EDITION_HARMATTAN
    QScopedPointer<QApplication> a(new QApplication(argc, argv));
    QScopedPointer<QDeclarativeView> v( new QDeclarativeView);
    v->showFullScreen();
#else
    QScopedPointer<QApplication> a(MDeclarativeCache::qApplication(argc, argv));
    QScopedPointer<QDeclarativeView> v(MDeclarativeCache::qDeclarativeView());
    v->showFullScreen();
#endif

    QScopedPointer<Core> c(new Core(v.data()));

    return a->exec();
}
