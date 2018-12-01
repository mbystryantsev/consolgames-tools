#pragma once
#include "WiiTypes.h"
#include <cinttypes>

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
	uint32_t cid;
	int index;
	WiiPartitionType type;
	largesize_t size;
	uint8_t hash[20];
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
	std::vector<uint8_t> signature;
	char issuer[64];
	uint8_t version;
	uint8_t ca_crl_version;
	uint8_t signer_crl_version;
	uint64_t sys_version;
	uint64_t title_id;
	uint32_t title_type;
	uint16_t group_id;
	uint32_t accessRights;
	uint16_t titleVersion;
	uint16_t numContents;
	uint16_t bootIndex;
	std::vector<TmdContent> contents;
};

}
