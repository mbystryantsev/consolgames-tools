include(../ShatteredMemories.pri)

QT -= gui core
CONFIG -= flat qt
CONFIG += static precompile_header
TEMPLATE = lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
PRECOMPILED_HEADER = pch.h

LIBS += core.lib zlib.lib
