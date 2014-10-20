include(../ShatteredMemories.pri)

QT -= gui core
CONFIG -= flat qt
CONFIG += static
TEMPLATE = lib

isEmpty(NO_PRECOMPILED_HEADER){
	CONFIG += precompile_header
	PRECOMPILED_HEADER = pch.h
} else {
	QMAKE_CXXFLAGS += -FIpch.h
}

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)

LIBS += core.lib zlib.lib Common.lib
