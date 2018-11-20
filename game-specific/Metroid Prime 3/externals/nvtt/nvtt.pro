QT -= core gui
CONFIG += static
CONFIG -= flat
TEMPLATE = lib
DEFINES += _SCL_SECURE_NO_WARNINGS

NVTTDIR_BASE = ../../../../externals/nvidia-texture-tools
NVTTDIR = $$NVTTDIR_BASE/src

HEADERS = \
	nvconfig.h \
	$$NVTTDIR/nvcore/nvcore.h \
	$$NVTTDIR/nvcore/Containers.h \
	$$NVTTDIR/nvcore/Debug.h \
	$$NVTTDIR/nvcore/DefsVcWin32.h \
	$$NVTTDIR/nvcore/Library.h \
	$$NVTTDIR/nvcore/Memory.h \
	$$NVTTDIR/nvcore/Ptr.h \
	$$NVTTDIR/nvcore/StrLib.h \
	$$NVTTDIR/nvimage/nvimage.h \
	$$NVTTDIR/nvimage/BlockDXT.h \
	$$NVTTDIR/nvimage/ColorBlock.h \
	$$NVTTDIR/nvimage/DirectDrawSurface.h \
	$$NVTTDIR/nvimage/Filter.h \
	$$NVTTDIR/nvimage/FloatImage.h \
	$$NVTTDIR/nvimage/Image.h \
	$$NVTTDIR/nvimage/ImageIO.h \
	$$NVTTDIR/nvimage/NormalMap.h \
	$$NVTTDIR/nvimage/PixelFormat.h \
	$$NVTTDIR/nvimage/PsdFile.h \
	$$NVTTDIR/nvimage/Quantize.h \
	$$NVTTDIR/nvimage/TgaFile.h \
	$$NVTTDIR/nvmath/Box.h \
	$$NVTTDIR/nvmath/Color.h \
	$$NVTTDIR/nvmath/Matrix.h \
	$$NVTTDIR/nvmath/Plane.h \
	$$NVTTDIR/nvmath/Vector.h \
	$$NVTTDIR/nvtt/nvtt.h \
	$$NVTTDIR/nvtt/nvtt_wrapper.h \
	$$NVTTDIR/nvtt/CompressDXT.h \
	$$NVTTDIR/nvtt/CompressionOptions.h \
	$$NVTTDIR/nvtt/Compressor.h \
	$$NVTTDIR/nvtt/CompressRGB.h \
	$$NVTTDIR/nvtt/InputOptions.h \
	$$NVTTDIR/nvtt/OptimalCompressDXT.h \
	$$NVTTDIR/nvtt/OutputOptions.h \
	$$NVTTDIR/nvtt/QuickCompressDXT.h \
	$$NVTTDIR/nvtt/cuda/Bitmaps.h \
	$$NVTTDIR/nvtt/cuda/CudaCompressDXT.h \
	$$NVTTDIR/nvtt/cuda/CudaMath.h \
	$$NVTTDIR/nvtt/cuda/CudaUtils.h \
	$$NVTTDIR/nvtt/squish/clusterfit.h \
	$$NVTTDIR/nvtt/squish/colourblock.h \
	$$NVTTDIR/nvtt/squish/colourfit.h \
	$$NVTTDIR/nvtt/squish/colourset.h \
	$$NVTTDIR/nvtt/squish/fastclusterfit.h \
	$$NVTTDIR/nvtt/squish/maths.h \
	$$NVTTDIR/nvtt/squish/simd.h \
	$$NVTTDIR/nvtt/squish/simd_sse.h \
	$$NVTTDIR/nvtt/squish/weightedclusterfit.h \

SOURCES = \
	$$NVTTDIR/nvcore/Debug.cpp \
	$$NVTTDIR/nvcore/Library.cpp \
	#$$NVTTDIR/nvcore/Memory.cpp \
	$$NVTTDIR/nvcore/StrLib.cpp \
	$$NVTTDIR/nvcore/TextReader.cpp \
	$$NVTTDIR/nvcore/TextWriter.cpp \
	$$NVTTDIR/nvimage/BlockDXT.cpp \
	$$NVTTDIR/nvimage/ColorBlock.cpp \
	$$NVTTDIR/nvimage/DirectDrawSurface.cpp \
	$$NVTTDIR/nvimage/Filter.cpp \
	$$NVTTDIR/nvimage/FloatImage.cpp \
	$$NVTTDIR/nvimage/Image.cpp \
	$$NVTTDIR/nvimage/ImageIO.cpp \
	$$NVTTDIR/nvimage/NormalMap.cpp \
	$$NVTTDIR/nvimage/Quantize.cpp \
	$$NVTTDIR/nvmath/Plane.cpp \
	$$NVTTDIR/nvtt/CompressDXT.cpp \
	$$NVTTDIR/nvtt/CompressionOptions.cpp \
	$$NVTTDIR/nvtt/Compressor.cpp \
	$$NVTTDIR/nvtt/CompressRGB.cpp \
	$$NVTTDIR/nvtt/cuda/CudaCompressDXT.cpp \
	$$NVTTDIR/nvtt/cuda/CudaUtils.cpp \
	$$NVTTDIR/nvtt/InputOptions.cpp \
	$$NVTTDIR/nvtt/nvtt.cpp \
	$$NVTTDIR/nvtt/nvtt_wrapper.cpp \
	$$NVTTDIR/nvtt/OptimalCompressDXT.cpp \
	$$NVTTDIR/nvtt/OutputOptions.cpp \
	$$NVTTDIR/nvtt/QuickCompressDXT.cpp \
	$$NVTTDIR/nvtt/squish/colourblock.cpp \
	$$NVTTDIR/nvtt/squish/colourfit.cpp \
	$$NVTTDIR/nvtt/squish/colourset.cpp \
	$$NVTTDIR/nvtt/squish/maths.cpp \
	$$NVTTDIR/nvtt/squish/weightedclusterfit.cpp \

INCLUDEPATH += \
	$$PWD \
	$$NVTTDIR \
	$$NVTTDIR_BASE/gnuwin32/include \
	$$NVTTDIR/nvcore \
	$$NVTTDIR/nvimage \
	$$NVTTDIR/nvmath \
	$$NVTTDIR/nvtt \
	$$NVTTDIR/nvtt/squish \
	$$NVTTDIR_BASE/extern/poshlib \

QMAKE_CXXFLAGS_WARN_ON -= -w34100
QMAKE_CXXFLAGS += /wd4100 /wd4189 /wd4244 
QMAKE_LFFLAGS += /wd4221

QMAKE_LIBDIR += \
	$$EXTERNALS/nvidia-texture-tools/gnuwin32/lib \

LIBS += libpng.lib zlib.lib
