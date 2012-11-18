include(../Corruption.pri)

QT += core gui
CONFIG -= flat
CONFIG += precompile_header
PRECOMPILED_HEADER = pch.h

HEADERS = \
	$$files(*.h) \
	$$files(wizard/*.h) \

SOURCES = \
	$$files(*.cpp) \
	$$files(wizard/*.cpp) \

FORMS = \
	$$files(ui/*.ui) \
	$$files(wizard/ui/*.ui) \

RESOURCES = \
	resources/Patcher.qrc \
	patchdata.qrc \

RC_FILE = Patcher.rc
 
TEMPLATE = app
QMAKE_LFLAGS += /OPT:REF

CONFIG(debug, debug|release){
	CONFIG += console
}

INCLUDEPATH += \
	$$PWD/wizard \
	
LIBS += \
	WiiStreams.lib \
	PasterLib.lib \
	core.lib \

TRANSLATIONS += qt_ru.ts
