QT -= gui
QT += core

SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)

TEMPLATE = app
LIBS += nvtt.lib core.lib

CONFIG += console

include(../Corruption.pri)
