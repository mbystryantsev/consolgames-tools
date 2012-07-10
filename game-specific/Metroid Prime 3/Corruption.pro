CONFIG -= flat
CONFIG += ordered
TEMPLATE = subdirs

SUBDIRS = \
	ScriptTesterLib \
	ScriptTester \
	ExtractorLib \
	Extractor \
	Patcher \
	externals/core \
	externals/WiiStreams \
	tests/ScriptTesterTests \
	tests/ExtractorTests \
	