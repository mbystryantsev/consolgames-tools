include(../ShatteredMemories.pri)

QT += core gui

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
FORMS = $$files(ui/*.ui)
TEMPLATE = app
CONFIG += precompiled_header

PRECOMPILED_HEADER = pch.h

CONFIG(debug, release|debug){
	CONFIG += console
}

LIBS += core.lib PatcherLib.lib Common.lib
