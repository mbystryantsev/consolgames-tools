QT -= core gui
CONFIG += static
CONFIG -= qt flat
TEMPLATE = lib

HEADERS = \
	$$files(*.h) \
	$$files(classes/*.h) \
	$$files(streams/*.h) \
	$$files(streams/iso/*.h) \

SOURCES = \
	$$files(classes/*.cpp) \
	$$files(streams/*.cpp) \
	$$files(streams/iso/*.cpp) \

INCLUDEPATH += \
	. \
	classes \
	streams \
