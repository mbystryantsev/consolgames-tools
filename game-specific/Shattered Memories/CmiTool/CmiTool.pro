include(../ShatteredMemories.pri)

CONFIG += console
CONFIG -= qt
SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)
TEMPLATE = app
LIBS += core.lib Common.lib pnglite.lib zlib.lib libimagequant.a libgcc.a libmingwex.a nvtt.lib libpng.a
