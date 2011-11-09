# -------------------------------------------------
# Project created by QtCreator 2010-01-13T19:38:20
# -------------------------------------------------
TARGET = cuteexplorer
TEMPLATE = app
QT += core gui declarative

SOURCES += \
    main.cpp \
    core.cpp \
    qiconitem.cpp

HEADERS += \
    core.h \
    qiconitem.h

FORMS +=

RESOURCES += \
    qml_harmattan.qrc

CONFIG += qdeclarative-boostable \
        shareuiinterface-maemo-meegotouch # for shareui to work ( does not work in harmattan-nokia-meego-api)

contains(MEEGO_EDITION,harmattan) {
DEFINES += MEEGO_EDITION_HARMATTAN
}

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
