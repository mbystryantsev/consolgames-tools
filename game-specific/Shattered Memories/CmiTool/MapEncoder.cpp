#include "MapEncoder.h"
#include "MapCommon.h"
#include <libimagequant.h>
#include <vector>

namespace Origins
{

namespace
{
#pragma pack(push, 1)
struct RGBA
{
	uint8_t r, g, b, a;
};
#pragma pack(pop)
}

bool MapEncoder::quantize(const void* pixels, int width, int height, void* result, uint32_t* palette, bool indexed8)
{
	liq_attr *attr = liq_attr_create();
	if (attr == NULL)
	{
		return false;
	}

	liq_set_max_colors(attr, 16);

	liq_image *image = liq_image_create_rgba(attr, const_cast<void*>(pixels), width, height, 0);
	if (image == NULL)
	{
		return false;
	}

	liq_result *res = liq_quantize_image(attr, image);

	if (res == NULL)
	{
		return false;
	}

	const liq_palette *pal = liq_get_palette(res);
	RGBA* c = reinterpret_cast<RGBA*>(palette);
	for (int i = 0; i < 16; i++)
	{
		c->r = pal->entries[i].r;
		c->g = pal->entries[i].g;
		c->b = pal->entries[i].b;
		c->a = pal->entries[i].a;
		c++;
	}


	if (indexed8)
	{
		liq_write_remapped_image(res, image, result, width * height);
	}
	else
	{
		std::vector<uint8_t> indexedImage(width * height);
		liq_write_remapped_image(res, image, &indexedImage[0], width * height);
		indexed8ToIndexed4(&indexedImage[0], result, width * height);
	}

	liq_attr_destroy(attr);
	liq_image_destroy(image);
	liq_result_destroy(res);

	return true;
}

bool MapEncoder::encodeBG(const void* pixels, void* result, uint32_t* palette)
{
	std::vector<uint8_t> data(c_bgWidthHeight * c_bgWidthHeight / 2);
	if (!quantize(pixels, c_bgWidthHeight, c_bgWidthHeight, &data[0], palette))
	{
		return false;
	}

	swizzle4(&data[0], result, c_bgWidthHeight, c_bgWidthHeight);
	return true;
}

}