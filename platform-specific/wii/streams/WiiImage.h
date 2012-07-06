#ifndef __WIIIMAGE_H
#define __WIIIMAGE_H

#include "WiiTypes.h"
#include "Tmd.h"
#include "openssl/aes.h"
#include <FileStream.h>
#include <Nullable.h>
#include <vector>

namespace Consolgames
{

class WiiImage
{
protected:


public:
	bool open(const std::string& filename);
	void close();
	bool readHeader();
	bool checkAndLoadKey(bool loadCrypto);
	bool loadParitions();
	void loadTmd(int partition);
	const PartitionHeader& firstPartitionHeader();
	bool parseImage();
	Tree<FileInfo>::Node* searchFile(const std::string& name, Tree<FileInfo>::Node* folder = NULL);
	Tree<FileInfo>::Node* findFile(const std::string& path, Tree<FileInfo>::Node* folder = NULL);

public:
	bool setPartition(int partition);
	int currentPartition() const;
	int dataPartition() const;
	bool setDataPartition();
	int findDataPartitionIndex() const;

protected:
	void saveDecryptedFile(const std::string& destFilename, int partition, offset_t offset, largesize_t size, bool overrideEncrypt = false);
	u32 parse_fst_and_save(u8 *fst, const char* names, int i, int part);


public:
	largesize_t io_read(void* ptr, largesize_t size, offset_t offset);
	largesize_t	io_read_part(void* ptr, largesize_t size, int part, offset_t offset);
	void decryptBlock(int partition, int block);


	void readDirect(offset_t offset, void* data, largesize_t size);
	void writeDirect(offset_t offset, const void* data, largesize_t size);
	void writeDirect(offset_t offset, Stream* stream, largesize_t size){};
	bool loadDecryptedFile(const std::string& filename, u32 partition, u64 offset, u64 size, int fstReference);
	bool wii_trucha_signing(int partition);

	// TO REFACTORING:
	//u8			image_parse_header (struct PartitionHeader *header, u8 *buffer);
	//struct ImageFile *	image_init (const char *filename, int file_p = 0);
	//int			image_parse (struct ImageFile *image);
	//void			image_deinit (struct ImageFile *image, bool close_file = true);
	//u32			parse_fst (u8 *fst, const char *names, u32 i, struct tree *tree, struct ImageFile *image, u32 part, PNode hParent);
	//u8			get_partitions (struct ImageFile *image);
	//void			tmd_load (struct ImageFile *image, u32 part);
	bool wii_write_clusters(int partition, int cluster,  u8 *in, u32 nClusterOffset, u32 nBytesToWrite, Stream* stream){return false;};
	//void aes_cbc_dec(u8 *in, u8 *out, u32 len, u8 *key, u8 *iv);
	//void aes_cbc_enc(u8 *in, u8 *out, u32 len, u8 *key, u8 *iv);
	void sha1(u8 *data, u32 len, u8 *hash){};

	bool wii_write_data_file(int partition, offset_t offset, largesize_t size, u8 *in){return false;}
	bool wii_write_data_file(int partition, offset_t offset, largesize_t size, Stream* stream){return false;}
	bool wii_write_data_file(int partition, offset_t offset, largesize_t size, u8 *in, Stream* stream);

	bool checkForFreeSpace(int partition, offset_t offset, int blockCount) const;


	largesize_t findRequiredFreeSpaceInPartition(int partition, largesize_t requiredSize){return 0;};

	static void store32(void* data, u32 value);

	void markAsUsed(...){}
	void markAsUsedDC(...){}
	void markAsUnused(...){}

	static u32 calcDolSize(const u8* header);

	int partitionCount()
	{
		return m_generalPartitionCount;
	}

	bool m_isWii;

	static const u8 s_truchaSignature[256];

	int m_generalPartitionCount;
	std::vector<Partition> m_partitions;

	//       struct tree *tree;

	struct _stat st;

	int nfiles;
	largesize_t nbytes;

	int m_partitionCount;
	int m_channelCount;

	offset_t m_partTblOffset;
	offset_t m_chanTblOffset;

	AES_KEY m_key;


	std::auto_ptr<FileStream> m_stream;	
	// save the tables instead of reading and writing them all the time
	u8 m_h3[SIZE_H3];
	u8 m_h4[SIZE_H4];
	PartitionHeader m_header;
	int m_currentPartition;
};

}

#endif // __WIIIMAGE_H
