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
