#include "EmbededResourceInfo.h"
#include <Stream.h>

namespace ShatteredMemories
{

const quint32 EmbededResourceInfo::s_headerSize = 0x38;
const quint32 EmbededResourceInfo::s_contentSizeOffset = 0x14;

EmbededResourceInfo::EmbededResourceInfo()
	: type(Invalid)
	, streamSizeLeft(0)
	, contentSize(0)
{
}

EmbededResourceInfo EmbededResourceInfo::parse(Consolgames::Stream* stream)
{
	char signature[9] = "";
	stream->read(signature, 8);

	if (QString(signature) != "EMBEDED")
	{
		return EmbededResourceInfo();
	}

	EmbededResourceInfo info;

	char typeStr[5] = "";
	stream->read(typeStr, 4);
	if (QString(typeStr) == "AH")
	{
		info.type = ArchiveHeader;
	}
	else if (QString(typeStr) == "FS")
	{
		info.type = FileSystem;
	}
	else
	{
		return EmbededResourceInfo();
	}

	const quint32 c_tag = 0x2C2A4569;
	const quint32 tag = stream->read32();
	if (tag != c_tag)
	{
		return EmbededResourceInfo();
	}

	info.streamSizeLeft = stream->read32();
	info.contentSize = stream->read32();

	char name[33] = "";
	stream->read(name, 32);
	info.contentName = name;

	return info;
}

bool EmbededResourceInfo::isNull() const
{
	return (contentSize == 0);
}

}
