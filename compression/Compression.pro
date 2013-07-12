QT -= core gui
CONFIG += static
CONFIG -= qt flat
TEMPLATE = lib

HEADERS = \
	$$files(*.h) \

SOURCES = \
	$$files(*.cpp) \

LIBS += core.lib

INCLUDEPATH += \
	../core \
	../core/streams \
