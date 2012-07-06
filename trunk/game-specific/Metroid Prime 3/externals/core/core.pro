QT -= core gui
CONFIG += static
CONFIG -= flat
TEMPLATE = lib

COREDIR = ../../../../core

HEADERS = \
	$$COREDIR/*.h \
	$$COREDIR/classes/*.h \
	$$COREDIR/streams/*.h \

SOURCES = \
	$$COREDIR/classes/*.cpp \
	$$COREDIR/streams/*.cpp \

INCLUDEPATH += \
	$$COREDIR \
	$$COREDIR/classes \
	$$COREDIR/streams \
