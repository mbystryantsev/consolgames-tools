#include "dxt1.h"
#include <nvimage/image.h>
#include <pnglite.h>
#include <iostream>
#include <fstream>
#include <vector>

namespace
{

static int s_pngInitCode = png_init(0, 0);

inline void endian_swap_s(short& x)
{
	x = (( (unsigned)x >> 8) & 0xFF) |
		(( (unsigned)x << 8) & 0xFF00);
}

inline void endian_swap(int& x)
{
	x = ((unsigned)x>>24) |
		(((unsigned)x<<8) & 0x00FF0000) |
		(((unsigned)x>>8) & 0x0000FF00) |
		((unsigned)x<<24);
}

#pragma pack(push, 1)

struct TexHeader
{
	int textureType;
	short width;
	short height;
	int mipmapCount;
};

#pragma pack(pop)

using namespace std;


void PrintUsage()
{
	cout << "Metroid Prime 3 Texture Converter by HoRRoR\n"
			"http://consolgames.ru/\n"
			"Usage:\n"
			"  -d <InTexture> <OutImage> - decode texture to image\n"
			"  -e <InImage> <OutTexture> [MipmapCount] - encode image into texture\n";
}

bool savePNG(void* image, int width, int height, const char* filename)
{
	png_t png;
	if (png_open_file_write(&png, filename) != PNG_NO_ERROR)
	{
		return false;
	}
	png_set_data(&png, width, height, 8, PNG_TRUECOLOR_ALPHA, static_cast<unsigned char*>(image));
	png_close_file(&png);
	return true;
}

int calcEncodedSize(int w, int h, int m)
{
	int s = 0;
	while (m > 0)
	{
		s += w * h / 2;
		m--;
		w /= 2;
		h /= 2;
		w = max(w, 32);
		h = max(h, 32);
	}
	return s;
}

bool decodeTexture(const char* filename, const char* destFile)
{
	TexHeader header;
	std::ifstream file(filename, ifstream::in | ifstream::binary);
	if (!file.good())
	{
		cout << "Unable to open file!" << endl;
		return false;
	}

	file.read(reinterpret_cast<char*>(&header), sizeof(header));
	endian_swap(header.textureType);
	endian_swap_s(header.width);
	endian_swap_s(header.height);
	
	if (header.textureType != 10)
	{
		cout << "Unsupported texture type (" << header.textureType << "), supported only dxt1 (10)" << endl;
		return false;
	}

	const int size = header.width * header.height / 2;
	if (size <= 0)
	{
		cout << "Invalid image size!" << endl;
		return false;
	}

	std::vector<char> buf(size);
	std::vector<char> image(header.width * header.height * 4);
	file.read(&buf[0], size);
	file.close();

	{
		ofstream file("D:\\rev\\corruption\\txtr\\bin", ofstream::out | ofstream::binary);
		file.write(&buf[0], size);
	}
	if (header.textureType == 10)
	{
		DXTCodec::decodeDXT1(&buf[0], &image[0], header.width, header.height);
	}
	else
	{
		DXTCodec::convert8bppaToGray(&buf[0], &image[0], header.width, header.height);
	}

	if (!savePNG(&image[0], header.width, header.height, destFile))
	{
		cout << "Error saving image!" << endl;
		return false;
	}

	cout << "Done!" << endl;

	return true;
}

bool encodeTexture(const char* filename, const char* destFile, int mipmaps = 1)
{
	nv::Image image;

	if (!image.load(filename))
	{
		cout << "Error loading image!" << endl;
		return false;
	}

	TexHeader header;
	header.width = image.width();
	header.height = image.height();
	header.textureType = 10;
	header.mipmapCount = mipmaps;

	endian_swap_s(header.width);
	endian_swap_s(header.height);
	endian_swap(header.textureType);
	endian_swap(header.mipmapCount);


	std::vector<char> buf(calcEncodedSize(image.width(), image.height(), mipmaps));
	int size = DXTCodec::encodeDXT1(image.pixels(), &buf[0], image.width(), image.height(), mipmaps);

	ofstream file(destFile, ofstream::out);
	if (!file.good())
	{
		cout << "Error saving file!" << endl;
		return false;
	}

	file.write(reinterpret_cast<char*>(&header), sizeof(header));
	file.write(&buf[0], size);

	cout << "Done!" << endl;

	return true;
}

}

int main(int argc, char *argv[])
{
	if (argc < 4)
	{
		PrintUsage();
	}
	else if (strcmp(argv[1], "-d") == 0)
	{
		return decodeTexture(argv[2], argv[3]) ? 0 : -1;
	}
	else
	if(strcmp(argv[1], "-e") == 0)
	{
		int mipmaps = 1;
		if (argc > 4)
		{
			mipmaps = atoi(argv[4]);
		}
		return encodeTexture(argv[2], argv[3], mipmaps) ? 0 : -1;
	}
	else
	{
		PrintUsage();
	}

	return 0;
}

