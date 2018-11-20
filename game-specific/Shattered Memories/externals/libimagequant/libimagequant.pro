QT -= core gui
CONFIG += static
TEMPLATE = lib

DEFINES += _CRT_SECURE_NO_WARNINGS
QMAKE_CXXFLAGS += /wd4100 /wd4244 /wd4018 /wd4028 /wd4305

EXTERNALS = ../../../../externals
LIBQUANTDIR = $$EXTERNALS/libimagequant

HEADERS = $$files($$LIBQUANTDIR/*.h)
SOURCES = $$LIBQUANTDIR/pam.c $$LIBQUANTDIR/mediancut.c $$LIBQUANTDIR/blur.c $$LIBQUANTDIR/mempool.c $$LIBQUANTDIR/kmeans.c $$LIBQUANTDIR/nearest.c $$LIBQUANTDIR/libimagequant.c

INCLUDEPATH += $$PWD $$LIBQUANTDIR
