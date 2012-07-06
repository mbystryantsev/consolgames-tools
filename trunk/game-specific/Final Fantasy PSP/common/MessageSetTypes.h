#pragma once
#include <CommonTypes.h>

#pragma pack(push, 1)

struct MessageSetHeader
{
	char signature[8]; // "\0\0\0\0TEXT"
	uint32 version     : 8;
	uint32 stringCount : 24;
	uint32 fileSize;
};

#pragma pack(pop)
