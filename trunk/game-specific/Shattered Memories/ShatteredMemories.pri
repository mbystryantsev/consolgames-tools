CONFIG += debug_and_release

CONFIG(debug, debug|release) {
	CONFIG_NAME = debug
} else {
	CONFIG_NAME = release
}

DEFINES += _SCL_SECURE_NO_WARNINGS _CRT_SECURE_NO_WARNINGS

EXTERNALS = $$PWD/../../externals/

INCLUDEPATH += \
	$$PWD/Common \
	$$PWD/Compression \
	$$PWD/TextLib \
	$$PWD/PatcherLib \
	$$PWD/StreamParserLib \
	$$PWD/../../core \
	$$PWD/../../core/streams \
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

QMAKE_LIBDIR += \
	$$PWD/Common/$$CONFIG_NAME \
	$$PWD/Compression/$$CONFIG_NAME \
	$$PWD/TextLib/$$CONFIG_NAME \
	$$PWD/PatcherLib/$$CONFIG_NAME \
	$$PWD/StreamParserLib/$$CONFIG_NAME \
	$$PWD/externals/core/$$CONFIG_NAME \
	$$PWD/externals/pnglite/$$CONFIG_NAME \
	$$PWD/externals/zlib/$$CONFIG_NAME \
	$$PWD/externals/WiiStreams/$$CONFIG_NAME \
	$$PWD/externals/nvtt/$$CONFIG_NAME \
	$$EXTERNALS/nvidia-texture-tools/gnuwin32/lib \

	