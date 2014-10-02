QT += core gui opengl

SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)
FORMS = $$files(ui/*.ui)

isEmpty(NO_PRECOMPILED_HEADER){
	CONFIG += precompile_header
	PRECOMPILED_HEADER = pch.h
}

TEMPLATE = app
LIBS += ScriptTesterLib.lib FontLib.lib
RESOURCES = ScriptViewer.qrc

CONFIG(debug, debug|release){
	CONFIG += console
}

include(../Corruption.pri)
