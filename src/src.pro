# -------------------------------------------------
# Project created by QtCreator 2010-01-13T19:38:20
# -------------------------------------------------
TARGET = cuteexplorer
TEMPLATE = app
QT += declarative

SOURCES += \
    main.cpp \
    core.cpp

HEADERS += \
    core.h

FORMS +=

TRANSLATIONS += cuteexplorertranslation_fi_FI.ts

RESOURCES += i18n.qrc \
    qml.qrc

DEFINES += CUTE_VERSION=\\\"1.2\\\"

CONFIG += qdeclarative-boostable

OTHER_FILES += \
    cuteexplorer_icon.svg \
    cuteexplorer.desktop \
    cuteexplorer_icon64.png \
    qml/view.qml \
    about.txt

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
