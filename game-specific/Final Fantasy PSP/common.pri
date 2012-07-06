CONFIG(debug, debug|release){
	CONFIG_NAME = debug
	CONFIG += console
}
else{
	CONFIG_NAME = release
}

DESTDIR = $$PWD/$$QT_ARCH/$$CONFIG_NAME
ROOT = $$PWD
QMAKE_LIBDIR += $$DESTDIR
INCLUDEPATH += $$ROOT/common
