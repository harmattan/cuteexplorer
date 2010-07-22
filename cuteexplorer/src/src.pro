# -------------------------------------------------
# Project created by QtCreator 2010-01-13T19:38:20
# -------------------------------------------------
TARGET = cuteexplorer
TEMPLATE = app
QT += dbus
SOURCES += main.cpp \
    mainwindow.cpp \
    filelistwidget.cpp \
    searchdialog.cpp
HEADERS += mainwindow.h \
    filelistwidget.h \
    searchdialog.h
FORMS += mainwindow.ui \
    searchdialog.ui
TRANSLATIONS += cuteexplorertranslation_fi_FI.ts
RESOURCES += i18n.qrc
DEFINES += CUTE_VERSION=\\\"1.2\\\"
maemo5 { 
    # VARIABLES
    CONFIG += link_pkgconfig
    PKGCONFIG += dbus-1 \
        gnome-vfs-2.0
    LIBS += -lhildonmime \
        -ldbus-1
    isEmpty(PREFIX):PREFIX = /usr
    BINDIR = $$PREFIX/bin
    DATADIR = $$PREFIX/share
    DEFINES += DATADIR=\\\"$$DATADIR\\\" \
        PKGDATADIR=\\\"$$PKGDATADIR\\\"
    
    # MAKE INSTALL
    INSTALLS += target \
        desktop \
        icon \
        icon64
    target.path = $$BINDIR
    desktop.path = $$DATADIR/applications/hildon
    desktop.files += $${TARGET}.desktop
    icon64.path = $$DATADIR/icons/hicolor/64x64/apps
    icon64.files += $${TARGET}_icon64.png
    icon.path = $$DATADIR/icons/hicolor/scalable/apps
    icon.files += $${TARGET}_icon.svg
}

OTHER_FILES += \
    cuteexplorer_icon48.png \
    cuteexplorer_icon.svg \
    cuteexplorer.desktop \
    cuteexplorer_icon64.png
