#include "WiiTextureCodec.h"
#include "dxt1.h"

bool WiiTextureCodec::formatIsSupported(Format format) const
{
	return (format == formatDXT1);
}

uint32 WiiTextureCodec::encodedRasterSize(Format format, int width, int height, int mipmaps) const 
{
	if (format != formatDXT1)
	{
		ASSERT(!"Unsupported format!");
		return 0;
	}

	uint32 size = 0;
	while (mipmaps > 0)
	{
		size += width * height / 2;
		mipmaps--;
		width /= 2;
		height /= 2;
		width = max(width, 8);
		height = max(height, 8);
	}
	return size;
}

uint32 WiiTextureCodec::encodedPaletteSize(Format format) const 
{
	ASSERT(format == formatDXT1);
	return 0;
}

void WiiTextureCodec::decode(void* result, const void* image, int width, int height, Format format, const void* palette, int mipmapsToDecode)
{
	if (format != formatDXT1)
	{
		ASSERT(!"Unsupported format!");
		return;
	}

	ASSERT(mipmapsToDecode >= 1);
	ASSERT(palette == NULL);
	DXTCodec::decodeDXT1(image, result, width, height, max(1, mipmapsToDecode));
}

static const int defaultMipmapCount = 4;

void WiiTextureCodec::encode(void* result, const void* image, int width, int height, Format format, void* palette, int mipmaps)
{
	if (format != formatDXT1)
	{
		ASSERT(!"Unsupported format!");
		return;
	}
	ASSERT(palette == NULL);

	DXTCodec::encodeDXT1(image, result, width, height, mipmaps == mipmapCountDefault ? defaultMipmapCount : mipmaps);
}
