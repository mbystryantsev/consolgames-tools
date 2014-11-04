QT -= core gui
CONFIG += static
TEMPLATE = lib
DEFINES += _SCL_SECURE_NO_WARNINGS _CRT_SECURE_NO_WARNINGS

CONFIG(external_build){
	STRDIR = $$PWD
	COREDIR = $$PWD/../core
} else {
	STRDIR = $$PWD/../../../../platform-specific/wii/streams
	COREDIR = $$PWD/../../../../core
}

HEADERS = \
	$$files($$STRDIR/*.h) \
	$$files($$STRDIR/aes/*.h) \
	$$files($$STRDIR/include/openssl/*.h) \
	$$files($$STRDIR/sha/*.h) \
	
SOURCES = \
	$$files($$STRDIR/*.cpp) \
	$$files($$STRDIR/aes/*.c) \
	$$files($$STRDIR/sha/*.c) \

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
