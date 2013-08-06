CONFIG(debug, debug|release) {
	CONFIG_NAME = debug
} else {
	CONFIG_NAME = release
}

DEFINES += _SCL_SECURE_NO_WARNINGS _CRT_SECURE_NO_WARNINGS

INCLUDEPATH += \
	$$PWD/Common \
	$$PWD/Compression \
	$$PWD/PatcherLib \
	$$PWD/StreamParserLib \
	$$PWD/externals/WiiStreams \
	$$PWD/externals/WiiStreams/include \
	$$PWD/externals/WiiStreams/include/openssl \
	$$PWD/externals/zlib \
	$$PWD/externals/core \
	$$PWD/externals/core/streams \
	$$PWD/externals/core/classes \

QMAKE_LIBDIR += \
	$$PWD/Common/$$CONFIG_NAME \
	$$PWD/Compression/$$CONFIG_NAME \
	$$PWD/PatcherLib/$$CONFIG_NAME \
	$$PWD/StreamParserLib/$$CONFIG_NAME \
	$$PWD/externals/core/$$CONFIG_NAME \
	$$PWD/externals/WiiStreams/$$CONFIG_NAME \
	$$PWD/externals/zlib/$$CONFIG_NAME \
