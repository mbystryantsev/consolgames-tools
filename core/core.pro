QT -= core gui
CONFIG += static
CONFIG -= flat
TEMPLATE = lib

HEADERS = \
	*.h \
	classes/*.h \
	streams/*.h \

SOURCES = \
	classes/*.cpp \
	streams/*.cpp \

INCLUDEPATH += \
	. \
	classes \
	streams \
