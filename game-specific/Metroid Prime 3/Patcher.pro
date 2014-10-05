CONFIG -= flat
CONFIG += ordered
TEMPLATE = subdirs
CONFIG += release

SUBDIRS = \
	core \
	WiiStreams \
	ExtractorLib \
	PasterLib \
	Patcher \
	
core.subdir = externals/core
WiiStreams.subdir = externals/WiiStreams

Patcher.depends = \
	core \
	WiiStreams \
	ExtractorLib \
	PasterLib \
