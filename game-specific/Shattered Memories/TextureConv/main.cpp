#include "dxt1.h"
#include <core.h>
#include <FileStream.h>
#include <nvimage/image.h>
#include <pnglite.h>
#include <iostream>
#include <vector>

static int s_pngInitCode = png_init(0, 0);

using namespace std;
using namespace Consolgames;

struct TexHeader
{
	static TexHeader read(Stream* stream)
	{
		TexHeader header;
		header.textureType = stream->readUInt32();
		header.width = stream->readUInt16();
		header.height = stream->readUInt16();
		header.mipmapCount = stream->readUInt32();

		return header;
	}

	int textureType;
	short width;
	short height;
	int mipmapCount;
};

void PrintUsage()
{
	cout << "Silent Hill: Shattered Memories Texture Converter by consolgames.ru\n"
			"Usage:\n"
			"  -d [--mipmap] <InTexture> <OutImage> - decode texture to image\n"
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
		w = max(w, 8);
		h = max(h, 8);
	}
	return s;
}

bool decodeTexture(const char* filename, const char* destFile, bool decodeMipmap = false)
{
	FileStream stream(filename, Stream::modeRead);
	if (!stream.opened())
	{
		cout << "Unable to open file!" << endl;
		return false;
	}
	stream.setByteOrder(Stream::orderBigEndian);

	const TexHeader header = TexHeader::read(&stream);
	
	if (header.textureType != 10)
	{
		cout << "Unsupported texture type (" << header.textureType << "), supported only dxt1 (10)" << endl;
		return false;
	}

	const bool asMipmap = (decodeMipmap && header.mipmapCount > 1);

	const int resultWidth = asMipmap ? header.width + header.width / 2 : header.width;
	const int resultHeight = header.height;
	const int size = calcEncodedSize(header.width, header.height, asMipmap ? header.mipmapCount : 1);

	if (size <= 0)
	{
		cout << "Invalid image size!" << endl;
		return false;
	}

	std::vector<char> buf(size);
	std::vector<char> image(resultWidth * resultHeight * 4);
	stream.read(&buf[0], size);

	DXTCodec::decodeDXT1(&buf[0], &image[0], header.width, header.height, asMipmap ? header.mipmapCount : 1);

	if (!savePNG(&image[0], resultWidth, resultHeight, destFile))
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
	header.width = endian16(image.width());
	header.height = endian16(image.height());
	header.textureType = endian32(10);
	header.mipmapCount = endian32(mipmaps);

	std::vector<char> buf(calcEncodedSize(image.width(), image.height(), mipmaps));
	int size = DXTCodec::encodeDXT1(image.pixels(), &buf[0], image.width(), image.height(), mipmaps);

	FileStream file(destFile, Stream::modeWrite);
	if (!file.opened())
	{
		cout << "Error saving file!" << endl;
		return false;
	}

	file.write(&header, sizeof(header));
	file.write(&buf[0], size);

	cout << "Done!" << endl;

	return true;
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

