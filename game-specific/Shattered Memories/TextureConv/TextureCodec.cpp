#include "TextureCodec.h"
#include "Quantize.h"
#include <Image.h>
#include <FloatImage.h>
#include <Filter.h>
#include <Color.h>
#include <memory>
#include <algorithm>

namespace
{

template <typename T, typename DT>
inline void copy(const T src, DT dest, int count)
{
	std::copy(src, src + count, dest);
}

struct Rect
{
	Rect(int x, int y, int width, int height)
		: x(x)
		, y(y)
		, width(width)
		, height(height)
	{
	}

	int x;
	int y;
	int width;
	int height;
};

void copyRect(const nv::Image& src, nv::Image& dest, const Rect& sourceRect, int destX, int destY)
{
	for (int line = 0; line < sourceRect.height; line++)
	{
		const nv::Color32* srcPixels = src.scanline(sourceRect.y + line) + sourceRect.x;
		nv::Color32* destPixels = dest.scanline(destY + line) + destX;
		copy(srcPixels, destPixels, sourceRect.width);
	}
}

}

uint32_t TextureCodec::encodedRasterSize(int format, int width, int height, int mipmaps) const
{
	if (!isFormatSupported(format))
	{
		ASSERT(!"Unsupported format!");
		return 0;
	}

	if (mipmaps == mipmapCountDefault)
	{
		mipmaps = defaultMipmapCount();
	}

	if (mipmaps > 1 && !isMipmapsSupported(format))
	{
		ASSERT(!"Mipmaps is not supported for this format!");
		return 0;
	}

	uint32_t size = 0;
	while (mipmaps > 0)
	{
		size += encodedRasterSize(format, width, height);
		mipmaps--;
		width /= 2;
		height /= 2;
		width = std::max(width, minWidth(format));
		height = std::max(height, minHeight(format));
	}

	return size;
}

bool TextureCodec::encode(void* result, const void* imageData, int format, int width, int height, void* palette, int paletteFormat, int mipmaps)
{
	if (mipmaps == mipmapCountDefault)
	{
		mipmaps = defaultMipmapCount();
	}

	if (mipmaps == 1 && width >= minWidth(format) && height >= minHeight(format))
	{
		Quantizer quantizer;
		return encode(result, imageData, format, width, height, palette, paletteFormat, false, quantizer);
	}

	if (!isMipmapsSupported(format))
	{
		return false;
	}

    unsigned char* destBytes = static_cast<unsigned char*>(result);
    nv::BoxFilter filter;
	
	std::auto_ptr<nv::Image> image(new nv::Image());
	image->allocate(width, height);
	const nv::Color32* colors = static_cast<const nv::Color32*>(imageData);
	for (uint line = 0; line < image->height(); line++)
	{
		copy(colors, image->scanline(line), width);
		colors += width;
	}

    int totalSize = 0;
	Quantizer quantizer;
    for (int i = 0; i < mipmaps; i++)
    {
        const int mipmapWidth = nv::max(width, minWidth(format));
        const int mipmapHeight = nv::max(height, minHeight(format));
		if (width < minWidth(format) || height < minHeight(format))
		{
			std::auto_ptr<nv::Image> canvas(new nv::Image());
			canvas->allocate(mipmapWidth, mipmapHeight);
			canvas->fill(nv::Color32(255, 255, 255));
			copyRect(*image.get(), *canvas.get(), Rect(0, 0, width, height), 0, 0);
			if (!encode(destBytes, canvas->pixels(), format, mipmapWidth, mipmapHeight, palette, paletteFormat, i > 0, quantizer))
			{
				return false;
			}
		}
		else
		{
			if (!encode(destBytes, image->pixels(), format, mipmapWidth, mipmapHeight, palette, paletteFormat, i > 0, quantizer))
			{
				return false;
			}
		}
		
		const int mipmapDataSize = encodedRasterSize(format, mipmapWidth, mipmapHeight);
		destBytes += mipmapDataSize;
		totalSize += mipmapDataSize;

        if (i == mipmaps - 1)
		{
			break;
		}

		width /= 2;
		height /= 2;

		nv::FloatImage floatImage(image.get());
		std::auto_ptr<nv::FloatImage> resizedFloatImage(floatImage.resize(filter, width, height, nv::FloatImage::WrapMode_Mirror));   
		image.reset(resizedFloatImage->createImage());
	}

    return true;
}

bool TextureCodec::decode(void* result, const void* image, int format, int width, int height, const void* palette, int paletteFormat, int mipmaps)
{
	if (mipmaps == 1 || mipmaps == mipmapCountDefault)
	{
		return decode(result, image, format, width, height, palette, paletteFormat);
	}

	const int resultWidth = width + width / 2;
	const int resultHeight = height;
	nv::Image resultImage;
	resultImage.allocate(resultWidth, resultHeight);
	resultImage.fill(nv::Color32(0));

	int destX = 0;
	int destY = 0;

	const uint8_t* bytes = static_cast<const uint8_t*>(image);
	for (int i = 0; i < mipmaps; i++)
	{
		const int mipmapWidth = std::max(width, minWidth(format));
		const int mipmapHeight = std::max(height, minHeight(format));
		
		if (!decode(result, bytes, format, mipmapWidth, mipmapHeight, palette, paletteFormat))
		{
			return false;
		}

		nv::Image image;
		image.wrap(result, mipmapWidth, mipmapHeight);
		copyRect(image, resultImage, Rect(0, 0, width, height), destX, destY);
		image.unwrap();

		if (destX == 0)
		{
			destX = width;
		}
		else
		{
			destY += height;
		}

		bytes += encodedRasterSize(format, width, height);
		width /= 2;
		height /= 2;
	}

	copy(resultImage.pixels(), reinterpret_cast<nv::Color32*>(result), resultWidth * resultHeight);

	return true;
}