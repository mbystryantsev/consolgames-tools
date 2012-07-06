include(../common.pri)

QT -= core gui
CONFIG += console
HEADERS = *.h
SOURCES = *.cpp
TEMPLATE = app
INCLUDEPATH += $$ROOT/common $$ROOT/LZ77
