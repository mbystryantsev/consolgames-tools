include(../ShatteredMemories.pri)

QT -= gui core
CONFIG += console
CONFIG -= flat qt
TEMPLATE = app

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp) $$files(*.c)

LIBS += core.lib nvtt.lib pnglite.lib libpng.a zlib.lib
