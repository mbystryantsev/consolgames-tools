include(../ShatteredMemories.pri)

QT += core
CONFIG -= flat
CONFIG += static
TEMPLATE = lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)

LIBS += core.lib Common.lib
