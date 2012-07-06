set(cgcore_HEADERS
	core.h
	classes/Nullable.h
	classes/Tree.h
	classes/PathInfo.h
	streams/Stream.h
	streams/FileStream.h
	streams/MemoryStream.h
	streams/ImageStream.h
	streams/ImageFileStream.h
)

set(cgcore_SOURCES
	classes/PathInfo.cpp
	streams/Stream.cpp
	streams/FileStream.cpp
	streams/MemoryStream.cpp
	streams/ImageStream.cpp
	streams/ImageFileStream.cpp
)

source_group("Header Files" FILES cgcore_HEADERS)
source_group("Source Files" FILES cgcore_SOURCES)

add_library(cgcore STATIC EXCLUDE_FROM_ALL ${cgcore_HEADERS} ${cgcore_SOURCES})

include_directories(
	.
	streams
	classes
)
