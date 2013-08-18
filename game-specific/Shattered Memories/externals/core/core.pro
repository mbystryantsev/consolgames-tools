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
	$$COREDIR/*.h \
	$$COREDIR/classes/*.h \
	$$COREDIR/streams/*.h \
	$$COREDIR/streams/iso/*.h \

SOURCES = \
	$$COREDIR/classes/*.cpp \
	$$COREDIR/streams/*.cpp \
	$$COREDIR/streams/iso/*.cpp \

INCLUDEPATH += \
	$$COREDIR \
	$$COREDIR/classes \
	$$COREDIR/streams \
	$$COREDIR/streams/iso \
