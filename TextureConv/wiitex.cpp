#include "wiitex.h"
#include "dxt1.h"
#include "pnglite/pnglite.h"
#include "miniLZO/minilzo.h"

//#include <nvcore/StrLib.h>
//#include <nvcore/StdStream.h>

#include <nvimage/Image.h>
//#include <nvimage/DirectDrawSurface.h>
#include <nvimage/BlockDXT.h>
#include <nvimage/FloatImage.h>
#include <nvimage/filter.h>
//#include <nvimage/ImageIO.h>
//#include <nvmath/Color.h>
#include <nvimage/Quantize.h>
//#include <nvimage/ColorBlock.h>


#include "nvtt/squish/colourset.h"
//#include "squish/clusterfit.h"
//#include "nvtt/squish/fastclusterfit.h"
//#include "nvtt/squish/weightedclusterfit.h"

#include <nvtt/nvtt.h>
//#include <nvtt/Compressor.h>
#include <nvtt/OptimalCompressDXT.h>
#include <nvtt/QuickCompressDXT.h>

//#include <pnglite/pnglite.h>


int WiiTexResizeImage(void *pixels, void *new_pixels, int width, int height, int filter, int new_width, int new_height)
{

	nv::Filter *r_filter;
	switch(filter)
	{
		case FILTER_BOX:		r_filter = new nv::BoxFilter(); break;
		case FILTER_QUADRATIC:	r_filter = new nv::QuadraticFilter(); break;
		case FILTER_TRIANGLE:	r_filter = new nv::TriangleFilter(); break;
		case FILTER_CUBIC:		r_filter = new nv::CubicFilter(); break;
		default:
			return ERROR_UNKNOWN_FILTER;
	}


	nv::Image image;
	image.allocate(width, height);
	memcpy(image.pixels(), pixels, sizeof(nv::Color32) * width * height);
	nv::FloatImage f_image(&image);


	nv::FloatImage *new_fimage = f_image.resize(*r_filter, new_width, new_height, nv::FloatImage::WrapMode_Mirror);


	nv::Image *new_image = new_fimage->createImage();
	memcpy(new_pixels, new_image->pixels(), new_width * new_height * sizeof(nv::Color32));

	delete new_fimage;
	delete r_filter;
	delete new_image;
	return 0;
}

int WiiTexResizeImageConstr(void *image, int width, int height, int filter, int new_width, int new_height,
					  int canvas_width, int canvas_height, int bgcolor)
{
	return 0;
}

int WiiTexDecodeDXT1(void *data, void *image, int width, int height)
{
	DecodeDXT1(data, image, width, height);
	return 0;
}

int WiiTexDecodeDXT3(void *data, void *image, int width, int height)
{
	DecodeDXT3(data, image, width, height);
	return 0;
}

int WiiTexEncodeDXT1(void *pixels, void *data, int width, int height)
{
	nv::Image image;
	image.allocate(width, height);
	memcpy(image.pixels(), pixels, width * height * sizeof(nv::Color32));
	nv::Quantize::FloydSteinberg(&image, 5, 6, 5, 8);
	EncodeDXT1(image.pixels(), data, width, height);
	return 0;

}

int WiiTexEncodeDXT1m(void *image, void *data, int width, int height, int mipmaps)
{
	//EncodeDXT1(
	return 0;

}

int WiiTexLoadImage(char* filename, void *pixels, int *width, int *height)
{
	nv::Image image;

	if(!image.load(filename)){
		return ERROR_IO_IMAGE;
	}
	memcpy(pixels, image.pixels(), image.width() * image.height() * sizeof(nv::Color32));
	*width = image.width();
	*height = image.height();
	return 0;
}


int WiiTexSavePNG(char* filename, void* pixels, int width, int height)
{
	png_t png;
	png_init(0, 0);
	if(png_open_file_write(&png, filename) != PNG_NO_ERROR)
	{
		return ERROR_IO_IMAGE;
	}
	if(png_set_data(&png, width, height, 8, PNG_TRUECOLOR_ALPHA, (unsigned char*)pixels) != PNG_NO_ERROR)
	{
		return ERROR_IO_IMAGE;
	}
	png_close_file(&png);
	return 0;
}


int WiiTexDecodeLZO(void *in_data, int in_size, void* out_data)
{
	lzo_uint out_size;
	lzo1x_decompress((unsigned char*)in_data, in_size, (unsigned char*)out_data, &out_size, NULL);
	return (int)out_size;
}

int WiiTexEncodeLZO(void *in_data, int in_size, void* out_data)
{
	lzo_uint out_size;
	lzo1x_1_compress((unsigned char*)in_data, in_size, (unsigned char*)out_data, &out_size, NULL);
	return (int)out_size;
}


int WiiTexDeswizzleImage(void *in_data, void *out_data, int width, int height)
{
	DeswizzleImage(in_data, out_data, width, height);
	return 0;
}

int WiiTex8bppToGray(void *in_data, void *out_data, int width, int height)
{
	nv::Color32 *color = (nv::Color32*)out_data;
	unsigned char *c = (unsigned char*)in_data;
	for(int i = 0; i < width * height; i++)
	{
		color->a = 0xFF;
		color->r = color->g = color->b = *c++;
		color++;
	}
	return 0;
}

int WiiTex8bppaToGray(void *in_data, void *out_data, int width, int height)
{
	nv::Color32 *color = (nv::Color32*)out_data;
	unsigned char *c = (unsigned char*)in_data;
	for(int i = 0; i < width * height; i++)
	{
		color->a = *c++;
		color->r = color->g = color->b = *c++;
		color++;
	}
	return 0;
}
