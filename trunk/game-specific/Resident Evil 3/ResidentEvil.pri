CONFIG += debug_and_release

CONFIG(debug, debug|release) {
	CONFIG_NAME = debug
} else {
	CONFIG_NAME = release
}

DEFINES += _SCL_SECURE_NO_WARNINGS _CRT_SECURE_NO_WARNINGS

EXTERNALS = $$PWD/externals/

INCLUDEPATH += \
	$$PWD/Compression \
	$$PWD/../../core \
	$$PWD/../../core/streams \
	
DESTDIR = $$PWD/$$QT_ARCH/$$CONFIG_NAME

QMAKE_LIBDIR += \
	$$DESTDIR \
	$$EXTERNALS/core/$$CONFIG_NAME \
