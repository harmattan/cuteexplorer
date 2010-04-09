# -------------------------------------------------
# Project created by QtCreator 2010-01-13T19:38:20
# -------------------------------------------------
TARGET = cuteexplorer
TEMPLATE = app

SOURCES += main.cpp \
    mainwindow.cpp \
    filelistwidget.cpp
HEADERS += mainwindow.h \
    filelistwidget.h
FORMS += mainwindow.ui
TRANSLATIONS += cuteexplorertranslation_fi_FI.ts
RESOURCES += i18n.qrc


maemo5 {
    #VARIABLES
    CONFIG += link_pkgconfig
    PKGCONFIG += dbus-1 gnome-vfs-2.0
    LIBS += -lhildonmime -ldbus-1
    QT += dbus
    isEmpty(PREFIX) {
        PREFIX = /usr
  }
BINDIR = $$PREFIX/bin
DATADIR =$$PREFIX/share

DEFINES += DATADIR=\\\"$$DATADIR\\\" PKGDATADIR=\\\"$$PKGDATADIR\\\"

#MAKE INSTALL

INSTALLS += target desktop icon icon64

  target.path =$$BINDIR

  desktop.path = $$DATADIR/applications/hildon
  desktop.files += $${TARGET}.desktop

  icon64.path = $$DATADIR/icons/hicolor/64x64/apps
  icon64.files += $${TARGET}_icon64.png

  icon.path = $$DATADIR/icons/hicolor/scalable/apps
  icon.files += $${TARGET}_icon.svg
}
