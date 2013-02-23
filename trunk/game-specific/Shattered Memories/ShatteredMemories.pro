CONFIG -= flat
CONFIG += ordered
TEMPLATE = subdirs

SUBDIRS = \
	Common \
	Compression \
	ArcTool \
	TextLib \
	TextConv \
	PatcherLib \
	WorkPatcher \
	ScriptEditor \
	StreamParser \
	externals/core \
	externals/WiiStreams \
	externals/pnglite \
	externals/zlib \
