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

        node->data.name   = name;
        node->data.dataType   = data_type;
        node->data.subtype     = subtype;
        return node;
    }
    PNode addItemToTree(PNode parent, CString name, uint32 part, u64 offset, u64 size, int fst_reference, int data_type = dataFile){
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

uint16 be16 (const uint8 *p);
uint32 be32 (const uint8 *p);
u64 be64 (const uint8 *p);

extern uint8 verbose_level;
size_t g_strnlen (const char *s, size_t size);
uint32 get_dol_size (const uint8 *header);





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
        u32 cid;
        u16 index;
        u16 type;
        u64 size;
        u8 hash[20];
};

struct Tmd 
{
        TmdSigType sigType;
        u8 *sig;
        char issuer[64];
        u8 version;
        u8 ca_crl_version;
        u8 signer_crl_version;
        u64 sys_version;
        u64 title_id;
        u32 title_type;
        u16 group_id;
        u32 access_rights;
        u16 title_version;
        u16 num_contents;
        u16 boot_index;
        struct TmdContent *contents;
};
*/


/*
struct PartitionHeader 
{
        char console;
        u8 isGamecube;
        u8 isWii;

        char gamecode[2];
        char region;
        char publisher[2];

        u8 hasMagic;
        char name[0x60];

        u64 dolOffset;
        u64 dol_size;

        u64 fstOffset;
        u64 fstSize;
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
        u64 offset;
        PartitionHeader header;
        u64 appldr_size;
        u8 isEncrypted;
        u64 tmdOffset;
        u64 tmdSize;
        Tmd* tmd;
		u64	h3_offset;

        char title_id_str[17];

        enum PartitionType type;
        char chan_id[5];

        char key_c[35];
        AES_KEY key;

		u8 title_key[16];

        u64 data_offset;
        u64 data_size;

        u64 cert_offset;
        u64 cert_size;

        u8 dec_buffer[0x8000];

        u32 cached_block;
        u8 cache[0x7c00];
};
*/

/*****************************************/


class WiiDisc
{
public:
	largesize_t findRequiredFreeSpaceInPartition(struct ImageFile *image, u64 nPartition, uint32 nRequiredSize);
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

	void aes_cbc_dec(uint8 *in, uint8 *out, uint32 len, uint8 *key, uint8 *iv);
	void aes_cbc_enc(uint8 *in, uint8 *out, uint32 len, uint8 *key, uint8 *iv);
	void sha1(uint8 *data, uint32 len, uint8 *hash);

	bool wii_write_data_file(int partition, offset_t offset, largesize_t size, uint8 *in, std::FILE * fIn= NULL, IWiiDiscProcessHandler* _ProgressBox = NULL);
	bool wii_write_clusters(int partition, int cluster,  uint8 *in, uint32 nClusterOffset, uint32 nBytesToWrite, std::FILE * fIn);
	int wii_read_data(int partition, u64 offset, uint32 size, uint8 **out);
	bool wii_read_cluster_hashes(int partition, int cluster, uint8 *h0, uint8 *h1, uint8 *h2);
	int wii_write_cluster(int partition, int cluster, uint8 *in);
	int wii_read_cluster(int partition, int cluster, uint8 *data, uint8 *header);
	bool wii_calc_group_hash(int partition, int cluster);
	int wii_nb_cluster(int partition);

	bool wii_trucha_signing(int partition);
	bool discWriteDirect(offset_t offset, void* data, largesize_t size);
	void markAsUnused(offset_t offset, largesize_t size);
	bool mergeAndRelocateFSTs(unsigned char *pFST1, uint32 nSizeofFST1, unsigned char *pFST2, uint32 nSizeofFST2, unsigned char *pNewFST,  uint32 * nSizeofNewFST, u64 nNewOffset, u64 nOldOffset);
	bool TruchaScrub(struct ImageFile * image, unsigned int nPartition);
	bool RecreateOriginalFile(const std::string& csScrubbedName, const std::string& csDIFName, const std::string& csOutName);
	bool CheckAndLoadKey(bool bLoadCrypto = false, struct ImageFile *image = NULL);
	bool SaveDecryptedFile(CString csDestinationFilename,  struct ImageFile *image,
							uint32 part, u64 nFileOffset, u64 nFileSize, bool bOverrideEncrypt = false);
	bool LoadDecryptedFile(CString csDestinationFilename,  struct ImageFile *image,
							uint32 part, u64 nFileOffset, u64 nFileSize, int nFSTReference, IWiiDiscProcessHandler* _ProgressBox = NULL);
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

	uint8			image_parse_header (struct PartitionHeader *header, uint8 *buffer);
	struct ImageFile *	image_init (const char *filename, int file_p = 0);
	int			image_parse (struct ImageFile *image);
	void			image_deinit (struct ImageFile *image, bool close_file = true);
	uint32			parse_fst (uint8 *fst, const char *names, uint32 i, struct tree *tree, struct ImageFile *image, uint32 part, PNode hParent);
	uint8			get_partitions (struct ImageFile *image);
	void			tmd_load (struct ImageFile *image, uint32 part);
	int			io_read (void *ptr, size_t size, struct ImageFile *image, u64 offset);
	size_t			io_read_part (void* ptr, size_t size, struct ImageFile *image, uint32 part, u64 offset);
	int			decrypt_block (struct ImageFile *image, uint32 part, uint32 block);


CString	m_csText;


private:
	IWiiDiscProcessHandler* m_progressHandler;
	ImageFile* m_imageFile;


	uint32 parse_fst_and_save(uint8 *fst, const char *names, uint32 i, ImageFile *image, uint32 part);

	u64 findFirstData(u64 nStartOffset,  u64 nLength, bool bUsed = true);
	bool CopyDiscDataDirect(struct ImageFile * image, int nPart, u64 nSource, u64 nDest, u64 nLength);
	u64 SearchBackwards(u64 nStartPosition, u64 nEndPosition);
	void FindFreeSpaceInPartition(_int64 nPartOffset, u64 * pStart, u64 * pSize);
	void Write32( uint8 *p, uint32 nVal);

	CString m_filename;
};

}

#endif // _WIIDISC_H__

#endif