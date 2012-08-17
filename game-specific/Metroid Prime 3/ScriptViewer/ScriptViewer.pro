QT += core gui opengl

SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)
PRECOMPILED_HEADER = pch.h
TEMPLATE = app
LIBS += ScriptTesterLib.lib FontLib.lib

CONFIG(debug, debug|release){
	CONFIG += console
}

include(../Corruption.pri)
