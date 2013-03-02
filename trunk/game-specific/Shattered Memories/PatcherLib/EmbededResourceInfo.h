#pragma once
#include <QString>

namespace Consolgames
{
class Stream;
}

namespace ShatteredMemories
{

struct EmbededResourceInfo
{
	EmbededResourceInfo();
	static EmbededResourceInfo EmbededResourceInfo::parse(Consolgames::Stream* stream);
	bool isNull() const;

	enum Type
	{
		Invalid = -1,
		FileSystem,
		ArchiveHeader
	};

	Type type;
	quint32 streamSizeLeft;
	quint32 contentSize;
	QString contentName;

	static const quint32 s_headerSize;
	static const quint32 s_contentSizeOffset;
};

}