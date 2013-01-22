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
	u32 cid;
	int index;
	WiiPartitionType type;
	largesize_t size;
	u8 hash[20];
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
	std::vector<u8> signature;
	char issuer[64];
	u8 version;
	u8 ca_crl_version;
	u8 signer_crl_version;
	u64 sys_version;
	u64 title_id;
	u32 title_type;
	u16 group_id;
	u32 accessRights;
	u16 titleVersion;
	u16 numContents;
	u16 bootIndex;
	std::vector<TmdContent> contents;
};

}
