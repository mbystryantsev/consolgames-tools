include(../../common.pri)

QT -= gui
QT += core

CONFIG += qtestlib

TEMPLATE = app

INCLUDEPATH += $$ROOT/LZ77 $$ROOT/DataPackage

SOURCES = *.cpp
HEADERS = *.h
LIBS += LZ77.lib DataPackage.lib
