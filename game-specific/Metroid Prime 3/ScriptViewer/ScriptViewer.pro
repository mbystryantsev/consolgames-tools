QT += core gui widgets opengl

SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)
FORMS = $$files(ui/*.ui)

# TODO: Use separate directories for intermediate files
HEADERS -= ui_CentralWidget.h
SOURCES -= pch.h.cpp

isEmpty(NO_PRECOMPILED_HEADER){
	CONFIG += precompile_header
	PRECOMPILED_HEADER = pch.h
}

TEMPLATE = app
LIBS += ScriptTesterLib.lib FontLib.lib opengl32.lib
RESOURCES = ScriptViewer.qrc

CONFIG(debug, debug|release){
	CONFIG += console
}

include(../Corruption.pri)
