include(../ShatteredMemories.pri)

QT -= gui
CONFIG -= flat
CONFIG += static
TEMPLATE = lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)

LIBS += core.lib
