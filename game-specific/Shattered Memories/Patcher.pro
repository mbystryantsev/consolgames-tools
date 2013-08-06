CONFIG -= flat
CONFIG += ordered
TEMPLATE = subdirs
CONFIG += release

SUBDIRS = \
	Common \
	Compression \
	PatcherLib \
	StreamParserLib \
	Patcher \
	externals/core \
	externals/zlib \
	externals/WiiStreams \
