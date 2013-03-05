include(../ShatteredMemories.pri)

QT -= gui
QT += core
CONFIG += console
CONFIG -= flat
TEMPLATE = app

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)

LIBS += core.lib Common.lib StreamParserLib.lib
