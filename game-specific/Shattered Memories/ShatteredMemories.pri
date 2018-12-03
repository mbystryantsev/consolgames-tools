# Check Qt version
QT_VERSION = $$[QT_VERSION]
QT_VERSION = $$split(QT_VERSION, ".")
QT_VER_MAJ = $$member(QT_VERSION, 0)
QT_VER_MIN = $$member(QT_VERSION, 1)

CONFIG += debug_and_release

CONFIG(debug, debug|release) {
	CONFIG_NAME = debug
} else {
	CONFIG_NAME = release
}

!contains(DEFINES, PRODUCTION) {
	DEFINES += CG_LOG_ENABLED
}

DEFINES += _SCL_SECURE_NO_WARNINGS _CRT_SECURE_NO_WARNINGS

EXTERNALS = $$PWD/../../externals/

*-g++* {
	QMAKE_CXXFLAGS += -std=c++14
}

INCLUDEPATH += \
	$$PWD/Common \
	$$PWD/CommonQt \
	$$PWD/Compression \
	$$PWD/TextLib \
	$$PWD/PatcherLib \
	$$PWD/StreamParserLib \
	$$PWD/../../core \
	$$PWD/../../core/streams \
	$$PWD/../../core/streams/iso \
	$$PWD/../../core/classes \
	$$PWD/../../platform-specific/wii/streams \
	$$PWD/../../platform-specific/wii/streams/include \
	$$PWD/../../platform-specific/wii/streams/include/openssl \
	$$EXTERNALS/nvidia-texture-tools/project/vc9 \
	$$EXTERNALS/nvidia-texture-tools/src \
	$$EXTERNALS/nvidia-texture-tools/src/nvcore \
	$$EXTERNALS/nvidia-texture-tools/src/nvmath \
	$$EXTERNALS/nvidia-texture-tools/src/nvimage \
	$$EXTERNALS/nvidia-texture-tools/src/nvtt \
	$$EXTERNALS/nvidia-texture-tools/extern/poshlib \
	$$EXTERNALS/pnglite \
	$$EXTERNALS/zlib \
	$$PWD/externals/libjpeg \
	$$PWD/externals/libpng \
	$$EXTERNALS/libjpeg \
	$$EXTERNALS/libpng \
	$$EXTERNALS/libimagequant \

DESTDIR     = $$PWD/out/$$QT_ARCH/$$CONFIG_NAME
OBJECTS_DIR = $$DESTDIR/imm/$$TARGET/obj
MOC_DIR     = $$DESTDIR/imm/$$TARGET/moc
UI_DIR      = $$DESTDIR/imm/$$TARGET/uic

QMAKE_LIBDIR += \
	$$DESTDIR \
	$$PWD/externals/core/$$CONFIG_NAME \
	$$PWD/externals/pnglite/$$CONFIG_NAME \
	$$PWD/externals/zlib/$$CONFIG_NAME \
	$$PWD/externals/WiiStreams/$$CONFIG_NAME \
	$$PWD/externals/nvtt/$$CONFIG_NAME \
	$$PWD/externals/libjpeg/$$CONFIG_NAME \
	$$PWD/externals/libpng/$$CONFIG_NAME \
	$$PWD/externals/libimagequant/$$CONFIG_NAME \
	$$PWD/../../libs \
