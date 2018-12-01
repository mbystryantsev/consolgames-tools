#include "Quantize.h"
#include <libimagequant.h>
#include <nvimage/Quantize.h>
#include <nvimage/Image.h>
#include <vector>

void convertIndexed4ToRGBA(const void* indexed4Data, int count, const void* palette, void* dest)
{
	const uint32_t* pal = static_cast<const uint32_t*>(palette);

	const uint8_t* src = static_cast<const uint8_t*>(indexed4Data);
	uint32_t* dst = static_cast<uint32_t*>(dest);
	for (int i = 0; i < count; i += 2)
	{
		*dst++ = pal[*src & 0xF];
		*dst++ = pal[*src >> 4];
		src++;
	}	
}

void convertIndexed8ToRGBA(const void* indexed8Data, int count, const void* palette, void* dest)
{
	const uint32_t* pal = static_cast<const uint32_t*>(palette);

	const uint8_t* src = static_cast<const uint8_t*>(indexed8Data);
	uint32_t* dst = static_cast<uint32_t*>(dest);
	for (int i = 0; i < count; i++)
	{
		*dst++ = pal[*src++];
	}	
}

void indexed8to4(const void* source, void* dest, int count)
{
	const uint8_t* src = static_cast<const uint8_t*>(source);
	uint8_t* dst = static_cast<uint8_t*>(dest);

	const int rasterSize = count / 2;
	for (int i = 0; i < rasterSize; i++)
	{
		const uint8_t c1 = *src++;
		const uint8_t c2 = *src++;
		ASSERT(c1 < 16 && c2 < 16);
		*dst++ = (c1 & 0xF) | (c2 << 4);
	}
}

void floydSteinberg(void* image, int width, int height, int rBits, int gBits, int bBits, int aBits)
{
	nv::Image nvImage;
	nvImage.wrap(image, width, height);
	nv::Quantize::FloydSteinberg(&nvImage, rBits, gBits, bBits, aBits);
	nvImage.unwrap();
}

//////////////////////////////////////////////


Quantizer::Quantizer()
	: m_attr(NULL)
	, m_result(NULL)
	, m_colorCount(0)
{
}

Quantizer::~Quantizer()
{
	finalize();
}

bool Quantizer::quantize(const void* data, int colorCount, int width, int height, void* dest, void* palette)
{
	finalize();

	m_colorCount = colorCount;
	m_attr = liq_attr_create();
	
	if (m_attr == NULL)
	{
		DLOG << "Unable to create liq attr";
		return false;
	}

	if (liq_set_max_colors(m_attr, colorCount) != LIQ_OK)
	{
		DLOG << "Unable to set liq max colors";
		return false;
	}

	liq_image *image = liq_image_create_rgba(m_attr, const_cast<void*>(data), width, height, 0);
	
	if (image == NULL)
	{
		DLOG << "Unable to create liq image";
		return false;
	}

	m_result = liq_quantize_image(m_attr, image);

	if (m_result == NULL)
	{
		DLOG << "Unable to quantize image";
		liq_image_destroy(image);
		return false;
	}

	if (liq_set_dithering_level(m_result, 0.1f) != LIQ_OK)
	{
		DLOG << "Dithering error!";
		liq_image_destroy(image);
		return false;
	}

	const bool result = remap(image, width, height, dest);

	liq_image_destroy(image);

	if (!result)
	{
		return false;
	}

	const liq_palette* pal = liq_get_palette(m_result);
	if (pal == NULL)
	{
		DLOG << "Unable to get liq palette";
		return false;
	}

	RGBA* c = static_cast<RGBA*>(palette);
	for (int i = 0; i < m_colorCount ; i++)
	{
		c->r = pal->entries[i].r;
		c->g = pal->entries[i].g;
		c->b = pal->entries[i].b;
		c->a = pal->entries[i].a;
		c++;
	}

	return true;
}

bool Quantizer::remapAdditionalImage(const void* data, int width, int height, void* dest)
{
	if (m_result == NULL || m_attr == NULL)
	{
		return false;
	}

	liq_image *image = liq_image_create_rgba(m_attr, const_cast<void*>(data), width, height, 0);
	
	if (image == NULL)
	{
		DLOG << "Unable to create liq image";
		return false;
	}

	const bool result = remap(image, width, height, dest);
	
	liq_image_destroy(image);

	return result;
}

void Quantizer::finalize()
{
	if (m_result != NULL)
	{
		liq_result_destroy(m_result);
		m_result = NULL;
	}

	if (m_attr)
	{
		liq_attr_destroy(m_attr);
		m_attr = NULL;
	}

	m_colorCount = 0;
}

bool Quantizer::remap(liq_image* image, int width, int height, void* dest)
{
	if (liq_write_remapped_image(m_result, image, dest, width * height) != LIQ_OK)
	{
		DLOG << "Unable to write liq remapped image";
		return false;
	}

	return true;
}