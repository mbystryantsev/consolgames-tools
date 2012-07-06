QT += core
QT -= gui
CONFIG += console

CONFIG_NAME = release
CONFIG(debug, debug|release)
{
	CONFIG_NAME = debug
}

SOURCES = main.cpp
TEMPLATE = app
INCLUDEPATH += ../ScriptTesterLib
QMAKE_LIBDIR += ../ScriptTesterLib/$$CONFIG_NAME
LIBS += ScriptTesterLib.lib
QMAKE_LFLAGS += /OPT:REF
