QT -= gui
QT += core
TEMPLATE = app
CONFIG += qtestlib

SOURCES = *.cpp
HEADERS = *.h

include(../../Corruption.pri)

LIBS += core.h ExtractorLib.lib