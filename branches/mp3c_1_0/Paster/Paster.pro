QT += core gui
LIBS += core.lib ExtractorLib.lib PasterLib.lib WiiStreams.lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
TEMPLATE = app
FORMS = main.ui

CONFIG(debug, release|debug){
	CONFIG += console
}

#QMAKE_LFLAGS += "/MANIFESTUAC:\"level=\'requireAdministrator\' uiAccess=\'false\'\""

include(../Corruption.pri)
