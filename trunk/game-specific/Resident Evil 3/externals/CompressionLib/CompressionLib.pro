QT -= core gui
CONFIG += static
TEMPLATE = lib
DEFINES += _SCL_SECURE_NO_WARNINGS

DIR = ../../../../compression
COREDIR = ../../../../core

HEADERS = \
	$$files($$DIR/*.h) \

SOURCES = \
	$$files($$DIR/*.cpp) \
	
INCLUDEPATH += \
	$$COREDIR \
	$$COREDIR/streams/ \