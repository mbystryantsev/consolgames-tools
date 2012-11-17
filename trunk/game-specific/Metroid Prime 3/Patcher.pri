CONFIG(debug, debug|release) {
	CONFIG_NAME = debug
} else {
	CONFIG_NAME = release
}

DEFINES += _SCL_SECURE_NO_WARNINGS _CRT_SECURE_NO_WARNINGS

EXTERNALS = $$PWD/../../externals/

INCLUDEPATH += \
	$$PWD/ExtractorLib \
	$$PWD/PasterLib \
	$$EXTERNALS/WiiStreams \
	$$EXTERNALS/WiiStreams/include \
	$$EXTERNALS/WiiStreams/include/openssl \
	$$EXTERNALS/core \
	$$EXTERNALS/core/streams \
	$$EXTERNALS/core/classes \

QMAKE_LIBDIR += \
	$$PWD/ExtractorLib/$$CONFIG_NAME \
	$$PWD/PasterLib/$$CONFIG_NAME \
	$$EXTERNALS/core/$$CONFIG_NAME \
	$$EXTERNALS/WiiStreams/$$CONFIG_NAME \
