QT -= gui
QT += core

SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)

TEMPLATE = app
LIBS += core.lib nvtt.lib pnglite.lib libpng.lib libjpeg.lib zlib.lib libimagequant.lib

QMAKE_LFLAGS += /SAFEESH:NO

CONFIG += console

include(../Corruption.pri)
