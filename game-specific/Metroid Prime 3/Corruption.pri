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
	$$PWD/platform-specific/wii/streams \
	$$PWD/../../core \
	$$PWD/../../core/streams \
	$$PWD/../../core/classes \

QMAKE_LIBDIR += \
	$$PWD/ScriptTesterLib/$$CONFIG_NAME \
	$$PWD/ExtractorLib/$$CONFIG_NAME \
	$$PWD/externals/core/$$CONFIG_NAME \
	$$PWD/externals/WiiStreams/$$CONFIG_NAME \
