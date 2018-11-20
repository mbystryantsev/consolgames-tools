QT += core gui widgets
LIBS += core.lib ExtractorLib.lib PasterLib.lib WiiStreams.lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
TEMPLATE = app
FORMS = main.ui

# TODO: Use separate directories for intermediate files
HEADERS -= ui_main.h

CONFIG(debug, release|debug){
	CONFIG += console
}

#QMAKE_LFLAGS += "/MANIFESTUAC:\"level=\'requireAdministrator\' uiAccess=\'false\'\""

include(../Corruption.pri)
