include(../ShatteredMemories.pri)

QT += core gui

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
FORMS = $$files(ui/*.ui)
TEMPLATE = app
CONFIG += precompiled_header
DEFINES += CG_LOG_ENABLED

PRECOMPILED_HEADER = pch.h

!contains(DEFINES, PRODUCTION) || CONFIG(debug, release|debug){
	CONFIG += console
}

LIBS += core.lib PatcherLib.lib Common.lib CommonQt.lib StreamParserLib.lib
