QT -= core gui
CONFIG += static
CONFIG -= flat
TEMPLATE = lib
DEFINES += _SCL_SECURE_NO_WARNINGS

COREDIR = ../../../../core

HEADERS = \
	$$files($$COREDIR/*.h) \
	$$files($$COREDIR/classes/*.h) \
	$$files($$COREDIR/streams/*.h) \

SOURCES = \
	$$files($$COREDIR/classes/*.cpp) \
	$$files($$COREDIR/streams/*.cpp) \

INCLUDEPATH += \
	$$COREDIR \
	$$COREDIR/classes \
	$$COREDIR/streams \
