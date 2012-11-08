QT -= core gui
CONFIG += static
#CONFIG -= flat
TEMPLATE = lib
DEFINES += _SCL_SECURE_NO_WARNINGS

STRDIR = ../../../../platform-specific/wii/streams
COREDIR = ../../../../core

HEADERS = \
	$$STRDIR/*.h \
	$$STRDIR/aes/*.h \
	$$STRDIR/include/openssl/*.h \
	$$STRDIR/sha/*.h \
	
SOURCES = \
	$$STRDIR/*.cpp \
	$$STRDIR/aes/*.c \
	$$STRDIR/sha/*.c \

INCLUDEPATH += \
	$$STRDIR \
	$$STRDIR/aes \
	$$STRDIR/include \
	$$STRDIR/include/openssl \
	$$STRDIR/sha \
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