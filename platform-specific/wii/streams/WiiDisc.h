#if 0

#ifndef _WIIDISC_H__
#define _WIIDISC_H__

#ifndef __BORLANDC__
//#   include <inttypes.h>
#   include <cstdio>
#endif

#include "Stream.h"
#include "WiiImage.h"

//typedef __int64 _int64;
//typedef unsigned int DWORD;

//typedef bool bool;
//#define FALSE false
//#define TRUE  true


#ifdef __BORLANDC__
#   include <windows.h>
#   define _chdir chdir
//#define _lseeki64 _lseek
__int64 _lseeki64(int __handle, __int64 __offset, int __fromwhere){
	LARGE_INTEGER new_offset;
	new_offset.QuadPart = (LONGLONG)0;
	if(SetFilePointerEx((HANDLE)__handle, *((LARGE_INTEGER*)&__offset), &new_offset, (DWORD)__fromwhere)){
		return (__int64)new_offset.QuadPart;
	} else {
		return -1;
	}
}

int _read(int fd, void *buffer, unsigned int count){
	unsigned long readed;
	if(!ReadFile((HANDLE)fd, buffer, count, &readed, NULL)){
		return -1;
	} else {
		return (int)readed;
	}
}

int _open(const char *filename, int oflag){
	OFSTRUCT tmp_struct;
	return OpenFile(filename, &tmp_struct, oflag & 3);
}

int _close(int handle){
	return !CloseHandle((HANDLE)handle);
}

int _write(int fd, const void *buffer, unsigned int count){
	unsigned long writed;
	if(!WriteFile((HANDLE)fd, buffer, count, &writed, NULL)){
		return -1;
	} else {
		return (int)writed;
	}
}

#else

#  include <io.h>
#  include <fcntl.h>

#endif


//#include "stdafx.h"
//#include <sys/types.h>
//#include <sys/stat.h>
#include <string>
#include <tree.h>
#include <iostream>
//#include <..\streams\iso_stream.h>
//using namespace std;

//#define CString std::string


namespace Consolgames
{


class CWIIScrubberDlg
{
	Tree<FileInfo> m_directoryTree;
public:
	PNode findFile(PNode folder, const CString& name);
	PNode FindDataPartition();
	CWIIScrubberDlg()
	{
	}
	
	~CWIIScrubberDlg()
	{
	}

	const Tree<FileInfo>& directories()
	{
	  return m_directoryTree;
	}

	PNode addItemToTree(PNode parent, const char* name, int data_type = dataFile, int subtype = 0)
	{
		PNode node;
		if(parent)
		{
			node = parent->addChild();
		}
		else 
		{
			node = m_directoryTree.addChild();
		}
		//memset(&node->data, 0, sizeof(CFileInfo));

		node->data.name      = name;
		node->data.dataType  = data_type;
		node->data.subtype   = subtype;
		return node;
	}
	PNode addItemToTree(PNode parent, CString name, uint32_t part, uint64_t offset, uint64_t size, int fst_reference, int data_type = dataFile){
		PNode node = parent->addChild();
		node->data.name   = name;
		node->data.partition   = part;
		node->data.size   = size;
		node->data.offset = offset;
		node->data.fstReference = fst_reference;
		node->data.dataType   = data_type;
		return node;
	}
	void ClearTree()
	{
		m_directoryTree.clear();
	}
};

#include "include/openssl/aes.h"

//#include "global.h"	// Added by ClassView
//#include "ProgressBox.h"


#ifdef __BORLANDC__

void AfxMessageBox(const CString& s)
{
	MessageBox(NULL, s.data(), "WiiDisc", MB_ICONWARNING);
}
#else

#   define AfxMessageBox(ignore)((void)0)

#endif


#ifdef __BORLANDC__
#   define _file fd
#endif

uint16 be16 (const uint8_t *p);
uint32_t be32 (const uint8_t *p);
uint64_t be64 (const uint8_t *p);

extern uint8_t verbose_level;
size_t g_strnlen (const char *s, size_t size);
uint32_t get_dol_size (const uint8_t *header);





/*****************************************/

#include <sys/types.h>
#include <sys/stat.h>
//#include "global.h"
//#include "aes.h"


/*
enum TmdSigType 
{
	SIG_UNKNOWN = 0,
	SIG_RSA_2048,
	SIG_RSA_4096
};

struct TmdContent
{
	uint32_t cid;
	uint16 index;
	uint16 type;
	uint64_t size;
	uint8_t hash[20];
};

struct Tmd 
{
	TmdSigType sigType;
	uint8_t *sig;
	char issuer[64];
	uint8_t version;
	uint8_t ca_crl_version;
	uint8_t signer_crl_version;
	uint64_t sys_version;
	uint64_t title_id;
	uint32_t title_type;
	uint16 group_id;
	uint32_t access_rights;
	uint16 title_version;
	uint16 num_contents;
	uint16 boot_index;
	struct TmdContent *contents;
};
*/


/*
struct PartitionHeader 
{
	char console;
	uint8_t isGamecube;
	uint8_t isWii;

	char gamecode[2];
	char region;
	char publisher[2];

	uint8_t hasMagic;
	char name[0x60];

	uint64_t dolOffset;
	uint64_t dol_size;

	uint64_t fstOffset;
	uint64_t fstSize;
};

enum PartitionType
{
	PART_UNKNOWN = 0,
	PART_DATA,
	PART_UPDATE,
	PART_INSTALLER,
	PART_VC
};

struct Partition
{
	uint64_t offset;
	PartitionHeader header;
	uint64_t appldr_size;
	uint8_t isEncrypted;
	uint64_t tmdOffset;
	uint64_t tmdSize;
	Tmd* tmd;
	uint64_t	h3_offset;

	char title_id_str[17];

	enum PartitionType type;
	char chan_id[5];

	char key_c[35];
	AES_KEY key;

	uint8_t title_key[16];

	uint64_t data_offset;
	uint64_t data_size;

	uint64_t cert_offset;
	uint64_t cert_size;

	uint8_t dec_buffer[0x8000];

	uint32_t cached_block;
	uint8_t cache[0x7c00];
};
*/

/*****************************************/


class WiiDisc
{
public:
	largesize_t findRequiredFreeSpaceInPartition(struct ImageFile *image, uint64_t nPartition, uint32_t nRequiredSize);
	bool checkForFreeSpace(int partition, offset_t offset, int blockCount);
	bool extractPartitionFiles(int partition, const std::string& directory);
	bool doPartitionShrink(int partition);
	bool loadDecryptedPartition(const std::string& name, int partition);
	bool saveDecryptedPartition(const std::string& filename, int partition);
	bool doTheShuffle();
	offset_t freePartitionStart();
	offset_t freeSpaceAtEnd();
	bool addPartition(bool channel, offset_t offset, largesize_t dataSize, const char* text);
	bool setBootMode();
	offset_t nImageSize;

	void aes_cbc_dec(uint8_t *in, uint8_t *out, uint32_t len, uint8_t *key, uint8_t *iv);
	void aes_cbc_enc(uint8_t *in, uint8_t *out, uint32_t len, uint8_t *key, uint8_t *iv);
	void sha1(uint8_t *data, uint32_t len, uint8_t *hash);

	bool wii_write_data_file(int partition, offset_t offset, largesize_t size, uint8_t *in, std::FILE * fIn= NULL, IWiiDiscProcessHandler* _ProgressBox = NULL);
	bool wii_write_clusters(int partition, int cluster,  uint8_t *in, uint32_t nClusterOffset, uint32_t nBytesToWrite, std::FILE * fIn);
	int wii_read_data(int partition, uint64_t offset, uint32_t size, uint8_t **out);
	bool wii_read_cluster_hashes(int partition, int cluster, uint8_t *h0, uint8_t *h1, uint8_t *h2);
	int wii_write_cluster(int partition, int cluster, uint8_t *in);
	int wii_read_cluster(int partition, int cluster, uint8_t *data, uint8_t *header);
	bool wii_calc_group_hash(int partition, int cluster);
	int wii_nb_cluster(int partition);

	bool wii_trucha_signing(int partition);
	bool discWriteDirect(offset_t offset, void* data, largesize_t size);
	void markAsUnused(offset_t offset, largesize_t size);
	bool mergeAndRelocateFSTs(unsigned char *pFST1, uint32_t nSizeofFST1, unsigned char *pFST2, uint32_t nSizeofFST2, unsigned char *pNewFST,  uint32_t * nSizeofNewFST, uint64_t nNewOffset, uint64_t nOldOffset);
	bool TruchaScrub(struct ImageFile * image, unsigned int nPartition);
	bool RecreateOriginalFile(const std::string& csScrubbedName, const std::string& csDIFName, const std::string& csOutName);
	bool CheckAndLoadKey(bool bLoadCrypto = false, struct ImageFile *image = NULL);
	bool SaveDecryptedFile(CString csDestinationFilename,  struct ImageFile *image,
							uint32_t part, uint64_t nFileOffset, uint64_t nFileSize, bool bOverrideEncrypt = false);
	bool LoadDecryptedFile(CString csDestinationFilename,  struct ImageFile *image,
							uint32_t part, uint64_t nFileOffset, uint64_t nFileSize, int nFSTReference, IWiiDiscProcessHandler* _ProgressBox = NULL);
	void Reset(void);
	void markAsUsed(offset_t offset, largesize_t size);
	void markAsUsedDC(offset_t partitionOffset, offset_t offset, largesize_t size, bool isEncrypted);

	bool CleanupISO(CString csFileIn, CString csFileOut, int nMode, int nHeaderMode = 0);
	unsigned int CountBlocksUsed();
	WiiDisc(void* pParent);
	virtual ~WiiDisc();

	//unsigned char * pFreeTable;
	std::vector<bool> m_freeMap;
	unsigned char * pBlankSector;
	unsigned char * pBlankSector0;

	class CWIIScrubberDlg * m_pParent;

	//HTREEITEM	hPartition[20];
	//HTREEITEM	hDisc;
	PNode hPartition[20];
	PNode hDisc;

	uint8_t			image_parse_header (struct PartitionHeader *header, uint8_t *buffer);
	struct ImageFile *	image_init (const char *filename, int file_p = 0);
	int			image_parse (struct ImageFile *image);
	void			image_deinit (struct ImageFile *image, bool close_file = true);
	uint32_t			parse_fst (uint8_t *fst, const char *names, uint32_t i, struct tree *tree, struct ImageFile *image, uint32_t part, PNode hParent);
	uint8_t			get_partitions (struct ImageFile *image);
	void			tmd_load (struct ImageFile *image, uint32_t part);
	int			io_read (void *ptr, size_t size, struct ImageFile *image, uint64_t offset);
	size_t			io_read_part (void* ptr, size_t size, struct ImageFile *image, uint32_t part, uint64_t offset);
	int			decrypt_block (struct ImageFile *image, uint32_t part, uint32_t block);


CString	m_csText;


private:
	IWiiDiscProcessHandler* m_progressHandler;
	ImageFile* m_imageFile;


	uint32_t parse_fst_and_save(uint8_t *fst, const char *names, uint32_t i, ImageFile *image, uint32_t part);

	uint64_t findFirstData(uint64_t nStartOffset,  uint64_t nLength, bool bUsed = true);
	bool CopyDiscDataDirect(struct ImageFile * image, int nPart, uint64_t nSource, uint64_t nDest, uint64_t nLength);
	uint64_t SearchBackwards(uint64_t nStartPosition, uint64_t nEndPosition);
	void FindFreeSpaceInPartition(_int64 nPartOffset, uint64_t * pStart, uint64_t * pSize);
	void Write32( uint8_t *p, uint32_t nVal);

	CString m_filename;
};

}

#endif // _WIIDISC_H__

#endif