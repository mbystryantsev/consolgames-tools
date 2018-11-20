QT -= gui
QT += core testlib
TEMPLATE = app

SOURCES = *.cpp
HEADERS = *.h

CONFIG_NAME = release
CONFIG(debug, debug|release){
	CONFIG_NAME = debug
}

INCLUDEPATH +=  ../../ScriptTesterLib
QMAKE_LIBDIR += ../../ScriptTesterLib/$$CONFIG_NAME
LIBS += ScriptTesterLib.lib
