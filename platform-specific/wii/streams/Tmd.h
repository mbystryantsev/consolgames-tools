#pragma once
#include "WiiTypes.h"
#include <core.h>

namespace Consolgames
{

enum WiiPartitionType
{
	PART_UNKNOWN = 0,
	PART_DATA,
	PART_UPDATE,
	PART_INSTALLER,
	PART_VC 
};

struct TmdContent
{
	uint32 cid;
	int index;
	WiiPartitionType type;
	largesize_t size;
	uint8 hash[20];
};

struct Tmd 
{
	Tmd()
		: sigType(SIG_UNKNOWN)
		, version(0)
		, ca_crl_version(0)
		, signer_crl_version(0)
		, sys_version(0)
		, title_id(0)
		, title_type(0)
		, group_id(0)
		, accessRights(0)
		, titleVersion(0)
		, numContents(0)
		, bootIndex(0)
	{
		memset(issuer, sizeof(issuer), 0);
	}

	TmdSigType sigType;
	std::vector<uint8> signature;
	char issuer[64];
	uint8 version;
	uint8 ca_crl_version;
	uint8 signer_crl_version;
	uint64 sys_version;
	uint64 title_id;
	uint32 title_type;
	uint16 group_id;
	uint32 accessRights;
	uint16 titleVersion;
	uint16 numContents;
	uint16 bootIndex;
	std::vector<TmdContent> contents;
};

}
