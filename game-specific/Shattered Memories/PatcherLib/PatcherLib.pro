include(../ShatteredMemories.pri)

QT -= gui
QT += core
CONFIG -= flat
CONFIG += static precompiled_header
TEMPLATE = lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
PRECOMPILED_HEADER = pch.h

LIBS += core.lib Common.lib Compression.lib WiiStreams.lib
