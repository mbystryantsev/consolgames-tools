include(../externals.pri)

QT -= core gui
CONFIG += static
TEMPLATE = lib

DEFINES += _CRT_SECURE_NO_WARNINGS
QMAKE_CXXFLAGS += /wd4100
EXTERNALS = ../../../../externals
LIBPNGDIR = $$EXTERNALS/libpng
HEADERS = pnglibconf.h $$files($$LIBPNGDIR/*.h)
SOURCES = \
	$$LIBPNGDIR/png.c      $$LIBPNGDIR/pngerror.c $$LIBPNGDIR/pngget.c   $$LIBPNGDIR/pngmem.c   $$LIBPNGDIR/pngpread.c \
	$$LIBPNGDIR/pngread.c  $$LIBPNGDIR/pngrio.c   $$LIBPNGDIR/pngrtran.c $$LIBPNGDIR/pngrutil.c $$LIBPNGDIR/pngset.c \
	$$LIBPNGDIR/pngtrans.c $$LIBPNGDIR/pngwio.c   $$LIBPNGDIR/pngwrite.c $$LIBPNGDIR/pngwtran.c $$LIBPNGDIR/pngwutil.c

INCLUDEPATH += $$PWD $$LIBPNGDIR $$EXTERNALS/zlib
