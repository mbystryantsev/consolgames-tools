include(../externals.pri)

QT -= core gui
CONFIG += static
CONFIG -= flat
TEMPLATE = lib
DEFINES += _SCL_SECURE_NO_WARNINGS

!contains(DEFINES, PRODUCTION) {
	DEFINES += CG_LOG_ENABLED
}

COREDIR = ../../../../core

HEADERS = \
	$$files($$COREDIR/*.h) \
	$$files($$COREDIR/classes/*.h) \
	$$files($$COREDIR/streams/*.h) \
	$$files($$COREDIR/streams/iso/*.h) \

SOURCES = \
	$$files($$COREDIR/classes/*.cpp) \
	$$files($$COREDIR/streams/*.cpp) \
	$$files($$COREDIR/streams/iso/*.cpp) \

INCLUDEPATH += \
	$$COREDIR \
	$$COREDIR/classes \
	$$COREDIR/streams \
	$$COREDIR/streams/iso \
