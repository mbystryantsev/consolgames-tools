#include "Quantize.h"
#include <libimagequant.h>
#include <nvimage/Quantize.h>
#include <nvimage/Image.h>
#include <vector>

void convertIndexed4ToRGBA(const void* indexed4Data, int count, const void* palette, void* dest)
{
	const uint32* pal = static_cast<const uint32*>(palette);

	const uint8* src = static_cast<const uint8*>(indexed4Data);
	uint32* dst = static_cast<uint32*>(dest);
	for (int i = 0; i < count; i += 2)
	{
		*dst++ = pal[*src & 0xF];
		*dst++ = pal[*src >> 4];
		src++;
	}	
}

void convertIndexed8ToRGBA(const void* indexed8Data, int count, const void* palette, void* dest)
{
	const uint32* pal = static_cast<const uint32*>(palette);

	const uint8* src = static_cast<const uint8*>(indexed8Data);
	uint32* dst = static_cast<uint32*>(dest);
	for (int i = 0; i < count; i++)
	{
		*dst++ = pal[*src++];
	}	
}

bool quantize(const void* data, int colorCount, int width, int height, void* dest, void* palette)
{
	liq_attr *attr = liq_attr_create();
	
	if (attr == NULL)
	{
		DLOG << "Unable to create liq attr";
		return false;
	}

	if (liq_set_max_colors(attr, colorCount) != LIQ_OK)
	{
		DLOG << "Unable to set liq max colors";
		liq_attr_destroy(attr);
		return false;
	}

	liq_image *image = liq_image_create_rgba(attr, const_cast<void*>(data), width, height, 0);
	
	if (image == NULL)
	{
		DLOG << "Unable to create liq image";
		liq_attr_destroy(attr);
		return false;
	}

	liq_result *res = liq_quantize_image(attr, image);

	if (res == NULL)
	{
		DLOG << "Unable to quantize image";
		liq_attr_destroy(attr);
		liq_image_destroy(image);
		return false;
	}

	if (liq_set_dithering_level(res, 0.1f) != LIQ_OK)
	{
		DLOG << "Dithering error!";
		liq_attr_destroy(attr);
		liq_image_destroy(image);
		liq_result_destroy(res);
		return false;
	}

	if (liq_write_remapped_image(res, image, dest, width * height) != LIQ_OK)
	{
		DLOG << "Unable to write liq remapped image";
		liq_attr_destroy(attr);
		liq_image_destroy(image);
		liq_result_destroy(res);
		return false;
	}

	const liq_palette *pal = liq_get_palette(res);
	if (pal == NULL)
	{
		DLOG << "Unable to get liq palette";
		liq_attr_destroy(attr);
		liq_image_destroy(image);
		liq_result_destroy(res);
		return false;
	}

	RGBA* c = static_cast<RGBA*>(palette);
	for (int i = 0; i < colorCount; i++)
	{
		c->r = pal->entries[i].r;
		c->g = pal->entries[i].g;
		c->b = pal->entries[i].b;
		c->a = pal->entries[i].a;
		c++;
	}
	//memcpy(palette, pal, 4 * colorCount);

	liq_attr_destroy(attr);
	liq_image_destroy(image);
	liq_result_destroy(res);

	return true;
}

bool quantize8(const void* data, int width, int height, void* dest, void* palette)
{
	return quantize(data, 256, width, height, dest, palette);
}

bool quantize4(const void* data, int width, int height, void* dest, void* palette)
{
	std::vector<uint8> buffer(width * height);
	
	if (!quantize(data, 16, width, height, &buffer[0], palette))
	{
		return false;
	}

	const uint8* src = &buffer[0];
	uint8* dst = static_cast<uint8*>(dest);

	const int rasterSize = (width * height) / 2;
	for (int i = 0; i < rasterSize; i++)
	{
		const uint8 c1 = *src++;
		const uint8 c2 = *src++;
		ASSERT(c1 < 16 && c2 < 16);
		*dst++ = (c1 & 0xF) | (c2 << 4);
	}

	return true;
}

void floydSteinberg(void* image, int width, int height, int rBits, int gBits, int bBits, int aBits)
{
	nv::Image nvImage;
	nvImage.wrap(image, width, height);
	nv::Quantize::FloydSteinberg(&nvImage, rBits, gBits, bBits, aBits);
	nvImage.unwrap();
}