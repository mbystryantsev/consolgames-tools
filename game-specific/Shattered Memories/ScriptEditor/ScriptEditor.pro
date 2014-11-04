include(../ShatteredMemories.pri)

QT += core gui

SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)
FORMS = $$files(ui/*.ui)
TEMPLATE = app
RESOURCES = ScriptEditor.qrc

isEmpty(NO_PRECOMPILED_HEADER) {
	PRECOMPILED_HEADER = pch.h
	SOURCES -= pch.h.cpp
}

!lessThan(QT_VER_MAJ, 5) {
	QT += widgets
}

CONFIG(debug, debug|release){
	CONFIG += console
}

LIBS += core.lib Common.lib TextLib.lib CommonQt.lib