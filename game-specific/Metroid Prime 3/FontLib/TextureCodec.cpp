#include "TextureCodec.h"

namespace Consolgames
{

inline Rgb makeRgb(int r, int g, int b)
{
	return (0xffu << 24) | ((r & 0xff) << 16) | ((g & 0xff) << 8) | (b & 0xff);
}

Rgb TextureCodec::decodeColor(quint16 color)
{
	// Big or little endian?
	color = (color >> 8) | (color << 8);

	const double rbCoef = 255.0 / 31.0;
	const double gCoef = 255.0 / 63.0;

	const double r = (color >> 11);
	const double g = ((color >> 5) & 0x3F);
	const double b = (color & 0x1F);
	return makeRgb(r * rbCoef + 0.5, g * gCoef + 0.5, b * rbCoef + 0.5);
}

void TextureCodec::decodeImage2bpp(const void* src, void* dest, int width, int height, int layerIndex)
{
	const quint8* s = static_cast<const quint8*>(src);
	quint8* d = static_cast<quint8*>(dest);

	for (int j = 0; j < height; j += 8)
	{
		for (int i = 0; i < width; i += 8)
		{
			for (int n = 0; n < 8; n++)
			{
				for (int k = 0; k < 8; k += 2)
				{
					const int p0i = (j + n) * width + i + k + 1;
					const int p1i = (j + n) * width + i + k + 0;
					if (layerIndex == 0)
					{
						d[p0i] = *s & 3;
						d[p1i] = (*s >> 4) & 3;
					}
					else
					{
						d[p0i] = (*s >> 2) & 3;
						d[p1i] = (*s >> 6) & 3;
					}
					s++;
				}
			}
		}
	}
}

void TextureCodec::decodeImage1bpp(const void* src, void* dest, int width, int height, int layerIndex)
{
	const quint8* const s = static_cast<const quint8*>(src);
	quint8* d = static_cast<quint8*>(dest);

	for (int j = 0; j < height; j += 8)
	{
		for (int i = 0; i < width; j += 8)
		{
			for (int n = 0; n < 8; n++)
			{
				for (int k = 0; k < 8; k++)
				{
					const int p0i = (j + n) * width + i + k + 1;
					const int p1i = (j + n) * width + i + k + 0;

					if (layerIndex == 0)
					{
						d[p0i] = *s & 1;
						d[p1i] = (*s >> 4) & 1;
					}
					else if (layerIndex == 1)
					{
						d[p0i] = (*s >> 1) & 1;
						d[p1i] = (*s >> 5) & 1;
					}
					else if (layerIndex == 2)
					{
						d[p0i] = (*s >> 2) & 1;
						d[p1i] = (*s >> 6) & 1;
					}
					else if (layerIndex == 3)
					{
						d[p0i] = (*s >> 3) & 1;
						d[p1i] = (*s >> 7) & 1;
					}
				}
			}
		}
	}
}

void TextureCodec::encodeImage2bpp(const void* src, void* dest, int width, int height, int layerIndex)
{
	const quint8* const s = static_cast<const quint8*>(src);
	quint8* d = static_cast<quint8*>(dest);

	for (int j = 0; j < height; j += 8)
	{
		for (int i = 0; i < width; i += 8)
		{
			for (int n = 0; n < 8; n++)
			{
				for (int k = 0; k < 8; k += 2)
				{
					const int p0i = (j + n) * width + i + k + 1;
					const int p1i = (j + n) * width + i + k + 0;
					if (layerIndex == 0)
					{
						*d |= s[p0i] & 3;
						*d |= (s[p1i] & 3) << 4;
					}
					else
					{
						*d |= (s[p0i] & 3) << 2;
						*d |= (s[p1i] & 3) << 6;
					}
					d++;
				}
			}
		}
	}
}

void TextureCodec::encodeImage1bpp(const void* src, void* dest, int width, int height, int layerIndex)
{
	const quint8* const s = static_cast<const quint8*>(src);
	quint8* d = static_cast<quint8*>(dest);

	for (int j = 0; j < height; j += 8)
	{
		for (int i = 0; i < width; i += 8)
		{
			for (int n = 0; n < 8; n++)
			{
				for (int k = 0; k < 8; k += 2)
				{
					const int p0i = (j + n) * width + i + k + 1;
					const int p1i = (j + n) * width + i + k + 0;
					if (layerIndex == 0)
					{
						*d = s[p0i] & 1;
						*d = (s[p1i] & 1) << 4;
					}
					else if (layerIndex == 1)
					{
						*d = (s[p0i] & 1) << 1;
						*d = (s[p1i] & 1) << 5;
					}
					else if (layerIndex == 2)
					{
						*d = (s[p0i] & 1) << 2;
						*d = (s[p1i] & 1) << 6;
					}
					else if (layerIndex == 3)
					{
						*d = (s[p0i] & 1) << 3;
						*d = (s[p1i] & 1) << 7;
					}
					d++;
				}
			}
		}
	}
}

}