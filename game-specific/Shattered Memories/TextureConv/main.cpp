#include <Image.h>
#include <FloatImage.h>
#include <Filter.h>
#include <Color.h>
#include "WiiTextureCodec.h"
#include "PS2TextureCodec.h"
#include "PSPTextureCodec.h"
#include <TexHeader.h>
#include <FileStream.h>
#include <core.h>
#include <pnglite.h>
#include <jpeglib.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <set>

static const int s_pngInitCode = png_init(0, 0);
static const int c_defaultJpegQuality = 86;

using namespace std;
using namespace Consolgames;
using namespace ShatteredMemories;

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

static bool savePNG(void* image, int width, int height, const char* filename)
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

static void printUsage()
{
	cout << "Silent Hill: Shattered Memories Texture Converter by consolgames.ru\n"
			"Usage:\n"
			"  -d [--mipmap] <InTexture> <OutImage> - decode texture to image\n"
			"  -e <wii|ps2|psp> <format[:paletteFormat]> <InImage> <OutTexture> [MipmapCount] [width height] - encode image into texture\n"
			"     Wii formats:         dxt1|c4|c8\n"
			"     Wii palette formats: rgb565|rgb5a3\n"
			"     PS formats:          indexed4|indexed8|rgba16|rgba\n"
			"     PS palette formats:  rgba\n"
			"  -p <wii|ps2|psp> <csv> <InDir> <OutDir> - parse and extract textures\n"
			"  -j <InImage> <OutImage> [quality] - reencode image as jpeg\n";
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
	actionParse,
	actionEncodeJPEG,
	actionPrintUsage
};

struct Arguments
{
	Arguments()
		: action(actionUndefined)
		, platform(platformUndefined)
		, decodeMipmaps(false)
		, mipmapCount(0)
		, quality(c_defaultJpegQuality)
		, customWidth(0)
		, customHeight(0)
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
				&& !format.empty()
				&& !inputPath.empty()
				&& !outputPath.empty()
				&& ((customWidth == 0 && customHeight == 0) || (customWidth > 0 && customHeight > 0));
		}
		if (action == actionParse)
		{
			return platform != platformUndefined
				&& !inputPath.empty()
				&& !outputPath.empty()
				&& !csvPath.empty();
		}
		if (action == actionEncodeJPEG)
		{
			return !inputPath.empty()
				&& !outputPath.empty();
		}
		return false;
	}

	Action action;
	Platform platform;
	string format;
	string paletteFormat;
	vector<string> extractFormats;
	bool decodeMipmaps;
	string inputPath;
	string outputPath;
	string csvPath;
	int mipmapCount;
	int quality;
	int customWidth;
	int customHeight;
};

static Platform platformFromString(const char* platformStr)
{
	if (strcmp(platformStr, "wii") == 0)
	{
		return platformWii;
	}
	if (strcmp(platformStr, "ps2") == 0)
	{
		return platformPS2;
	}
	if (strcmp(platformStr, "psp") == 0)
	{
		return platformPSP;
	}

	return platformUndefined;
}

static Arguments parseArgs(int argc, char *argv[])
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

		if (permanentArgs.size() < 4 || permanentArgs.size() > 7)
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
		result.platform = platformFromString(platformStr);
		
		if (result.platform == platformUndefined)
		{
			cout << "Unknown platform: " << platformStr << endl;
			return Arguments();
		}

		result.format = permanentArgs[1];
		const size_t palFormatPos = result.format.find(':');
		if (palFormatPos != string::npos)
		{
			result.paletteFormat = result.format.c_str() + palFormatPos + 1;
			result.format.resize(palFormatPos);
		}

		result.inputPath = permanentArgs[2];
		result.outputPath = permanentArgs[3];

		if (permanentArgs.size() == 5 || permanentArgs.size() == 7)
		{
			result.mipmapCount = atoi(permanentArgs[4]);
		}
		else
		{
			result.mipmapCount = TextureCodec::mipmapCountDefault;
		}

		if (permanentArgs.size() == 7)
		{
			result.customWidth = atoi(permanentArgs[5]);
			result.customHeight = atoi(permanentArgs[6]);
		}
		else if (permanentArgs.size() == 6)
		{
			result.customWidth = atoi(permanentArgs[4]);
			result.customHeight = atoi(permanentArgs[5]);
		}
	}
	else if (strcmp(action, "-p") == 0 || strcmp(action, "--parse") == 0)
	{
		result.action = actionParse;

		if (permanentArgs.size() < 4)
		{
			cout << "Invalid actual parameters count!" << endl;
			return Arguments();
		}

		const char* platformStr = permanentArgs[0];
		result.platform = platformFromString(platformStr);

		if (result.platform == platformUndefined)
		{
			cout << "Unknown platform: " << platformStr << endl;
			return Arguments();
		}

		result.csvPath = permanentArgs[1];
		result.inputPath = permanentArgs[2];
		result.outputPath = permanentArgs[3];

		result.extractFormats.reserve(permanentArgs.size() - 4);
		for (size_t i = 4; i < permanentArgs.size(); i++)
		{
			result.extractFormats.push_back(permanentArgs[i]);
		}
	}
	else if (strcmp(action, "-j") == 0 || strcmp(action, "--jpeg") == 0)
	{		
		result.action = actionEncodeJPEG;

		if (permanentArgs.size() != 2 && permanentArgs.size() != 3)
		{
			cout << "Invalid actual parameters count!" << endl;
			return Arguments();
		}

		result.inputPath = permanentArgs[0];
		result.outputPath = permanentArgs[1];

		if (permanentArgs.size() == 3)
		{
			result.quality = atoi(permanentArgs[3]);
		}
		else
		{
			result.quality = c_defaultJpegQuality;
		}
	}
	else
	{
		result.action = actionPrintUsage;
	}


	return result;
}

static auto_ptr<TextureCodec> codecForPlatform(Platform platform)
{
	switch (platform)
	{
	case platformWii:
		return auto_ptr<TextureCodec>(new WiiTextureCodec());
	case platformPS2:
		return auto_ptr<TextureCodec>(new PS2TextureCodec());
	case  platformPSP:
		return auto_ptr<TextureCodec>(new PSPTextureCodec());
	}

	ASSERT(!"Unknown platform!");
	return auto_ptr<TextureCodec>();
}


static Platform platformFromSignature(uint32 signature)
{
	switch (signature)
	{
	case TexHeader::signatureWii:
		return platformWii;
	case TexHeader::signaturePS2:
		return platformPS2;
	case TexHeader::signaturePSP:
		return platformPSP;
	}

	return platformUndefined;
}

static uint32 platformToSignature(Platform platform)
{
	switch (platform)
	{
	case platformWii:
		return TexHeader::signatureWii;
	case platformPS2:
		return TexHeader::signaturePS2;
	case platformPSP:
		return TexHeader::signaturePSP;
	}

	ASSERT(!"Unknown platform!");
	return 0;
}

static bool checkFormatsAndNotify(TextureCodec* codec, int format, int paletteFormat)
{
	if (!codec->isFormatSupported(format))
	{
		cout << "Unsupported texture format (" << codec->textureFormatToString(format) << ", id=" << format << "), supported only dxt1 for Wii and indexed4/indexed8/RGBA for PS2/PSP" << endl;
		return false;
	}

	if (!codec->isPaletteFormatSupported(paletteFormat))
	{
		cout << "Unsupported palette format (" << codec->paletteFormatToString(paletteFormat) << ", id=" << paletteFormat << "), supported only RGBA palette for PS2/PSP" << endl;
		return false;
	}

	return true;
}

static bool decodeTexture(Stream& stream, const string& destPath, bool decodeMipmap)
{
	const TexHeader header = TexHeader::read(&stream);

	const Platform platform = platformFromSignature(header.platformSignature);
	
	auto_ptr<TextureCodec> codec = codecForPlatform(platform);
	if (codec.get() == NULL)
	{
		cout << "Platform unknown or not supported yet.";
		return false;
	}

	if (!checkFormatsAndNotify(codec.get(), header.format, header.paletteFormat))
	{
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

	if (header.rasterSize != codec->encodedRasterSize(header.format, header.width, header.height, header.mipmapCount))
	{
		cout << "WARNING: Actual and expected raster size are different!" << endl;
	}
	if (header.paletteSize != codec->encodedPaletteSize(header.format, header.paletteFormat))
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

	if (!codec->decode(&image[0], &rasterData[0], header.format, header.width, header.height, paletteData.empty() ? NULL : &paletteData[0], header.paletteFormat, asMipmap ? header.mipmapCount : 1))
	{
		cout << "Unable to decode image!";
		return false;
	}

	if (!savePNG(&image[0], resultWidth, resultHeight, destPath.c_str()))
	{
		cout << "Error saving image!" << endl;
		return false;
	}

	cout << "Done!" << endl;

	return true;
}

static bool decodeTexture(const string& inputPath, const string& destPath, bool decodeMipmap)
{
	FileStream stream(inputPath, Stream::modeRead);
	if (!stream.opened())
	{
		cout << "Unable to open file!" << endl;
		return false;
	}

	return decodeTexture(stream, destPath, decodeMipmap);
}

static bool encodeTexture(const string& filename, const string& destFile, Platform platform, const char* formatStr, const char* paletteFormatStr, int mipmaps, int customWidth, int customHeight)
{
	auto_ptr<TextureCodec> codec = codecForPlatform(platform);
	if (codec.get() == NULL)
	{
		cout << "Platform unknown or not supported yet.";
		return false;
	}

	const int format = codec->textureFormatFromString(formatStr);
	const int paletteFormat = paletteFormatStr == NULL ? codec->bestSuitablePaletteFormatFor(format) : codec->paletteFormatFromString(paletteFormatStr);

	if (!checkFormatsAndNotify(codec.get(), format, paletteFormat))
	{
		return false;
	}

	std::auto_ptr<nv::Image> image(new nv::Image());

	if (!image->load(filename.c_str()))
	{
		cout << "Error loading image!" << endl;
		return false;
	}

	if (customWidth != 0 && (image->width() != customWidth || image->height() != customHeight))
	{
		ASSERT(customWidth > 0);
		ASSERT(customHeight > 0);

		if (customWidth > static_cast<int>(image->width()) || customHeight > static_cast<int>(image->height()))
		{		
			cout << "WARNING: Upscaling from " << image->width() << 'x' << image->height() << " to " << customWidth << 'x' << customHeight << endl;
		}

		nv::FloatImage floatImage(image.get());
		std::auto_ptr<nv::FloatImage> resizedImage(floatImage.resize(nv::BoxFilter(), customWidth, customHeight, nv::FloatImage::WrapMode_Mirror));
		image.reset(resizedImage->createImage());
	}

	std::vector<uint32> rgba(image->width() * image->height());
	nvImageToRgba(*image, &rgba[0]);

	TexHeader header;
	header.platformSignature = platformToSignature(platform);
	header.format = format;
	header.paletteFormat = paletteFormat;
	header.width = image->width();
	header.height = image->height();
	header.mipmapCount = mipmaps;
	header.rasterSize = codec->encodedRasterSize(format, image->width(), image->height(), mipmaps);
	header.paletteSize = codec->encodedPaletteSize(format, paletteFormat);

	if (header.rasterSize == 0)
	{
		cout << "Unknown error!" << endl;
		return false;
	}

	vector<char> rasterData(header.rasterSize);
	vector<char> paletteData(header.paletteSize);

	if (!codec->encode(&rasterData[0], &rgba[0], format, image->width(), image->height(), paletteData.empty() ? NULL : &paletteData[0], paletteFormat, mipmaps))
	{
		cout << "Unable to encode image!";
		return false;
	}

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

static std::string extractPart(const std::string& str, int part)
{
	int offset = 0;
	int index = 0;
	while (true)
	{
		if (index++ == part)
		{
			const size_t endOffset = str.find(';', offset);
			if (endOffset == std::string::npos)
			{
				return str.substr(offset);
			}
			return str.substr(offset, endOffset - offset);
		}

		offset = str.find(';', offset);
		if (offset == std::string::npos)
		{
			return std::string();
		}
		offset++;
	}	
}

static bool extractTextures(Platform platform, const std::string& csvFile, const std::string& inputDir, const std::string& outputDir, const vector<string>& formats = vector<string>(), bool skipExistingTextures = false)
{
	std::auto_ptr<TextureCodec> codec = codecForPlatform(platform);
	if (codec.get() == NULL)
	{
		std::cout << "Unsupported platform!" << std::endl;
		return false;
	}

	std::ifstream stream(csvFile.c_str(), ios_base::in);
	if (!stream.is_open())
	{
		std::cout << "Unable to open input csv" << std::endl;
		return false;
	}

	set<int> formatSet;
	for (vector<string>::const_iterator it = formats.begin(); it != formats.end(); it++)
	{
		const int format = codec->textureFormatFromString(it->c_str());
		if (format == TextureCodec::textureFormatUndefined)
		{
			std::cout << "Unknown image format: " << *it << std::endl;
			return false;
		}

		formatSet.insert(format);
	}

	char buf[1024];

	stream.getline(buf, sizeof(buf));
	const std::string header = buf;

	int indexFileName = -1;
	int indexTextureName = -1;
	int indexRasterPosition = -1;
	int indexRasterSize = -1;
	int indexPalettePosition = -1;
	int indexPaletteSize = -1;
	int indexPaletteFormat = -1;
	int indexWidth = -1;
	int indexHeight = -1;
	int indexFormat = -1;

	int index = 0;
	while (true)
	{
		const std::string item = extractPart(header, index);

		if (item.empty())
		{
			break;
		}

		if (item == "fileHash")
		{
			ASSERT(indexFileName == -1);
			indexFileName = index;
		}
		else if (item == "fileName")
		{
			ASSERT(indexFileName == -1);
			indexFileName = index;
		}
		else if (item == "textureName")
		{
			indexTextureName = index;
		}
		else if (item == "rasterPosition")
		{
			indexRasterPosition = index;
		}
		else if (item == "rasterSize")
		{
			indexRasterSize = index;
		}
		else if (item == "palettePosition")
		{
			indexPalettePosition = index;
		}
		else if (item == "paletteSize")
		{
			indexPaletteSize = index;
		}
		else if (item == "paletteFormat")
		{
			indexPaletteFormat = index;
		}
		else if (item == "width")
		{
			indexWidth = index;
		}
		else if (item == "height")
		{
			indexHeight = index;
		}
		else if (item == "format")
		{
			indexFormat = index;
		}

		index++;
	}

	if (indexFileName == -1
		|| indexTextureName == -1
		|| indexRasterPosition == -1
		|| indexRasterSize == -1
		|| indexFormat == -1
		|| indexWidth == -1
		|| indexHeight == -1
	)
	{
		std::cout << "Invalid csv file!" << std::endl;
		return false;
	}

	std::auto_ptr<FileStream> textureStream;

	std::set<std::string> convertedTextures;

	int lineNum = 0;
	while (!stream.eof())
	{
		stream.getline(buf, sizeof(buf));
		lineNum++;
		const std::string line = buf;

		const std::string fileName = extractPart(line, indexFileName);
		const int width = atoi(extractPart(line, indexWidth).c_str());
		const int height = atoi(extractPart(line, indexHeight).c_str());
		const std::string name = extractPart(line, indexTextureName);
		const int format = codec->textureFormatFromString(extractPart(line, indexFormat).c_str());
		const int paletteFormat = (indexPaletteFormat == -1) ? TextureCodec::paletteFormatNone : codec->paletteFormatFromString(extractPart(line, indexPaletteFormat).c_str());
		const uint32 rasterPosition = strtoul(extractPart(line, indexRasterPosition).c_str(), NULL, 16);
		const uint32 rasterSize = strtoul(extractPart(line, indexRasterSize).c_str(), NULL, 16);
		const uint32 palettePosition = strtoul(extractPart(line, indexPalettePosition).c_str(), NULL, 16);
		const uint32 paletteSize = strtoul(extractPart(line, indexPaletteSize).c_str(), NULL, 16);

		if (fileName.empty() || width == 0 || height == 0 || name.empty() || format == TextureCodec::textureFormatUndefined || rasterPosition == 0 || rasterSize == 0)
		{
			std::cout << "Invalid line " << lineNum << ": " << line << std::endl;
			continue;
		}

		if (!formatSet.empty() && formatSet.find(format) == formatSet.end())
		{
			continue;
		}

		cout << "Decoding " << name << "..." << std::endl;

		if (convertedTextures.find(name) != convertedTextures.end())
		{
			continue;
		}
		convertedTextures.insert(name);

		const std::string outputFile = outputDir + PATH_SEPARATOR_STR + name + ".PNG";
		if (skipExistingTextures && FileStream::fileExists(outputFile))
		{
			continue;
		}

		if (!checkFormatsAndNotify(codec.get(), format, paletteFormat))
		{
			continue;
		}

		const std::string filename = inputDir + PATH_SEPARATOR_STR + fileName;// + ".BIN";
		if (textureStream.get() == NULL || textureStream->filename() != std::wstring(filename.begin(), filename.end()))
		{
			textureStream.reset(new FileStream(filename, Stream::modeRead));
		}

		if (!textureStream->opened())
		{
			std::cout << "Unable to open file: " << fileName << std::endl;
			return false;
		}

		vector<uint8> rasterData(rasterSize);
		vector<uint8> paletteData(paletteSize);
		vector<uint8> image(width * height * 4);

		textureStream->seek(rasterPosition, Stream::seekSet);
		textureStream->read(&rasterData[0], rasterSize);

		if (!paletteData.empty())
		{
			textureStream->seek(palettePosition, Stream::seekSet);
			textureStream->read(&paletteData[0], paletteData.size());
		}

		if (!codec->decode(&image[0], &rasterData[0], format, width, height, paletteData.empty() ? NULL : &paletteData[0], paletteFormat, 1))
		{
			cout << "Unable to decode texture!" << endl;
			return false;
		}

		if (!savePNG(&image[0], width, height, outputFile.c_str()))
		{
			cout << "Error saving image!" << endl;
			return false;
		}
	}
	
	return true;
}

static bool encodeJPEG(const string& filename, const string& destFile, int quality = c_defaultJpegQuality)
{
	nv::Image image;

	if (!image.load(filename.c_str()))
	{
		cout << "Error loading image!" << endl;
		return false;
	}

	FILE* outfile = fopen(destFile.c_str(), "wb");
	if (outfile == NULL)
	{				
		cout << "Unable to open output file!" << endl;
		return false;
	}

	jpeg_compress_struct cinfo;
	jpeg_error_mgr jerr;

	memset(&cinfo, 0, sizeof(cinfo));
	memset(&jerr, 0, sizeof(jerr));
	
	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_compress(&cinfo);
	jpeg_stdio_dest(&cinfo, outfile);

	cinfo.image_width = image.width();
	cinfo.image_height = image.height();
	cinfo.input_components = 3;
	cinfo.in_color_space = JCS_RGB;

	jpeg_set_defaults(&cinfo);
	jpeg_set_quality(&cinfo, quality, false);
	jpeg_start_compress(&cinfo, TRUE);

#pragma pack(push, 1)
	struct RGB24
	{
		uint8 r, g, b;
	};
#pragma pack(pop)

	std::vector<RGB24> line(image.width());
	JSAMPROW row_pointer[1] = { reinterpret_cast<JSAMPROW>(&line.front()) };
	while (cinfo.next_scanline < cinfo.image_height)
	{
		const nv::Color32* color32 = image.scanline(cinfo.next_scanline);
		RGB24* color24 = &line.front();
		for (uint i = 0; i < image.width(); i++)
		{
			color24->r = color32->r;
			color24->g = color32->g;
			color24->b = color32->b;
			color24++;
			color32++;
		}

		jpeg_write_scanlines(&cinfo, row_pointer, 1);
	}

	jpeg_finish_compress(&cinfo);
	jpeg_destroy_compress(&cinfo);

	fclose(outfile);

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
		return encodeTexture(args.inputPath, args.outputPath, args.platform, args.format.c_str(), args.paletteFormat.empty() ? NULL : args.paletteFormat.c_str(), args.mipmapCount, args.customWidth, args.customHeight) ? 0 : -1;
	}
	else if(args.action == actionParse)
	{
		return extractTextures(args.platform, args.csvPath, args.inputPath, args.outputPath, args.extractFormats) ? 0 : -1;
	}
	else if(args.action == actionEncodeJPEG)
	{
		return encodeJPEG(args.inputPath, args.outputPath, args.quality) ? 0 : -1;
	}
	else
	{
		printUsage();
	}

	return 0;
}

