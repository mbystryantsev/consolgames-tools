include(../ShatteredMemories.pri)

QT += core gui

SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)
FORMS = $$files(ui/*.ui)
PRECOMPILED_HEADER = pch.h
TEMPLATE = app
LIBS += TextLib.lib
RESOURCES = ScriptEditor.qrc

CONFIG(debug, debug|release){
	CONFIG += console
}
