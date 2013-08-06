CONFIG -= flat
CONFIG += ordered
TEMPLATE = subdirs
CONFIG += release

SUBDIRS = \
	Common \
	Compression \
	PatcherLib \
	StreamParserLib \
	externals/core \
	externals/WiiStreams \
