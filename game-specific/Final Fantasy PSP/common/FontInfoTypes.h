#pragma once
#include <CommonTypes.h>

#pragma pack(push, 1)

struct FontHeader
{
	uint16 height;
	uint16 charCount;
};

struct CharRecord
{
	CharRecord()
	{
	}
	CharRecord(uint16 x, uint16 y, uint16 w)
		: x(x), y(y), width(w)
	{
	}
	uint16 x;
	uint16 y;
	uint16 width;
};

typedef uint16 EncodingMap[138];

#pragma pack(pop)
