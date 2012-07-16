QT -= gui
QT += core
CONFIG += static
TEMPLATE = lib

HEADERS = *.h
SOURCES = *.cpp
LIBS = ExtractorLib.lib WiiStreams.lib

include(../Corruption.pri)
