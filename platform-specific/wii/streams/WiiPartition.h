#pragma once
#include "Tmd.h"

namespace Consolgames
{

class WiiPartition
{
public:
	PartitionHeader header;
// 	struct Info
// 	{
		offset_t offset;
		offset_t dataOffset;
		largesize_t dataSize;
		offset_t certOffset;
		largesize_t certSize;
		uint32_t appldrSize;

		//! http://wiibrew.org/wiki/Title_metadata
		offset_t tmdOffset;
		uint32_t tmdSize;
		Nullable<Tmd> tmd;
		offset_t h3_offset;
 		char title_id_str[17];
// 	} info;
	WiiPartitionType type;
// 	bool m_isEncrypted;
// 	char m_channelId[5];
// 	AES_KEY m_key;
// 	uint8_t m_titleKey[16];
// 	uint8_t m_decryptionBuffer[0x8000];
// 	int m_cachedBlock;
// 	uint8_t m_cache[0x7c00];
// 	int m_fileCount;
	bool isEncrypted;
	char chan_id[5];
	AES_KEY key;
	uint8_t title_key[16];
	uint8_t dec_buffer[0x8000];
	int cached_block;
	uint8_t cache[0x7c00];
	int fileCount;

	int m_index;
	Tree<FileInfo> m_filesystem;

	Tree<FileInfo>::Node* addFilesystemObject(Tree<FileInfo>::Node* parentNode, const std::string& name, offset_t offset, largesize_t size, int fstReference, FsObjectType fsType);
	Tree<FileInfo>::Node* addFilesystemObject(const std::string& name, offset_t offset, largesize_t size, int fstReference, FsObjectType fsType);
	uint32_t parseFst(uint8_t* fstData, int index, Tree<FileInfo>::Node* node = NULL);
};

}
