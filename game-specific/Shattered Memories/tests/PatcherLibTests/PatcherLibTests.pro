include(../tests.pri)

SOURCES = $$files(*.cpp)
HEADERS = $$files(*.h)

LIBS += PatcherLib.lib StreamParserLib.lib Common.lib CommonQt.lib
