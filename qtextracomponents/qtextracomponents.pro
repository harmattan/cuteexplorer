### eqmake4 was here ###
TEMPLATE = lib
TARGET = qtextracomponents
QT += declarative
CONFIG += qt plugin

TARGET = $$qtLibraryTarget($$TARGET)

uri = org.kde.qtextracomponents

# Input
SOURCES += \
    qtextracomponentsplugin.cpp \
    qpixmapitem.cpp \
    qimageitem.cpp \
    qiconitem.cpp

HEADERS += \
    qtextracomponentsplugin.h \
    qpixmapitem.h \
    qimageitem.h \
    qiconitem.h

OTHER_FILES = qmldir

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$OUT_PWD/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir
unix {
    installPath = /usr/lib/qt4/imports/$$replace(uri, \\., /)
    qmldir.path = $$installPath
    target.path = $$installPath
    INSTALLS += target qmldir
}

CONFIG -= debug_and_release debug
CONFIG += release
