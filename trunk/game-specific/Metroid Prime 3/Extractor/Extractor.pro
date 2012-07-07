QT -= core gui
CONFIG += console
LIBS += ExtractorLib.lib

SOURCES = main.cpp
TEMPLATE = app

include(../Corruption.pri)
