include(../ShatteredMemories.pri)

CONFIG -= flat
CONFIG += console
TEMPLATE = app

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)

LIBS += core.lib Common.lib CommonQt.lib PatcherLib.lib
