QT -= core gui
CONFIG += static
CONFIG -= flat
TEMPLATE = lib
DEFINES += _SCL_SECURE_NO_WARNINGS _CRT_SECURE_NO_WARNINGS

COREDIR = $$PWD

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
