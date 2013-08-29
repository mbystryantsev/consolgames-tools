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
	NamesFinder \
	StreamParserLib \
	StreamParser \
	TextureConv \
	Patcher \
	CmiTool \
	externals/core \
	externals/WiiStreams \
	externals/pnglite \
	externals/zlib \
	externals/nvtt \
	tests/PatcherLibTests \
