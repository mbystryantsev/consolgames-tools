QT -= gui
QT += core testlib
TEMPLATE = app

SOURCES = *.cpp
HEADERS = *.h

include(../../Corruption.pri)

LIBS += core.lib ExtractorLib.lib