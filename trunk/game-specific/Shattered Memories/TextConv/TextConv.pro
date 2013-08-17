include(../ShatteredMemories.pri)

QT -= gui
CONFIG -= flat
CONFIG += console
TEMPLATE = app

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)

LIBS += core.lib TextLib.lib CommonQt.lib
