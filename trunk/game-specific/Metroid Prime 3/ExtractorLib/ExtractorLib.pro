QT -= gui core
CONFIG += static
TEMPLATE = lib

HEADERS = *.h miniLZO/*.h
SOURCES = *.cpp miniLZO/*.c
LIBS = core.lib
