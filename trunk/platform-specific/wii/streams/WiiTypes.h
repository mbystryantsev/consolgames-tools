#pragma once

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS 1
#endif

#include <core.h>
#include "aes.h"
#include <Nullable.h>
#include <Tree.h>
#include <vector>
#include <string>

namespace Consolgames
{

#define SIZE_H0						0x0026C
#define SIZE_H1						0x000A0
#define SIZE_H2						0x000A0
#define SIZE_H3						0x18000
#define SIZE_H4						0x00014
#define SIZE_PARTITION_HEADER		0x20000
#define SIZE_CLUSTER				0x08000
#define SIZE_CLUSTER_HEADER			0x00400
#define SIZE_CLUSTER_DATA			(SIZE_CLUSTER - SIZE_CLUSTER_HEADER)

	// ADDRESSES

	// Absolute addresses
#define OFFSET_GAME_TITLE			0x00020UL
#define OFFSET_PARTITIONS_INFO		0x40000UL
#define OFFSET_REGION_BYTE			0x4E003UL
#define OFFSET_REGION_CODE			0x4E010UL

	// Relative addresses
#define OFFSET_H0					0x00000UL
#define OFFSET_H1					0x00280UL
#define OFFSET_H2					0x00340UL
#define OFFSET_PARTITION_TITLE_KEY	0x001BFUL
#define OFFSET_PARTITION_TITLE_ID	0x001DCUL
#define OFFSET_PARTITION_TMD_SIZE	0x002A4UL
#define OFFSET_PARTITION_TMD_OFFSET	0x002A8UL
#define OFFSET_PARTITION_H3_OFFSET	0x002B4UL
#define OFFSET_PARTITION_INFO		0x002B8UL
#define OFFSET_CLUSTER_IV			0x003D0UL
#define OFFSET_FST_NB_FILES			0x00008UL
#define OFFSET_FST_ENTRIES			0x0000CUL
#define OFFSET_TMD_HASH				0x001F4UL

	// OTHER
#define NB_CLUSTER_GROUP			64
#define NB_CLUSTER_SUBGROUP			8

enum TmdSigType 
{
	SIG_UNKNOWN = 0,
	SIG_RSA_2048,
	SIG_RSA_4096
};

inline u16 be16 (const u8 *p)
{
	return (p[0] << 8) | p[1];
}

inline u32 be32 (const u8 *p)
{
	return (p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3];
}

inline u64 be64 (const u8 *p)
{
	return ((u64) be32 (p) << 32) | be32 (p + 4);
}

#define ROUNDUP64B(x) (((u64)(x) + 64 - 1) & ~(64 - 1))

struct PartitionHeader 
{
	char console;
	char gamecode[2];
	char region;
	char publisher[2];

	bool hasMagic;
	char name[0x60];

	offset_t dolOffset;
	u32 dolSize;

	offset_t fstOffset;
	u32 fstSize;

	static PartitionHeader parse(void* data)
	{
		unsigned char* buffer = static_cast<unsigned char*>(data);

		PartitionHeader header;
		memset(&header, 0, sizeof(header));

		header.console = buffer[0];
		header.gamecode[0] = buffer[1];
		header.gamecode[1] = buffer[2];
		header.region = buffer[3];
		header.publisher[0] = buffer[4];
		header.publisher[1] = buffer[5];
		header.hasMagic = (be32(&buffer[0x18]) == 0x5d1c9ea3);

		strncpy(header.name, reinterpret_cast<char*>(&buffer[0x20]), 0x60);

		header.dolOffset = be32 (&buffer[0x420]);
		header.fstOffset = be32(&buffer[0x424]);
		header.fstSize = be32(&buffer[0x428]);
		if (header.isWii())
		{
			header.dolOffset *= 4;
			header.fstOffset *= 4;
			header.fstSize *= 4;
		}
		return header;
	}
	bool isWii() const
	{
		return (console == 'R') || (console == '_') || (console == 'H') || (console == '0') || (console == '4');
	}
	bool isGamecube() const
	{
		return (console == 'G') || (console == 'D') || (console == 'P') || (console == 'U');
	}
	std::string discId() const
	{
		std::string id(6, '\0');
		id[0] = console;
		id[1] = gamecode[0];
		id[2] = gamecode[1];
		id[3] = region;
		id[4] = publisher[0];
		id[5] = publisher[1];
		return id;
	}
};

enum FsObjectType
{
	dataVoid,
	dataFile,
	dataPartition,
	dataPartitionBin,
	dataFolder,
	dataDisc
};

enum ReferenceType
{
	refFst = -1,
	refMain = -2,
	refApploader = -3,
	refPartition = -4,
	refTmd = -5,
	refCert = -6,
	refH3 = -7
};

struct FileInfo
{
	std::string name;
	int partition;
	offset_t   offset;
	largesize_t size;
	int fstReference;
	FsObjectType dataType;
};

struct Certificate
{
	u32 signatureType;
	char signature[256];
	char issuer[64];
	int tag;
	char name[64];
	// key;
};


typedef Tree<FileInfo>::Node *PNode;

class IWiiDiscProcessHandler
{
public:
	virtual void setPosition(int position) = 0;
	virtual void setRange(int start, int end) = 0;
	virtual void setText(const char* message) = 0;
};

};
