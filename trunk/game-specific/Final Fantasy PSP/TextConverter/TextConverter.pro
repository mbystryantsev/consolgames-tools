QT += gui
CONFIG += console static
HEADERS = *.h
SOURCES = *.cpp
TEMPLATE = app
INCLUDEPATH += $$PWD/../common \
	$$PWD/../../../externals/freetype-2.4.9/include \
	$$PWD/../../../../nvidia-texture-tools/src \
	$$PWD/../../../../nvidia-texture-tools/extern/poshlib \
	$$PWD/../../../../nvidia-texture-tools/project/vc9 \
	
LIBS += $$PWD/../../../externals/freetype-2.4.9/objs/win32/vc2008/freetype249ST.lib
LIBS += ../libs/freetype249ST.lib ../libs/nvcore.lib ../libs/nvmath.lib ../libs/nvimage.lib
QMAKE_LFLAGS += /OPT:REF