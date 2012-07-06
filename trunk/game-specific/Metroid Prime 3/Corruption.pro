CONFIG -= flat
CONFIG += ordered
TEMPLATE = subdirs

SUBDIRS = \
	ScriptTesterLib \
	ScriptTester \
	Patcher \
	externals/core \
	externals/WiiStreams \
	tests/ScriptTesterTests
	