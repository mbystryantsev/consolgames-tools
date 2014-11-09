CONFIG -= flat
CONFIG += ordered
TEMPLATE = subdirs

SUBDIRS = \
	Common \
	CommonQt \
	Compression \
	ArcTool \
	TextLib \
	TextConv \
	PatcherLib \
	WorkPatcher \
	ScriptEditor \
	StreamParserLib \
	StreamParser \
	TextureConv \
	Patcher \
	CmiTool \
	ExecutablePatcher \
	externals/core \
	externals/WiiStreams \
	externals/pnglite \
	externals/zlib \
	externals/nvtt \
	externals/libjpeg \
	tests/PatcherLibTests \
