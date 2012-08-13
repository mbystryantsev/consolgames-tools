QT -= gui
CONFIG += static
CONFIG -= flat
TEMPLATE = lib

HEADERS = $$files(*.h)
SOURCES = $$files(*.cpp)
LIBS += core.lib

CONFIG(debug, debug|release){
	QT += gui
}

include(../Corruption.pri)
