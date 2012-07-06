QT -= core gui
CONFIG += static
CONFIG -= flat
TEMPLATE = lib

COREDIR = ../../../core

HEADERS = \
	*.h \
	aes/*.h \
	include/openssl/*.h \
	sha/*.h \
	
SOURCES = \
	*.cpp \
	aes/*.c \
	sha/*.c \

INCLUDEPATH += \
	. \
	aes \
	include \
	include/openssl \
	sha \
	$$COREDIR \
	$$COREDIR/Streams \
	$$COREDIR/classes \

CONFIG(release)
{
	CONFIG_NAME = release
}
CONFIG(debug, release|debug)
{
	CONFIG_NAME = debug
}

QMAKE_LIBDIR += \
	$$COREDIR/$$CONFIG_NAME \
	
LIBS += core.lib
