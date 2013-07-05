#pragma once
#include <core.h>
#include <vector>

namespace Consolgames
{
class Stream;
}

namespace ResidentEvil
{

class Archive
{
public:
	enum
	{
		defaultOffsetsAddr = 0x8FE78,
		defaultFileCount = 134
	};

public:
	Archive(Consolgames::Stream* stream, Consolgames::Stream* slesStream, uint32 offsetsAddr = defaultOffsetsAddr, int fileCount = defaultFileCount);

	bool next();
	bool extract(Consolgames::Stream* outStream);

private:
	void parseOffsets(Consolgames::Stream* slesStream, uint32 offsetsAddr, int fileCount);

private:
	Consolgames::Stream* m_stream;
	std::vector<uint32> m_offsets;
	int m_position;
};

}
