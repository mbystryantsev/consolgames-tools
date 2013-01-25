QT += core
QT -= gui
CONFIG += console

SOURCES = *.cpp
HEADERS = *.h
TEMPLATE = app
LIBS += ScriptTesterLib.lib FontLib.lib
QMAKE_LFLAGS += /OPT:REF

include(../Corruption.pri)
