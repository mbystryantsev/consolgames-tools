QT -= gui core
CONFIG -= flat qt
CONFIG += console
TEMPLATE = app

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)

include(../Silent.pri)
