include(../ShatteredMemories.pri)

QT -= gui
QT += core
CONFIG -= flat
CONFIG += static
TEMPLATE = lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)

isEmpty(NO_PRECOMPILED_HEADER){
	CONFIG += precompile_header
	PRECOMPILED_HEADER = pch.h
	SOURCES -= pch.h.cpp
}

LIBS += core.lib Common.lib Compression.lib WiiStreams.lib CommonQt.lib
