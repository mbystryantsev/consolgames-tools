#include <nvimage/BlockDXT.h>
#include <nvimage/ColorBlock.h>
#include <nvimage/Filter.h>
#include <nvimage/Image.h>
#include <nvimage/FloatImage.h>
#include <nvtt/nvtt.h>
#include <nvtt/QuickCompressDXT.h>

inline void swap(uint16& a, uint16& b){
  uint16 t = a;
  a = b;
  b = t;
}

void flip_image(void* data, int w, int h)
{
	nv::Color32 *src = (nv::Color32*)data, *colors = new nv::Color32[w];
	for(int i = 0; i < h / 2; i++)
	{
		memcpy(colors, &src[i*w], w * sizeof(nv::Color32));
		memcpy(&src[i*w], &src[(h-i-1)*w], w * sizeof(nv::Color32));
		memcpy(&src[(h-i-1)*w], colors, w * sizeof(nv::Color32));
	}
	delete []colors;
}

#define img_pos(X) (i * 8 + X + (k > 1) * 4) * width + j * 8 + (k & 1) * 4 //  + key
//#define i_pos(X)   (i * 8 + X + (k > 1) * 4) * width + j * 8 + (k & 1) * 4 //  + key

void DeswizzleImage(void* src, void* dest, int width, int height)
{
	int *img = (int*)dest;
	nv::ColorBlock *rgba = (nv::ColorBlock*)src;

	for(int i = 0; i < height / 4; i++)
	{
		for(int j = 0; j < width / 8; j++)
		{
			//for(int k = 0; k < 2; k++)
			{
				memcpy(&img[(i*4+0)*width+j*8], &rgba->colors()[0],  32);
				memcpy(&img[(i*4+1)*width+j*8], &rgba->colors()[8],  32);
				rgba++;
				memcpy(&img[(i*4+2)*width+j*8], &rgba->colors()[0], 32);
				memcpy(&img[(i*4+3)*width+j*8], &rgba->colors()[8], 32);
				rgba++;
			}
		}
	}
	flip_image(dest, width, height);
}


void DecodeDXT1(void* src, void* dest, int width, int height)
{
	int a = 0, *img = (int*)dest;
	nv::BlockDXT1 *blocks = (nv::BlockDXT1*)src, block_dxt;
	nv::ColorBlock rgba;

	for(int i = 0; i < height / 8; i++)
	{
		for(int j = 0; j < width / 8; j++)
		{
			//k = 0;
			for(int k = 0; k < 4; k++)
			{
				block_dxt = blocks[a];
				block_dxt.col1.u = (block_dxt.col1.u << 8) | (block_dxt.col1.u >> 8);
				block_dxt.col0.u = (block_dxt.col0.u << 8) | (block_dxt.col0.u >> 8);

				for(int n = 0; n < 4; n++) block_dxt.row[n] =
					(block_dxt.row[n] << 6) | ((block_dxt.row[n] << 2) & 0x30) |
					((block_dxt.row[n] >> 2) & 0x0C) | (block_dxt.row[n] >> 6);
					//block_dxt.flip4();
				block_dxt.decodeBlock(&rgba);
				for(int n = 0; n < 16; n++)
				{
					((nv::Color32*)rgba.colors())[n].u = ((rgba.colors()[n].u >> 16) & 0xFF) | ((rgba.colors()[n].u << 16) & 0xFF0000) | (rgba.colors()[n].u & 0xFF00FF00);
					//n = n + 0;
				}
				memcpy(&img[img_pos(0)], &rgba.colors()[0],  16);
				memcpy(&img[img_pos(1)], &rgba.colors()[4],  16);
				memcpy(&img[img_pos(2)], &rgba.colors()[8],  16);
				memcpy(&img[img_pos(3)], &rgba.colors()[12], 16);
				a++;
			}
		}
	}
	flip_image(dest, width, height);
}

void DecodeDXT3(void* src, void* dest, int width, int height)
{
	int a = 0;
	nv::Color32 *img = (nv::Color32*)dest;
	nv::BlockDXT3 *blocks = (nv::BlockDXT3*)src, block_dxt;
	nv::ColorBlock rgba;

	for(int i = 0; i < height / 8; i++)
	{
		for(int j = 0; j < width / 8; j++)
		{
			//k = 0;
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
				memcpy(&img[img_pos(0)], &rgba.colors()[0],  16);
				memcpy(&img[img_pos(1)], &rgba.colors()[4],  16);
				memcpy(&img[img_pos(2)], &rgba.colors()[8],  16);
				memcpy(&img[img_pos(3)], &rgba.colors()[12], 16);
				a++;
			}
		}
	}
	flip_image(dest, width, height);
}

int EncodeDXT1(void* src, void* dest, int width, int height)
{	int a = 0;
	nv::Color32 *img = (nv::Color32*)malloc(width * height * sizeof(nv::Color32));
	memcpy(img, src, width * height * sizeof(nv::Color32));
	flip_image(img, width, height);

	nv::BlockDXT1 *blocks = (nv::BlockDXT1*)dest, block_dxt;
	nv::ColorBlock rgba;

	for(int i = 0; i < height / 8; i++)
	{
		for(int j = 0; j < width / 8; j++)
		{
			//k = 0;
			for(int k = 0; k < 4; k++)
			{
				memcpy((void*)&rgba.colors()[0],  &img[img_pos(0)], 16);
				memcpy((void*)&rgba.colors()[4],  &img[img_pos(1)], 16);
				memcpy((void*)&rgba.colors()[8],  &img[img_pos(2)], 16);
				memcpy((void*)&rgba.colors()[12], &img[img_pos(3)], 16);
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
	free(img);
	return (width * height) / 2;
}
#undef img_pos

int EncodeDXT1(void* src, void* dest, int width, int height, int mipmaps, int min_width, int min_height)
{
    //using namespace nv;
    unsigned char *d = (unsigned char*)dest;
    nv::BoxFilter filter;
    nv::Image *image = new nv::Image();
    int size = 0;

	image->allocate(width, height);
    memcpy(image->pixels(), src, width * height * sizeof(nv::Color32));
    while(mipmaps > 0)
    {
        int w = nv::max(width, min_width);
        int h = nv::max(height, min_height);
		EncodeDXT1(image->pixels(), d, w, h);
		size += w * h / 2;
		mipmaps--;

        if(mipmaps == 0) break;

		d += w * h / 2;
		width /= 2;
		height /= 2;

        nv::FloatImage* fimg = new nv::FloatImage(image);
        nv::FloatImage* new_fimg = fimg->resize(filter, width, height, nv::FloatImage::WrapMode_Mirror);
        delete fimg;
        nv::Image* new_image = new_fimg->createImage();
        delete new_fimg;
        if(width < min_width || height < min_height)
        {
            w = nv::max(width, min_width);
            h = nv::max(height, min_height);

            image->allocate(w, h);
            const nv::Color32 white(0xFF, 0xFF, 0xFF);

            for(int y = 0; y < h; y++)
            {
                nv::Color32* src_p = y < height ? new_image->scanline(y) : NULL;
                nv::Color32* dst_p = image->scanline(y);
                for(int x = 0; x < w; x++)
                {
                    if(x >= width || y >= height)
                    {
                        *dst_p++ = white;
                    }
                    else
                    {
                        *dst_p++ = *src_p++;
                    }
                }
            }
            delete new_image;
        }
        else
        {
            delete image;
            image = new_image;
        }
	}
	delete image;

    return size;
}

