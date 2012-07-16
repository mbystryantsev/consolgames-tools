CONFIG(release, debug|release)
{
	CONFIG_NAME = release
}
CONFIG(debug, debug|release)
{
	CONFIG_NAME = debug
}

INCLUDEPATH += \
	$$PWD/ScriptTesterLib \
	$$PWD/ExtractorLib \
	$$PWD/../../platform-specific/wii/streams \
	$$PWD/../../platform-specific/wii/streams/include \
	$$PWD/../../platform-specific/wii/streams/include/openssl \
	$$PWD/../../core \
	$$PWD/../../core/streams \
	$$PWD/../../core/classes \
	$$PWD/../../externals/pnglite \
	$$PWD/../../externals/nvidia-texture-tools/project/vc9 \
	$$PWD/../../externals/nvidia-texture-tools/src \
	$$PWD/../../externals/nvidia-texture-tools/src/nvcore \
	$$PWD/../../externals/nvidia-texture-tools/src/nvmath \
	$$PWD/../../externals/nvidia-texture-tools/src/nvimage \
	$$PWD/../../externals/nvidia-texture-tools/src/nvtt \

QMAKE_LIBDIR += \
	$$PWD/ScriptTesterLib/$$CONFIG_NAME \
	$$PWD/ExtractorLib/$$CONFIG_NAME \
	$$PWD/PasterLib/$$CONFIG_NAME \
	$$PWD/externals/core/$$CONFIG_NAME \
	$$PWD/externals/WiiStreams/$$CONFIG_NAME \
