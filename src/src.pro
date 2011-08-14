# -------------------------------------------------
# Project created by QtCreator 2010-01-13T19:38:20
# -------------------------------------------------
TARGET = cuteexplorer
TEMPLATE = app
QT += core gui declarative

#untill it is really set in target
DEFINES += MEEGO_EDITION_HARMATTAN

SOURCES += \
    main.cpp \
    core.cpp

HEADERS += \
    core.h

FORMS +=

RESOURCES += \
    qml_harmattan.qrc

DEFINES += CUTE_VERSION=\\\"1.2\\\"

CONFIG += qdeclarative-boostable \ # does not work with harmattan-platform-api ...
        shareuiinterface-maemo-meegotouch # for shareui to work ( does not work in harmattan-nokia-meego-api)


#fix for qdeclarative-boostable with harmattan-platform-api
#QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
#QMAKE_LFLAGS += -pie -rdynamic


OTHER_FILES += \
    cuteexplorer_icon.svg \
    cuteexplorer.desktop \
    cuteexplorer_icon64.png \
    qml_harmattan/FileDelegate.qml \
    qml_harmattan/Ui.qml \
    qml_harmattan/qmldir \
    qml_harmattan/SettingsSheet.qml

unix:!symbian {
    target.path = /opt/bin
    INSTALLS += target

    desktopfile.files = $${TARGET}.desktop
    desktopfile.path = /usr/share/applications
    INSTALLS += desktopfile

    icon.files = cuteexplorer_icon.svg
    icon.path = /usr/share/icons/hicolor/scalable/apps
    INSTALLS += icon
}
