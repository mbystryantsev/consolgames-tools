QT -= gui
QT += core
TEMPLATE = app
CONFIG += qtestlib

SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)

include(../../ShatteredMemories.pri)

LIBS += PatcherLib.lib StreamParserLib.lib Common.lib CommonQt.lib