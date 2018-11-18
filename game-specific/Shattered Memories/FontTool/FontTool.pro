include(../ShatteredMemories.pri)

QT -= gui
CONFIG -= flat
CONFIG += console
TEMPLATE = app

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)

LIBS += core.lib StreamParserLib.lib PatcherLib.lib CommonQt.lib Common.lib
