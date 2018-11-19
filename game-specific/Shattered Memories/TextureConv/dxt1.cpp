#include "dxt1.h"
#include <BlockDXT.h>
#include <ColorBlock.h>
#include <Filter.h>
#include <Image.h>
#include <FloatImage.h>
#include <OptimalCompressDXT.h>
#include <QuickCompressDXT.h>
#include <squish/colourset.h>
#include <squish/fastclusterfit.h>
#include <squish/weightedclusterfit.h>

#include <memory>
#include <iostream>
#include <fstream>

const int DXTCodec::s_minMipmapSide = 8;

template <typename T, typename DT>
static inline void copy(const T src, DT dest, int count)
{
	std::copy(src, src + count, dest);
}

void DXTCodec::flipImage(void* data, int w, int h)
{
	nv::Color32* src = static_cast<nv::Color32*>(data);
	nv::Color32* colors = new nv::Color32[w];
	for(int i = 0; i < h / 2; i++)
	{
		copy(&src[i * w], colors, w);
		copy(&src[(h - i - 1) * w], &src[i * w], w);
		copy(colors, &src[(h - i - 1) * w], w);
	}
	delete []colors;
}

#define img_pos(line) (i * 8 + line + (k > 1) * 4) * width + j * 8 + (k % 2) * 4 //  + key

static inline nv::BlockDXT1 swizzleBlock(const nv::BlockDXT1& block)
{
	nv::BlockDXT1 blockDXT = block;
	blockDXT.col1.u = (blockDXT.col1.u << 8) | (blockDXT.col1.u >> 8);
	blockDXT.col0.u = (blockDXT.col0.u << 8) | (blockDXT.col0.u >> 8);

	for (int n = 0; n < 4; n++)
	{
		blockDXT.row[n] =
			(blockDXT.row[n] << 6)
			| ((blockDXT.row[n] << 2) & 0x30)
			| ((blockDXT.row[n] >> 2) & 0x0C)
			| (blockDXT.row[n] >> 6);	
	}

	return blockDXT;
}

void DXTCodec::decodeDXT1(const void* src, void* dest, int width, int height)
{
	nv::Color32* imageData = static_cast<nv::Color32*>(dest);
	const nv::BlockDXT1* blocks = static_cast<const nv::BlockDXT1*>(src);
	std::fill(imageData, imageData + width * height, nv::Color32(0xFF, 0, 0, 0xFF));


	int blockIndex = 0;
	for (int i = 0; i < height / 8; i++)
	{
		for (int j = 0; j < width / 8; j++)
		{
			for (int k = 0; k < 4; k++)
			{
				nv::BlockDXT1 blockDXT = swizzleBlock(blocks[blockIndex]);

				nv::ColorBlock rgba;
				blockDXT.decodeBlock(&rgba);
				copy(&rgba.color(0),  &imageData[img_pos(0)], 4);
				copy(&rgba.color(4),  &imageData[img_pos(1)], 4);
				copy(&rgba.color(8),  &imageData[img_pos(2)], 4);
				copy(&rgba.color(12), &imageData[img_pos(3)], 4);
				blockIndex++;
			}
		}
	}
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

static void copyRect(const nv::Image& src, nv::Image& dest, const Rect& sourceRect, int destX, int destY)
{
	for (int line = 0; line < sourceRect.height; line++)
	{
		const nv::Color32* srcPixels = src.scanline(sourceRect.y + line) + sourceRect.x;
		nv::Color32* destPixels = dest.scanline(destY + line) + destX;
		copy(srcPixels, destPixels, sourceRect.width);
	}
}

void DXTCodec::decodeDXT1(const void* src, void* dest, int width, int height, int mipmaps)
{
	if (mipmaps == 1)
	{
		return decodeDXT1(src, dest, width, height);
	}

	const int resultWidth = width + width / 2;
	const int resultHeight = height;
	nv::Image resultImage;
	resultImage.allocate(resultWidth, resultHeight);
	resultImage.fill(nv::Color32(0));

	int destX = 0;
	int destY = 0;

	const uint8* bytes = static_cast<const uint8*>(src);
	for (int i = 0; i < mipmaps; i++)
	{
		const int mipmapWidth = std::max(width, s_minMipmapSide);
		const int mipmapHeight = std::max(height, s_minMipmapSide);
		decodeDXT1(bytes, dest, mipmapWidth, mipmapHeight);

		nv::Image image;
		image.wrap(dest, mipmapWidth, mipmapHeight);
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

		bytes += (mipmapWidth * mipmapHeight / 2);
		width /= 2;
		height /= 2;
	}

	copy(resultImage.pixels(), reinterpret_cast<nv::Color32*>(dest), resultWidth * resultHeight);
}

int DXTCodec::encodeDXT1(const void* src, void* dest, int width, int height)
{
	const nv::Color32* imageData = static_cast<const nv::Color32*>(src);
	nv::BlockDXT1* blocks = static_cast<nv::BlockDXT1*>(dest);

	squish::WeightedClusterFit fit;
	fit.SetMetric(1.0, 1.0, 1.0);

	int blockIndex = 0;
	for (int i = 0; i < height / 8; i++)
	{
		for (int j = 0; j < width / 8; j++)
		{
			for (int k = 0; k < 4; k++)
			{
				nv::ColorBlock rgba;
				copy(&imageData[img_pos(0)], &rgba.color(0), 4);
				copy(&imageData[img_pos(1)], &rgba.color(4), 4);
				copy(&imageData[img_pos(2)], &rgba.color(8), 4);
				copy(&imageData[img_pos(3)], &rgba.color(12), 4);

				nv::BlockDXT1 block;
				if (rgba.isSingleColor())
				{
					nv::OptimalCompress::compressDXT1(rgba.color(0), &block);
				}
				else
				{
					squish::ColourSet colours(reinterpret_cast<const uint8*>(rgba.colors()), 0, true);
					fit.SetColourSet(&colours, squish::kDxt1);
					fit.Compress(&block);
				}
				blocks[blockIndex] = swizzleBlock(block);
				blockIndex++;
			}
		}
	}

	return (width * height) / 2;
}
#undef img_pos

int DXTCodec::encodeDXT1(const void* src, void* dest, int width, int height, int mipmaps)
{
	if (mipmaps == 1)
	{
		return encodeDXT1(src, dest, width, height);
	}

    unsigned char* destBytes = static_cast<unsigned char*>(dest);
    nv::BoxFilter filter;
	
	std::unique_ptr<nv::Image> image(new nv::Image());
	image->allocate(width, height);
	const nv::Color32* colors = static_cast<const nv::Color32*>(src);
	for (uint line = 0; line < image->height(); line++)
	{
		copy(colors, image->scanline(line), width);
		colors += width;
	}

    int totalSize = 0;
    for (int i = 0; i < mipmaps; i++)
    {
        const int mipmapWidth = nv::max(width, s_minMipmapSide);
        const int mipmapHeight = nv::max(height, s_minMipmapSide);
		int mipmapDataSize = 0;
		if (width < s_minMipmapSide || height < s_minMipmapSide)
		{
			std::unique_ptr<nv::Image> canvas(new nv::Image());
			canvas->allocate(mipmapWidth, mipmapHeight);
			canvas->fill(nv::Color32(255, 255, 255));
			copyRect(*image.get(), *canvas.get(), Rect(0, 0, width, height), 0, 0);
			mipmapDataSize = encodeDXT1(canvas->pixels(), destBytes, mipmapWidth, mipmapHeight);
		}
		else
		{
			mipmapDataSize = encodeDXT1(image->pixels(), destBytes, mipmapWidth, mipmapHeight);
		}
		
		destBytes += mipmapDataSize;
		totalSize += mipmapDataSize;

        if (i == mipmaps - 1)
		{
			break;
		}

		width /= 2;
		height /= 2;

		nv::FloatImage floatImage(image.get());
		std::unique_ptr<nv::FloatImage> resizedFloatImage(floatImage.resize(filter, width, height, nv::FloatImage::WrapMode_Mirror));   
		image.reset(resizedFloatImage->createImage());
	}

    return totalSize;
}
