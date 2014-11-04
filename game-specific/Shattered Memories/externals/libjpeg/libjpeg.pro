QT -= core gui
CONFIG += static
TEMPLATE = lib

DEFINES += _CRT_SECURE_NO_WARNINGS
QMAKE_CXXFLAGS += /wd4100
LIBJPEGDIR = ../../../../externals/libjpeg
HEADERS = jconfig.h $$files($$LIBJPEGDIR/*.h)
SOURCES = \
	$$LIBJPEGDIR/jaricom.c  $$LIBJPEGDIR/jcapimin.c $$LIBJPEGDIR/jcapistd.c $$LIBJPEGDIR/jcarith.c  $$LIBJPEGDIR/jccoefct.c $$LIBJPEGDIR/jccolor.c \
	$$LIBJPEGDIR/jcdctmgr.c $$LIBJPEGDIR/jchuff.c   $$LIBJPEGDIR/jcinit.c   $$LIBJPEGDIR/jcmainct.c $$LIBJPEGDIR/jcmarker.c $$LIBJPEGDIR/jcmaster.c \
	$$LIBJPEGDIR/jcomapi.c  $$LIBJPEGDIR/jcparam.c  $$LIBJPEGDIR/jcprepct.c $$LIBJPEGDIR/jcsample.c $$LIBJPEGDIR/jctrans.c  $$LIBJPEGDIR/jdapimin.c \
	$$LIBJPEGDIR/jdapistd.c $$LIBJPEGDIR/jdarith.c  $$LIBJPEGDIR/jdatadst.c $$LIBJPEGDIR/jdatasrc.c $$LIBJPEGDIR/jdcoefct.c $$LIBJPEGDIR/jdcolor.c \
	$$LIBJPEGDIR/jddctmgr.c $$LIBJPEGDIR/jdhuff.c   $$LIBJPEGDIR/jdinput.c  $$LIBJPEGDIR/jdmainct.c $$LIBJPEGDIR/jdmarker.c $$LIBJPEGDIR/jdmaster.c \
	$$LIBJPEGDIR/jdmerge.c  $$LIBJPEGDIR/jdpostct.c $$LIBJPEGDIR/jdsample.c $$LIBJPEGDIR/jdtrans.c  $$LIBJPEGDIR/jerror.c   $$LIBJPEGDIR/jfdctflt.c \
	$$LIBJPEGDIR/jfdctfst.c $$LIBJPEGDIR/jfdctint.c $$LIBJPEGDIR/jidctflt.c $$LIBJPEGDIR/jidctfst.c $$LIBJPEGDIR/jidctint.c $$LIBJPEGDIR/jquant1.c \
	$$LIBJPEGDIR/jquant2.c  $$LIBJPEGDIR/jutils.c   $$LIBJPEGDIR/jmemmgr.c  $$LIBJPEGDIR/jmemnobs.c

INCLUDEPATH += $$PWD $$LIBJPEGDIR
