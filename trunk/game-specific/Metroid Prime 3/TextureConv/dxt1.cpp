#include "dxt1.h"
#include <BlockDXT.h>
#include <ColorBlock.h>
#include <Filter.h>
#include <Image.h>
#include <FloatImage.h>
#include <QuickCompressDXT.h>
#include <memory>
#include <iostream>
#include <fstream>

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

void DXTCodec::deswizzleImage(void* src, void* dest, int width, int height)
{
	nv::Color32* image = static_cast<nv::Color32*>(dest);
	nv::ColorBlock* rgba = static_cast<nv::ColorBlock*>(src);

	for (int i = 0; i < height / 4; i++)
	{
		for (int j = 0; j < width / 8; j++)
		{
			//for(int k = 0; k < 2; k++)
			{
				copy(&rgba->colors()[0], &image[(i*4+0)*width+j*8], 32);
				copy(&rgba->colors()[8], &image[(i*4+1)*width+j*8], 32);
				rgba++;
				copy(&rgba->colors()[0], &image[(i*4+2)*width+j*8], 32);
				copy(&rgba->colors()[8], &image[(i*4+3)*width+j*8], 32);
				rgba++;
			}
		}
	}
	flipImage(dest, width, height);
}

#define img_pos(line) (i * 8 + line + (k > 1) * 4) * width + j * 8 + (k % 2) * 4 //  + key

void DXTCodec::decodeDXT1(void* src, void* dest, int width, int height)
{
	int a = 0;

	std::ofstream file("D:\\rev\\corruption\\txtr\\dxt", std::ofstream::out | std::ofstream::binary);
	
	nv::Color32* imageData = static_cast<nv::Color32*>(dest);
	const nv::BlockDXT1* blocks = static_cast<nv::BlockDXT1*>(src);
	std::fill(imageData, imageData + width * height, nv::Color32(0xFF, 0, 0, 0xFF));

	for (int i = 0; i < height / 8; i++)
	{
		for (int j = 0; j < width / 8; j++)
		{
			for (int k = 0; k < 4; k++)
			{
				nv::BlockDXT1 blockDXT = blocks[a];
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
				file.write((char*)&blockDXT, sizeof(blockDXT));

				nv::ColorBlock rgba;
				blockDXT.decodeBlock(&rgba);
				for (int n = 0; n < 16; n++)
				{
					rgba.color(n).u = ((rgba.colors()[n].u >> 16) & 0xFF) | ((rgba.colors()[n].u << 16) & 0xFF0000) | (rgba.colors()[n].u & 0xFF00FF00);
				}
				copy(&rgba.color(0),  &imageData[img_pos(0)], 4);
				copy(&rgba.color(4),  &imageData[img_pos(1)], 4);
				copy(&rgba.color(8),  &imageData[img_pos(2)], 4);
				copy(&rgba.color(12), &imageData[img_pos(3)], 4);
				a++;
			}
		}
	}
	flipImage(dest, width, height);
}

void DXTCodec::decodeDXT3(void* src, void* dest, int width, int height)
{
	int a = 0;
	nv::Color32 *img = (nv::Color32*)dest;
	nv::BlockDXT3 *blocks = (nv::BlockDXT3*)src, block_dxt;
	nv::ColorBlock rgba;

	for(int i = 0; i < height / 8; i++)
	{
		for(int j = 0; j < width / 8; j++)
		{
			for(int k = 0; k < 4; k++)
			{
				block_dxt = blocks[a];
				block_dxt.color.col1.u = (block_dxt.color.col1.u << 8) | (block_dxt.color.col1.u >> 8);
				block_dxt.color.col0.u = (block_dxt.color.col0.u << 8) | (block_dxt.color.col0.u >> 8);

				for(int n = 0; n < 4; n++) block_dxt.alpha.row[n] =
					(block_dxt.alpha.row[n] << 6) | ((block_dxt.alpha.row[n] << 2) & 0x30) |
					((block_dxt.alpha.row[n] >> 2) & 0x0C) | (block_dxt.alpha.row[n] >> 6);
					//block_dxt.flip4();
				block_dxt.decodeBlock(&rgba);
				for(int n = 0; n < 16; n++)
				{
					((nv::Color32*)rgba.colors())[n].u = ((rgba.colors()[n].u >> 16) & 0xFF) | ((rgba.colors()[n].u << 16) & 0xFF0000) | (rgba.colors()[n].u & 0xFF00FF00);
					//n = n + 0;
				}
				copy(&rgba.colors()[0],  &img[img_pos(0)], 4);
				copy(&rgba.colors()[4],  &img[img_pos(1)], 4);
				copy(&rgba.colors()[8],  &img[img_pos(2)], 4);
				copy(&rgba.colors()[12], &img[img_pos(3)], 4);
				a++;
			}
		}
	}
	flipImage(dest, width, height);
}

int DXTCodec::encodeDXT1(void* src, void* dest, int width, int height)
{
	int a = 0;
	nv::Color32* imageData = static_cast<nv::Color32*>(malloc(width * height * sizeof(nv::Color32)));
	copy(static_cast<const nv::Color32*>(src), imageData, width * height);
	flipImage(imageData, width, height);

	nv::BlockDXT1 *blocks = (nv::BlockDXT1*)dest, block_dxt;
	nv::ColorBlock rgba;

	for (int i = 0; i < height / 8; i++)
	{
		for (int j = 0; j < width / 8; j++)
		{
			//k = 0;
			for (int k = 0; k < 4; k++)
			{
				copy(&rgba.colors()[0],  &imageData[img_pos(0)], 4);
				copy(&rgba.colors()[4],  &imageData[img_pos(1)], 4);
				copy(&rgba.colors()[8],  &imageData[img_pos(2)], 4);
				copy(&rgba.colors()[12], &imageData[img_pos(3)], 4);
#if 0
				for(int n = 0; n < 16; n++)
				{
					((nv::Color32*)rgba.colors())[n].u = ((rgba.colors()[n].u >> 16) & 0xFF) | ((rgba.colors()[n].u << 16) & 0xFF0000) | (rgba.colors()[n].u & 0xFF00FF00););
				}
#endif

				nv::QuickCompress::compressDXT1a(rgba, &block_dxt);
				//nv::OptimalCompress::compressDXT1a(rgba, &block_dxt);

				block_dxt.col1.u = (block_dxt.col1.u << 8) | (block_dxt.col1.u >> 8);
				block_dxt.col0.u = (block_dxt.col0.u << 8) | (block_dxt.col0.u >> 8);

				for(int n = 0; n < 4; n++) block_dxt.row[n] =
					(block_dxt.row[n] << 6) | ((block_dxt.row[n] << 2) & 0x30) |
					((block_dxt.row[n] >> 2) & 0x0C) | (block_dxt.row[n] >> 6);
					//block_dxt.flip4();

				blocks[a] = block_dxt;
				a++;
			}
		}
	}
	free(imageData);
	return (width * height) / 2;
}
#undef img_pos

int DXTCodec::encodeDXT1(void* src, void* dest, int width, int height, int mipmaps, int minWidth, int maxHeight)
{
    unsigned char* destByte = static_cast<unsigned char*>(dest);
    nv::BoxFilter filter;
	std::auto_ptr<nv::Image> image(new nv::Image());
    int size = 0;

	image->allocate(width, height);

    while (mipmaps > 0)
    {
        int currentWidth = nv::max(width, minWidth);
        int currentHeight = nv::max(height, maxHeight);
		encodeDXT1(image->pixels(), destByte, currentWidth, currentHeight);
		size += currentWidth * currentHeight / 2;
		mipmaps--;

        if (mipmaps == 0)
		{
			break;
		}

		destByte += currentWidth * currentHeight / 2;
		width /= 2;
		height /= 2;

		nv::FloatImage floatImage(image.get());
		std::auto_ptr<nv::FloatImage> resizedFloatImage(floatImage.resize(filter, width, height, nv::FloatImage::WrapMode_Mirror));
		std::auto_ptr<nv::Image> resultImage(resizedFloatImage->createImage());
        
		if (width < minWidth || height < maxHeight)
        {
            currentWidth = nv::max(width, minWidth);
            currentHeight = nv::max(height, maxHeight);

            image->allocate(currentWidth, currentHeight);
            const nv::Color32 white(0xFF, 0xFF, 0xFF);

            for(int y = 0; y < currentHeight; y++)
            {
                nv::Color32* src_p = y < height ? resultImage->scanline(y) : NULL;
                nv::Color32* dst_p = image->scanline(y);
                for(int x = 0; x < currentWidth; x++)
                {
                    if (x >= width || y >= height)
                    {
                        *dst_p++ = white;
                    }
                    else
                    {
                        *dst_p++ = *src_p++;
                    }
                }
            }
            resultImage.reset();
        }
        else
        {
            image.reset(resultImage.release());
        }
	}

    return size;
}

int DXTCodec::convert8bppaToGray(const void* inData, void* outData, int width, int height)
{
	nv::Color32 *color = static_cast<nv::Color32*>(outData);
	const unsigned char* c = static_cast<const unsigned char*>(inData);
	for(int i = 0; i < width * height; i++)
	{
		color->a = *c++;
		color->r = color->g = color->b = *c++;
		color++;
	}
	return 0;
}
