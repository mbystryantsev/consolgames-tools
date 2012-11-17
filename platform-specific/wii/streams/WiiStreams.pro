QT -= core gui
CONFIG += static
CONFIG -= qt flat
TEMPLATE = lib

HEADERS = \
	$$files(*.h) \
	$$files(aes/*.h) \
	$$files(include/openssl/*.h) \
	$$files(sha/*.h) \

SOURCES = \
	$$files(*.cpp) \
	$$files(aes/*.c) \
	$$files(sha/*.c) \

INCLUDEPATH += \
	. \
	aes \
	include \
	include/openssl \
