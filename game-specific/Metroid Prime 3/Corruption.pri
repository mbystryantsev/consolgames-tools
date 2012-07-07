CONFIG(release, debug|release)
{
	CONFIG_NAME = release
}
CONFIG(debug, debug|release)
{
	CONFIG_NAME = debug
}

INCLUDEPATH += \
	../ScriptTesterLib \
	../ExtractorLib \
	../../platform-specific/wii/streams \
	../../core \

QMAKE_LIBDIR += \
	../ScriptTesterLib/$$CONFIG_NAME \
	../ExtractorLib/$$CONFIG_NAME \
	../externals/core/$$CONFIG_NAME \
	../externals/WiiStreams/$$CONFIG_NAME \
