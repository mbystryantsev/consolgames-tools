CONFIG -= flat
CONFIG += ordered
TEMPLATE = subdirs

SUBDIRS = \
	ScriptTesterLib \
	ScriptTester \
	ExtractorLib \
	Extractor \
	PasterLib \
	Paster \
	FontLib \
	FontTool \
	TextureConv \
	Patcher \
	ScriptViewer \
	externals/core \
	externals/WiiStreams \
	externals/pnglite \
	externals/zlib \
	externals/nvtt \
	tests/ScriptTesterTests \
	tests/ExtractorTests \
