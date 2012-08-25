QT += core gui opengl

SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)
FORMS = $$files(ui/*.ui)
PRECOMPILED_HEADER = pch.h
TEMPLATE = app
LIBS += ScriptTesterLib.lib FontLib.lib

CONFIG(debug, debug|release){
	CONFIG += console
}

include(../Corruption.pri)
