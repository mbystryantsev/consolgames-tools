QT -= gui
QT += core
CONFIG += static
TEMPLATE = app
CONFIG += qtestlib

SOURCES = *.cpp
HEADERS = *.h

STRDIR = ../../../../platform-specific/wii/streams
COREDIR = ../../../../core

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
	$$STRDIR/$$CONFIG_NAME \
	$$COREDIR/$$CONFIG_NAME \
	
LIBS += core.lib streams.lib