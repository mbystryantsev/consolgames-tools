QT -= gui core
CONFIG += static
CONFIG -= flat qt
TEMPLATE = lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
LIBS = core.lib

include(lzo/lzo.pri)
include(../Corruption.pri)
