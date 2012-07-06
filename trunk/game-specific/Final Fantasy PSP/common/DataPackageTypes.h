#pragma once
#include "CommonTypes.h"

#pragma pack(push, 1)

struct PackageHeader
{
	uint32 fileCount;
	uint32 totalSize;
	uint32 reserved1;
	uint32 reserved2;
};

struct FileRecord
{
	char name[22];
	uint16 nameHash;
	uint32 offset;
	uint32 packedSize;
	uint32 fileSize;
	bool isPacked() const
	{
		return fileSize != packedSize;
	}
};

#pragma pack(pop)
