QT += core gui

HEADERS = *.h
SOURCES = *.cpp
FORMS = ui/*.ui
RESOURCES = Patcher.qrc
RC_FILE = resources/Patcher.rc
 
TEMPLATE = app
QMAKE_LFLAGS += /OPT:REF

STRDIR = ../../../platform-specific/wii/streams
COREDIR = ../../../core

CONFIG(release)
{
	CONFIG_NAME = release
}
CONFIG(debug, debug|release)
{
	CONFIG_NAME = debug
	CONFIG += console
}

INCLUDEPATH += \
	$$STRDIR \
	$$STRDIR/aes \
	$$STRDIR/include \
	$$STRDIR/include/openssl \
	$$STRDIR/sha \
	$$COREDIR \
	$$COREDIR/Streams \
	$$COREDIR/classes \
	
LIBS += ../externals/WiiStreams/$$CONFIG_NAME/WiiStreams.lib
LIBS += ../externals/core/$$CONFIG_NAME/core.lib
