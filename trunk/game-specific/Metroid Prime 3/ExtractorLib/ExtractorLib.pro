QT -= gui core
CONFIG += static
CONFIG -= flat
TEMPLATE = lib

HEADERS = *.h
SOURCES = *.cpp
LIBS = core.lib

include(lzo/lzo.pri)
include(../Corruption.pri)
