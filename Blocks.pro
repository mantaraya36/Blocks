#-------------------------------------------------
#
# Project created by QtCreator 2012-01-20T10:35:00
#
#-------------------------------------------------

QT       += core gui

TARGET = Blocks
TEMPLATE = app


DEFINES += USE_DOUBLE
unix {
macx {
INCLUDEPATH += "/usr/local/include/csound/"

LIBS += -framework CsoundLib64
LIBS += -L/Library/Frameworks/CsoundLib64.framework/Versions/Current/  -l_csnd

} else {
INCLUDEPATH += "/home/andres/src/csound5/H"
INCLUDEPATH += "/home/andres/src/csound5/interfaces"

LIBS += /home/andres/src/csound5/libcsound64.so
LIBS += /home/andres/src/csound5/libcsnd.so
}

}

SOURCES += main.cpp\
        blocks.cpp \
    fiducialproperties.cpp \
    properties.cpp

HEADERS  += blocks.h \
    fiducialproperties.h \
    properties.h

FORMS    += blocks.ui \
    fiducialproperties.ui

OTHER_FILES += \
    Blocks.csd

RESOURCES += \
    res.qrc
