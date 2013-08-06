include(Patcher.pri)

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

LIBS += \
	WiiStreams.lib \
	StreamParserLib.lib \
	PatcherLib.lib \
	core.lib \

MOC_DIR = generatedfiles/moc
UI_HEADERS_DIR = generatedfiles/ui
UI_SOURCES_DIR = generatedfiles/ui
RCC_DIR = generatedfiles/rcc

INCLUDEPATH += \
	$$PWD \
	$$PWD/wizard \
	$$PWD/$$UI_HEADERS_DIR \
