include(../ResidentEvil.pri)

QT -= gui core
CONFIG += static
CONFIG -= flat qt
TEMPLATE = lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
