QT -= gui
QT += core
CONFIG += static
TEMPLATE = lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
LIBS = ExtractorLib.lib WiiStreams.lib

include(../Corruption.pri)
