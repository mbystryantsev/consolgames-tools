include(../ShatteredMemories.pri)

QT -= gui core
CONFIG -= flat qt
CONFIG += static
TEMPLATE = lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)

isEmpty(NO_PRECOMPILED_HEADER){
	CONFIG += precompile_header
	PRECOMPILED_HEADER = pch.h
	SOURCES -= pch.h.cpp
} else {
	QMAKE_CXXFLAGS += -FIpch.h
}

LIBS += core.lib zlib.lib Common.lib
