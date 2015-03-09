#pragma once
#include <core.h>

#pragma pack(push, 1)
struct RGBA
{
	uint8 r, g, b, a;
};
#pragma pack(pop)

template <int bits>
static inline double colorCeil()
{
	return (1 << bits) - 1;
}

template <int bits>
static inline uint8 expandColorTo32(uint8 color)
{
	const double normalized = static_cast<double>(color) / colorCeil<bits>();
	return static_cast<uint8>(normalized * 255.0 + 0.5);
}

template <int bits>
static inline uint8 collapseColor32(uint8 color)
{
	const double normalized = static_cast<double>(color) / 255.0;
	return static_cast<uint8>(normalized * colorCeil<bits>() + 0.5);
}

typedef struct liq_attr liq_attr;
typedef struct liq_result liq_result;
typedef struct liq_image liq_image;

class Quantizer
{
public:
	Quantizer();
	~Quantizer();

	bool quantize(const void* data, int colorCount, int width, int height, void* dest, void* palette);
	bool remapAdditionalImage(const void* data, int width, int height, void* dest);
	void finalize();

private:
	bool remap(liq_image* image, int width, int height, void* dest);

private:
	liq_attr* m_attr;
	liq_result* m_result;
	int m_colorCount;
};

void convertIndexed4ToRGBA(const void* indexed4Data, int count, const void* palette, void* dest);
void convertIndexed8ToRGBA(const void* indexed8Data, int count, const void* palette, void* dest);
void indexed8to4(const void* source, void* dest, int count);
void floydSteinberg(void* image, int width, int height, int rBits, int gBits, int bBits, int aBits);
