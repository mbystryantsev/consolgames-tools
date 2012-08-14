QT += core gui opengl

SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)
TEMPLATE = app
LIBS += ScriptTesterLib.lib FontLib.lib

include(../Corruption.pri)
