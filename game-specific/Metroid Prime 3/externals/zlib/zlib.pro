QT -= core gui
CONFIG += static
TEMPLATE = lib

DEFINES += _CRT_SECURE_NO_WARNINGS

CONFIG(external_build){
	ZLIBDIR = $$PWD
} else {
	ZLIBDIR = $$PWD/../../../../externals/zlib
}

HEADERS = $$files($$ZLIBDIR/*.h)
SOURCES = $$files($$ZLIBDIR/*.c)
INCLUDEPATH += $$ZLIBDIR
