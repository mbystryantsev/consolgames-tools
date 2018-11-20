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
	$$PWD/ScriptTesterLib \
	$$PWD/ExtractorLib \
	$$PWD/PasterLib \
	$$PWD/FontLib \
	$$PWD/../../platform-specific/wii/streams \
	$$PWD/../../platform-specific/wii/streams/include \
	$$PWD/../../platform-specific/wii/streams/include/openssl \
	$$PWD/../../core \
	$$PWD/../../core/streams \
	$$PWD/../../core/classes \
	$$EXTERNALS/zlib \
	$$EXTERNALS/pnglite \
	$$EXTERNALS/libpng \
	$$EXTERNALS/libjpeg \
	$$EXTERNALS/libimagequant \
	$$EXTERNALS/nvidia-texture-tools/project/vc9 \
	$$EXTERNALS/nvidia-texture-tools/src \
	$$EXTERNALS/nvidia-texture-tools/src/nvcore \
	$$EXTERNALS/nvidia-texture-tools/src/nvmath \
	$$EXTERNALS/nvidia-texture-tools/src/nvimage \
	$$EXTERNALS/nvidia-texture-tools/src/nvtt \
	$$EXTERNALS/nvidia-texture-tools/extern/poshlib \

QMAKE_LIBDIR += \
	$$PWD/ScriptTesterLib/$$CONFIG_NAME \
	$$PWD/ExtractorLib/$$CONFIG_NAME \
	$$PWD/PasterLib/$$CONFIG_NAME \
	$$PWD/FontLib/$$CONFIG_NAME \
	$$PWD/externals/core/$$CONFIG_NAME \
	$$PWD/externals/pnglite/$$CONFIG_NAME \
	$$PWD/externals/zlib/$$CONFIG_NAME \
	$$PWD/externals/WiiStreams/$$CONFIG_NAME \
	$$PWD/externals/libpng/$$CONFIG_NAME \
	$$PWD/externals/libjpeg/$$CONFIG_NAME \
	$$PWD/externals/libimagequant/$$CONFIG_NAME \
	$$PWD/externals/nvtt/$$CONFIG_NAME \
	$$PWD/../../libs \
	$$EXTERNALS/nvidia-texture-tools/gnuwin32/lib \
