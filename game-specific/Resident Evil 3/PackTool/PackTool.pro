include(../ResidentEvil.pri)

QT -= gui
CONFIG += static console
CONFIG -= flat qt
TEMPLATE = app

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
LIBS += core.lib Compression.lib CompressionLib.lib
