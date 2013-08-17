#pragma once
#include <core.h>

namespace Consolgames
{
class Stream;
}

namespace ShatteredMemories
{

struct TexHeader
{
	enum
	{
		signatureWii = 0x00494957, // "WII\0"
		signaturePS2 = 0x00325350, // "PS2\0"
		signaturePSP = 0x00505350, // "PSP\0"
	};

	TexHeader();
	static TexHeader read(Consolgames::Stream* stream);
	void write(Consolgames::Stream* stream) const;

	uint32 platformSignature;
	uint32 format;
	int width;
	int height;
	int mipmapCount;
	uint32 paletteFormat;
	uint32 rasterSize;
	uint32 paletteSize;
};

}
