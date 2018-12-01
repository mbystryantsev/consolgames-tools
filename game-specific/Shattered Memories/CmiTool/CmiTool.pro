include(../ShatteredMemories.pri)

CONFIG += console
CONFIG -= qt
SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)
TEMPLATE = app
LIBS += core.lib nvtt.lib pnglite.lib libpng.lib libjpeg.lib zlib.lib libimagequant.lib Common.lib
