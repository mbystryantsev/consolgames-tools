QT += core
QT -= gui
CONFIG += static

HEADERS = *.h
SOURCES = *.cpp
 
TEMPLATE = lib
QMAKE_LFLAGS += /OPT:REF
