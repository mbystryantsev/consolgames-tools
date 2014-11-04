include(../ShatteredMemories.pri)

QT += core gui

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
FORMS = $$files(ui/*.ui)
TEMPLATE = app
DEFINES += CG_LOG_ENABLED

!lessThan(QT_VER_MAJ, 5) {
	QT += widgets
}

isEmpty(NO_PRECOMPILED_HEADER){
	CONFIG += precompile_header
	PRECOMPILED_HEADER = pch.h
	SOURCES -= pch.h.cpp
}

!contains(DEFINES, PRODUCTION) || CONFIG(debug, release|debug){
	CONFIG += console
}

LIBS += core.lib PatcherLib.lib Common.lib CommonQt.lib StreamParserLib.lib Compression.lib WiiStreams.lib zlib.lib
