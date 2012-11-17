QT -= core gui
CONFIG += static
CONFIG -= qt flat
TEMPLATE = lib

HEADERS = \
	$$files(*.h) \
	$$files(classes/*.h) \
	$$files(streams/*.h) \

SOURCES = \
	$$files(classes/*.cpp) \
	$$files(streams/*.cpp) \

INCLUDEPATH += \
	. \
	classes \
	streams \
