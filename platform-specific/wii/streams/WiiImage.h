#pragma once

#include "WiiTypes.h"
#include "Tmd.h"
#include "openssl/aes.h"
#include "WiiPartition.h"
#include <FileStream.h>
#include <Nullable.h>
#include <vector>

namespace Consolgames
{

class WiiFileStream;

//! http://wiibrew.org/wiki/Wiidisc
class WiiImage
{
public:
	class IProgressHandler
	{
	public:
		virtual void startProgress(const char* action, int maxValue) = 0;
		virtual void progress(int value) = 0;
		virtual void finishProgress() = 0;
		virtual bool stopRequested()
		{
			return false;
		}
	};

	IProgressHandler& progressHandler() const
	{
		return (m_progressHandler != NULL ? *m_progressHandler : s_dummyProgressHandler);
	}

private:
	class DummyProgressHandler : public IProgressHandler
	{
		virtual void startProgress(const char*, int) override
		{
		}
		virtual void progress(int) override
		{
		}
		virtual void finishProgress() override
		{
		}
	};

	class ProgressHandlerHolder
	{
	public:
		ProgressHandlerHolder(IProgressHandler& handler, const char* action, int maxSize)
			: m_handler(handler)
		{
			m_handler.startProgress(action, maxSize);
		}
		~ProgressHandlerHolder()
		{
			m_handler.finishProgress();
		}

	private:
		IProgressHandler& m_handler;
	};

public:
	bool open(const std::wstring& filename, Stream::OpenMode mode);
	bool isOpen() const;
	void close();
	bool readHeader();
	bool checkAndLoadKey(bool loadCrypto);
	bool loadParitions();
	void loadTmd(int partition);
	const PartitionHeader& firstPartitionHeader();
	bool parseImage();
	Tree<FileInfo>::Node* searchFile(const std::string& name, Tree<FileInfo>::Node* folder = NULL);
	Tree<FileInfo>::Node* findFile(const std::string& path, Tree<FileInfo>::Node* folder = NULL);
	Consolgames::WiiFileStream* openFile(const std::string& path, Stream::OpenMode mode);

public:
	bool setPartition(int partition);
	int currentPartition() const;
	int dataPartition() const;
	bool setDataPartition();
	int findDataPartitionIndex() const;

protected:
	void saveDecryptedFile(const std::wstring& destFilename, int partition, offset_t offset, largesize_t size, bool overrideEncrypt = false);
	uint32_t parse_fst_and_save(uint8_t *fst, const char* names, int i, int part);

public:
	bool checkPartition(int partition);


public:
	WiiImage();
	
	std::string discId() const;
	void setProgressHandler(IProgressHandler* handler);

	largesize_t io_read(void* ptr, largesize_t size, offset_t offset);
	largesize_t	io_read_part(void* ptr, largesize_t size, int part, offset_t offset);
	void decryptBlock(int partition, int block);


	void readDirect(offset_t offset, void* data, largesize_t size);
	bool writeDirect(offset_t offset, const void* data, largesize_t size);
	bool writeDirect(offset_t offset, Stream* stream, largesize_t size){offset;stream;size;return false;};
	bool loadDecryptedFile(const std::wstring& filename, uint32_t partition, offset_t offset, largesize_t size, int fstReference);
	
	//! http://wiibrew.org/wiki/Signing_bug
	//! http://hackmii.com/2008/04/keys-keys-keys/
	bool wii_trucha_signing(int partition);

	// TO REFACTORING:
	//uint8_t			image_parse_header (struct PartitionHeader *header, uint8_t *buffer);
	//struct ImageFile *	image_init (const char *filename, int file_p = 0);
	//int			image_parse (struct ImageFile *image);
	//void			image_deinit (struct ImageFile *image, bool close_file = true);
	//uint32_t			parse_fst (uint8_t *fst, const char *names, uint32_t i, struct tree *tree, struct ImageFile *image, uint32_t part, PNode hParent);
	//uint8_t			get_partitions (struct ImageFile *image);
	//void			tmd_load (struct ImageFile *image, uint32_t part);

	int wii_nb_cluster(int partition) const;
	bool wii_read_cluster(int partition, int cluster, uint8_t *data, uint8_t *header);
	bool wii_read_cluster_hashes(int partition, int cluster, uint8_t *h0, uint8_t *h1, uint8_t *h2);
	bool wii_calc_group_hash(int partition, int cluster);
	bool wii_write_cluster(int partition, int cluster, const uint8_t* in);
	bool wii_write_clusters(int partition, int cluster, const uint8_t *in, uint32_t nClusterOffset, uint32_t nBytesToWrite, Stream* stream);
	bool wii_write_clusters(int partition, int cluster, int nClusterOffset, int nBytesToWrite, Stream* inStream);

	// AES
	static void aes_cbc_dec(const uint8_t* in, uint8_t* out, uint32_t len, const uint8_t* key, uint8_t* iv);
	static void aes_cbc_enc(const uint8_t *in, uint8_t* out, uint32_t len, const uint8_t* key, uint8_t* iv);
	static void sha1(const uint8_t *data, uint32_t len, uint8_t *hash);

	bool wii_write_data_file(int partition, offset_t offset, Stream* file, largesize_t size);
	bool wii_write_data_file(int partition, offset_t offset, void* data, largesize_t size);
	bool wii_write_data(int partition, offset_t offset, Stream* file, largesize_t size);

	bool checkForFreeSpace(int partition, offset_t offset, int blockCount) const;


	largesize_t findRequiredFreeSpaceInPartition(int partition, largesize_t requiredSize){partition;requiredSize;return 0;};

	static void store32(void* data, uint32_t value);

	void markAsUsed(...){}
	void markAsUsedDC(...){}
	void markAsUnused(...){}

	static uint32_t calcDolSize(const uint8_t* header);

	int partitionCount()
	{
		return m_generalPartitionCount;
	}
	std::string lastErrorData() const;

	bool m_isWii;

	static const uint8_t s_truchaSignature[256];

	int m_generalPartitionCount;
	std::vector<WiiPartition> m_partitions;

	//struct tree *tree;

	struct _stat st;

	int nfiles;
	largesize_t nbytes;

	int m_partitionCount;
	int m_channelCount;

	offset_t m_partTblOffset;
	offset_t m_chanTblOffset;

	AES_KEY m_key;


	std::string m_lastErrorData;

	std::auto_ptr<FileStream> m_stream;	
	// save the tables instead of reading and writing them all the time
	uint8_t m_h3[SIZE_H3];
	uint8_t m_h4[SIZE_H4];
	PartitionHeader m_header;
	int m_currentPartition;
	IProgressHandler* m_progressHandler;
	static DummyProgressHandler s_dummyProgressHandler;
};

}
