HEADERS += \
	$$files($$PWD/include/lzo/*.h) \
	$$PWD/compr1b.h \
	$$PWD/compr1c.h \
	$$PWD/config1.h \
	$$PWD/config1x.h \
	$$PWD/lzo_conf.h \
	$$PWD/miniacc.h \
	$$PWD/lzo_dict.h \
	$$PWD/lzo_dll.ch \
	$$PWD/lzo_func.ch \
	$$PWD/lzo_mchw.ch \
	$$PWD/lzo_ptr.h \
	$$PWD/lzo_swd.ch \

SOURCES += \
	$$PWD/lzo_crc.c \
	$$PWD/lzo_init.c \
	$$PWD/lzo_ptr.c \
	$$PWD/lzo_str.c \
	$$PWD/lzo_util.c \
	$$PWD/lzo1.c \
	$$PWD/lzo1_99.c \
	$$PWD/lzo1x_1.c \
	$$PWD/lzo1x_9x.c \
	$$PWD/lzo1x_d1.c \
	$$PWD/lzo1x_d2.c \
	$$PWD/lzo1x_d3.c \

INCLUDEPATH += $$PWD/include $$PWD/include/lzo