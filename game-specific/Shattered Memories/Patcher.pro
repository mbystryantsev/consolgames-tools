CONFIG -= flat
CONFIG += ordered
TEMPLATE = subdirs
CONFIG += release

SUBDIRS = \
	externals/core \
	externals/zlib \
	externals/WiiStreams \
	Common \
	CommonQt \
	Compression \
	StreamParserLib \
	PatcherLib \
	Patcher \
