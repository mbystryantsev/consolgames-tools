#include "TexHeader.h"
#include <Stream.h>

namespace ShatteredMemories
{
TexHeader::TexHeader() : platformSignature(0)
	, format(-1)
	, width(0)
	, height(0)
	, mipmapCount(0)
	, paletteFormat(-2)
	, rasterSize(0)
	, paletteSize(0)
{
}

ShatteredMemories::TexHeader TexHeader::read(Consolgames::Stream* stream)
{
	TexHeader header;
	header.platformSignature = stream->readUInt32();
	header.format = stream->readUInt32();
	header.width = stream->readInt();
	header.height = stream->readInt();
	header.mipmapCount = stream->readInt();
	header.paletteFormat = stream->readUInt32();
	header.rasterSize = stream->readUInt32();
	header.paletteSize = stream->readUInt32();
	return header;
}

void TexHeader::write(Consolgames::Stream* stream) const
{
	stream->writeUInt32(platformSignature);
	stream->writeUInt32(format);
	stream->writeInt(width);
	stream->writeInt(height);
	stream->writeInt(mipmapCount);
	stream->writeUInt32(paletteFormat);
	stream->writeUInt32(rasterSize);
	stream->writeUInt32(paletteSize);
}

}
