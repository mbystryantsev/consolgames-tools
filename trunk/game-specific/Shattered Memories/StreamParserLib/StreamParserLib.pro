include(../ShatteredMemories.pri)

CONFIG -= qt flat
CONFIG += static
TEMPLATE = lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)

LIBS += core.lib
