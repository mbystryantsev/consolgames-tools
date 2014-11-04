QT -= core gui
CONFIG += static
TEMPLATE = lib

DEFINES += _CRT_SECURE_NO_WARNINGS

PNGLITEDIR = ../../../../externals/pnglite
ZLIBDIR = ../../../../externals/zlib
HEADERS = $$PNGLITEDIR/pnglite.h
SOURCES = $$PNGLITEDIR/pnglite.c
INCLUDEPATH += $$PNGLITEDIR $$ZLIBDIR

QMAKE_CXXFLAGS += /wd4100
