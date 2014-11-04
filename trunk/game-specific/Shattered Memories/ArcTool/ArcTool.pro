include(../ShatteredMemories.pri)

QT -= gui core
CONFIG -= flat qt
CONFIG += console precompiled_header
TEMPLATE = app

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
PRECOMPILED_HEADER = pch.h

LIBS += core.lib Compression.lib Common.lib zlib.lib 
