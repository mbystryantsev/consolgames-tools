CONFIG += debug_and_release

CONFIG(debug, debug|release) {
	CONFIG_NAME = debug
} else {
	CONFIG_NAME = release
}

DEFINES += _SCL_SECURE_NO_WARNINGS _CRT_SECURE_NO_WARNINGS

EXTERNALS = $$PWD/../../externals/

INCLUDEPATH += \
	$$PWD/NamesFinder \
	$$EXTERNALS/zlib \
	$$EXTERNALS/pnglite \
	$$EXTERNALS/nvidia-texture-tools/project/vc9 \
	$$EXTERNALS/nvidia-texture-tools/src \
	$$EXTERNALS/nvidia-texture-tools/src/nvcore \
	$$EXTERNALS/nvidia-texture-tools/src/nvmath \
	$$EXTERNALS/nvidia-texture-tools/src/nvimage \
	$$EXTERNALS/nvidia-texture-tools/src/nvtt \
	$$EXTERNALS/nvidia-texture-tools/extern/poshlib \

QMAKE_LIBDIR += \
	$$PWD/../../libs \
