#include <Image.h>
#include <Color.h>
#include "PS2TextureCodec.h"
#include "WiiTextureCodec.h"
#include <FileStream.h>
#include <core.h>
#include <pnglite.h>
#include <iostream>
#include <vector>

static int s_pngInitCode = png_init(0, 0);

using namespace std;
using namespace Consolgames;

static void nvImageToRgba(const nv::Image& image, void* result)
{
#pragma pack(push, 1)
struct RGBA {uint8 r, g, b, a;};
#pragma pack(pop)

	RGBA* dst = static_cast<RGBA*>(result);
	for (size_t y = 0; y < image.height(); y++)
	{
		const nv::Color32* src = image.scanline(y);
		for (size_t x = 0; x < image.width(); x++)
		{
			dst->r = src->r;
			dst->g = src->g;
			dst->b = src->b;
			dst->a = src->a;
			src++;
			dst++;
		}
	}
}

bool savePNG(void* image, int width, int height, const char* filename)
{
	png_t png;
	if (png_open_file_write(&png, filename) != PNG_NO_ERROR)
	{
		return false;
	}

	bool result = true;
	if (png_set_data(&png, width, height, 8, PNG_TRUECOLOR_ALPHA, static_cast<unsigned char*>(image)) != PNG_NO_ERROR)
	{
		result = false;
	}

	png_close_file(&png);

	return result;
}

struct TexHeader
{
	TexHeader()
		: platformSignature(0)
		, formatSignature(0)
		, width(0)
		, height(0)
		, mipmapCount(0)
		, reserved(0)
		, rasterSize(0)
		, paletteSize(0)
	{
	}

	static TexHeader read(Stream* stream)
	{
		TexHeader header;
		header.platformSignature = stream->readUInt32();
		header.formatSignature = stream->readUInt32();
		header.width = stream->readInt();
		header.height = stream->readInt();
		header.mipmapCount = stream->readInt();
		header.reserved = stream->readUInt32();
		header.rasterSize = stream->readUInt32();
		header.paletteSize = stream->readUInt32();
		return header;
	}

	void write(Stream* stream) const
	{
		stream->writeUInt32(platformSignature);
		stream->writeUInt32(formatSignature);
		stream->writeInt(width);
		stream->writeInt(height);
		stream->writeInt(mipmapCount);
		stream->writeUInt32(reserved);
		stream->writeUInt32(rasterSize);
		stream->writeUInt32(paletteSize);
	}

	uint32 platformSignature;
	uint32 formatSignature;
	int width;
	int height;
	int mipmapCount;
	uint32 reserved;
	uint32 rasterSize;
	uint32 paletteSize;
};

void printUsage()
{
	cout << "Silent Hill: Shattered Memories Texture Converter by consolgames.ru\n"
			"Usage:\n"
			"  -d [--mipmap] <InTexture> <OutImage> - decode texture to image\n"
			"  -e <wii|ps2|psp> <dxt1|indexed4|indexed8> <InImage> <OutTexture> [MipmapCount] - encode image into texture\n";
}

enum Platform
{
	platformUndefined = -1,
	platformWii,
	platformPS2,
	platformPSP
};

enum Action
{
	actionUndefined = -1,
	actionEncode,
	actionDecode,
	actionPrintUsage
};

struct Arguments
{
	Arguments()
		: action(actionUndefined)
		, platform(platformUndefined)
		, format(TextureCodec::formatUndefined)
		, decodeMipmaps(false)
		, mipmapCount(0)
	{
	}

	bool isValid() const
	{
		if (action == actionPrintUsage)
		{
			return true;
		}
		if (action == actionDecode)
		{
			return !inputPath.empty()
				&& !outputPath.empty();
		}
		if (action == actionEncode)
		{
			return platform != platformUndefined
				&& format != TextureCodec::formatUndefined
				&& !inputPath.empty()
				&& !outputPath.empty();
		}
		return false;
	}

	Action action;
	Platform platform;
	TextureCodec::Format format;
	bool decodeMipmaps;
	string inputPath;
	string outputPath;
	int mipmapCount;
};

Arguments parseArgs(int argc, char *argv[])
{
	Arguments result;

	if (argc < 3)
	{
		result.action = actionPrintUsage;
		return result;
	}

	vector<const char*> permanentArgs;
	vector<const char*> flags;

	for (int i = 2; i < argc; i++)
	{
		const char* arg = argv[i];
		if (arg[0] == '-')
		{
			flags.push_back(arg);
		}
		else
		{
			permanentArgs.push_back(arg);
		}
	}

	const char* action = argv[1];
	if (strcmp(action, "-d") == 0 || strcmp(action, "--decode") == 0)
	{
		result.action = actionDecode;

		if (permanentArgs.size() != 2)
		{
			cout << "Invalid actual parameters count!" << endl;
			return Arguments();
		}

		for (size_t i = 0; i < flags.size(); i++)
		{
			if (strcmp(flags[i], "--mipmaps") == 0)
			{
				result.decodeMipmaps = true;
			}
			else 
			{
				cout << "Unknown flag: " << flags[i];
				return Arguments();
			}
		}

		result.inputPath = permanentArgs[0];
		result.outputPath = permanentArgs[1];
	}
	else if (strcmp(action, "-e") == 0 || strcmp(action, "--encode") == 0)
	{
		result.action = actionEncode;

		if (permanentArgs.size() != 4 && permanentArgs.size() != 5)
		{
			cout << "Invalid actual parameters count!" << endl;
			return Arguments();
		}

		for (size_t i = 0; i < flags.size(); i++)
		{
			cout << "Unknown flag: " << flags[i] << endl;
			return Arguments();
		}

		const char* platformStr = permanentArgs[0];
		if (strcmp(platformStr, "wii") == 0)
		{
			result.platform = platformWii;
		}
		else if (strcmp(platformStr, "ps2") == 0)
		{
			result.platform = platformPS2;
		}
		else if (strcmp(platformStr, "psp") == 0)
		{
			result.platform = platformPSP;
		}
		else
		{
			cout << "Unknown platform: " << platformStr << endl;
			return Arguments();
		}

		const char* formatStr = permanentArgs[1];
		if (strcmp(formatStr, "indexed4") == 0)
		{
			result.format = TextureCodec::formatIndexed4;
		}
		else if (strcmp(formatStr, "indexed8") == 0)
		{
			result.format = TextureCodec::formatIndexed8;
		}
		else if (strcmp(formatStr, "dxt1") == 0)
		{
			result.format = TextureCodec::formatDXT1;
		}
		else
		{
			cout << "Unknown texture format: " << formatStr << endl;
			return Arguments();
		}

		result.inputPath = permanentArgs[2];
		result.outputPath = permanentArgs[3];

		if (permanentArgs.size() == 5)
		{
			result.mipmapCount = atoi(permanentArgs[4]);
		}
		else
		{
			result.mipmapCount = TextureCodec::mipmapCountDefault;
		}
	}
	else
	{
		result.action = actionPrintUsage;
	}


	return result;
}

auto_ptr<TextureCodec> codecForPlatform(Platform platform)
{
	switch (platform)
	{
	case platformWii:
		return auto_ptr<TextureCodec>(new WiiTextureCodec());
	case platformPS2:
		return auto_ptr<TextureCodec>(new PS2TextureCodec());
	case  platformPSP:
		return auto_ptr<TextureCodec>();
	}

	ASSERT(!"Unknown platform!");
	return auto_ptr<TextureCodec>();
}

enum
{
	signatureDXT1     = 0x31545844, // "DXT1"
	signatureIndexed4 = 0x34584449, // "IDX4"
	signatureIndexed8 = 0x38584449, // "IDX8"

	signatureWii = 0x00494957, // "WII\0"
	signaturePS2 = 0x00325350, // "PS2\0"
	signaturePSP = 0x00505350, // "PSP\0"
};

TextureCodec::Format textureFormatFromSignature(uint32 signature)
{
	switch (signature)
	{
	case signatureDXT1:
		return TextureCodec::formatDXT1;
	case signatureIndexed4:
		return TextureCodec::formatIndexed4;
	case signatureIndexed8:
		return TextureCodec::formatIndexed8;
	}

	return TextureCodec::formatUndefined;
}

uint32 textureFormatToSignature(TextureCodec::Format format)
{
	switch (format)
	{
	case TextureCodec::formatDXT1:
		return signatureDXT1;
	case TextureCodec::formatIndexed4:
		return signatureIndexed4;
	case TextureCodec::formatIndexed8:
		return signatureIndexed8;
	}

	ASSERT(!"Unknown texture format!");
	return 0;
}

Platform platformFromSignature(uint32 signature)
{
	switch (signature)
	{
	case signatureWii:
		return platformWii;
	case signaturePS2:
		return platformPS2;
	case signaturePSP:
		return platformPSP;
	}

	return platformUndefined;
}

uint32 platformToSignature(Platform platform)
{
	switch (platform)
	{
	case platformWii:
		return signatureWii;
	case platformPS2:
		return signaturePS2;
	case platformPSP:
		return signaturePSP;
	}

	ASSERT(!"Unknown platform!");
	return 0;
}

bool decodeTexture(const string& inputPath, const string& destPath, bool decodeMipmap)
{
	FileStream stream(inputPath, Stream::modeRead);
	if (!stream.opened())
	{
		cout << "Unable to open file!" << endl;
		return false;
	}

	const TexHeader header = TexHeader::read(&stream);

	const Platform platform = platformFromSignature(header.platformSignature);
	
	auto_ptr<TextureCodec> codec = codecForPlatform(platform);
	if (codec.get() == NULL)
	{
		cout << "Platform unknown or not supported yet.";
		return false;
	}

	const TextureCodec::Format format = textureFormatFromSignature(header.formatSignature);
	if (!codec->formatIsSupported(format))
	{
		cout << "Unsupported texture format (" << header.formatSignature << "), supported only dxt1 for Wii and indexed4/indexed8 for PS2/PSP" << endl;
		return false;
	}

	const bool asMipmap = (decodeMipmap && header.mipmapCount > 1);

	const int resultWidth = asMipmap ? header.width + header.width / 2 : header.width;
	const int resultHeight = header.height;

	if (header.rasterSize <= 0)
	{
		cout << "Invalid image size!" << endl;
		return false;
	}

	if (header.rasterSize != codec->encodedRasterSize(format, header.width, header.height, header.mipmapCount))
	{
		cout << "WARNING: Actual and expected raster size are different!" << endl;
	}
	if (header.paletteSize != codec->encodedPaletteSize(format))
	{
		cout << "WARNING: Actual and expected palette size are different!" << endl;
	}

	vector<uint8> rasterData(header.rasterSize);
	vector<uint8> paletteData(header.paletteSize);
	vector<uint8> image(resultWidth * resultHeight * 4);
	stream.read(&rasterData[0], header.rasterSize);
	if (!paletteData.empty())
	{
		stream.read(&paletteData[0], paletteData.size());
	}

	codec->decode(&image[0], &rasterData[0], header.width, header.height, format, paletteData.empty() ? NULL : &paletteData[0], asMipmap ? header.mipmapCount : 1);

	if (!savePNG(&image[0], resultWidth, resultHeight, destPath.c_str()))
	{
		cout << "Error saving image!" << endl;
		return false;
	}

	cout << "Done!" << endl;

	return true;
}

bool encodeTexture(const string& filename, const string& destFile, Platform platform, TextureCodec::Format format, int mipmaps)
{
	auto_ptr<TextureCodec> codec = codecForPlatform(platform);
	if (codec.get() == NULL)
	{
		cout << "Platform unknown or not supported yet.";
		return false;
	}

	if (!codec->formatIsSupported(format))
	{
		cout << "Unsupported texture format, supported only dxt1 for Wii and indexed4/indexed8 for PS2/PSP" << endl;
		return false;
	}

	nv::Image image;

	if (!image.load(filename.c_str()))
	{
		cout << "Error loading image!" << endl;
		return false;
	}

	std::vector<uint32> rgba(image.width() * image.height());
	nvImageToRgba(image, &rgba[0]);

	TexHeader header;
	header.platformSignature = platformToSignature(platform);
	header.formatSignature = textureFormatToSignature(format);
	header.width = image.width();
	header.height = image.height();
	header.mipmapCount = mipmaps;
	header.rasterSize = codec->encodedRasterSize(format, image.width(), image.height(), mipmaps);
	header.paletteSize = codec->encodedPaletteSize(format);

	if (header.rasterSize == 0)
	{
		cout << "Unknown error!" << endl;
		return false;
	}

	vector<char> rasterData(header.rasterSize);
	vector<char> paletteData(header.paletteSize);
	codec->encode(&rasterData[0], &rgba[0], image.width(), image.height(), format, paletteData.empty() ? NULL : &paletteData[0], mipmaps);

	FileStream file(destFile, Stream::modeWrite);
	if (!file.opened())
	{
		cout << "Error saving file!" << endl;
		return false;
	}

	header.write(&file);
	file.write(&rasterData[0], header.rasterSize);

	if (!paletteData.empty())
	{
		file.write(&paletteData[0], paletteData.size());
	}

	cout << "Done!" << endl;

	return true;
}

int main(int argc, char *argv[])
{
	const Arguments args = parseArgs(argc, argv);
	
	if (!args.isValid())
	{
		return -1;
	}

	if (args.action == actionDecode)
	{
		return decodeTexture(args.inputPath, args.outputPath, args.decodeMipmaps) ? 0 : -1;
	}
	else if(args.action == actionEncode)
	{
		return encodeTexture(args.inputPath, args.outputPath, args.platform, args.format, args.mipmapCount) ? 0 : -1;
	}
	else
	{
		printUsage();
	}

	return 0;
}

