#if 0

// WIIDisc.cpp: implementation of the CWIIDisc class.
//
//////////////////////////////////////////////////////////////////////

//#include "stdafx.h"
//#include "WIIScrubber.h"
#include "WIIDisc.h"
//#include "ProgressBox.h"
//#include "ResizePartition.h"
//#include "BootMode.h"
#include "openssl/ssl.h"
#include <direct.h>
#include <fcntl.h>
#include <limits.h>

#include <vector>
#include <iostream>

//#define ASSERT(...) ;
//#define DLOG std::cout
/*

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif
*/

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////
//#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <sys/types.h>

#ifdef __BORLANDC__
#   include <windows.h>
#endif


namespace Consolgames
{
	
PNode CWIIScrubberDlg::findFile(PNode folder, const std::string& name)
{
	if (!folder)
	{
		folder = &m_directoryTree;
	}
	PNode result = NULL, node = folder->firstChild();
	while(node)
	{
		if(node->data.dataType == dataFile)
		{
			if(node->data.name == name)
			{
				return node;
			}
		}
		else
		{
			if((result = findFile(node, name)))
			{
				return result;
			}
		}
		node = node->next();
	}
	return result;
}

PNode CWIIScrubberDlg::FindDataPartition()
{
	PNode node = m_directoryTree.firstChild();
	if(!node) return NULL;
	else node = node->firstChild();
	while(node)
	{
		if(node->data.dataType == dataPartition && node->data.subtype == PART_DATA)
		{
			return node;
		}
		node = node->next();
	}
	return NULL;
}

/******* FROM stdafx.h *********/

uint8_t verbose_level = 0;

uint16 be16 (const uint8_t *p)
{
	return (p[0] << 8) | p[1];
}

uint32_t be32 (const uint8_t *p)
{
	return (p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3];
}

uint64_t be64 (const uint8_t *p)
{
	return ((uint64_t) be32 (p) << 32) | be32 (p + 4);
}


size_t g_strnlen (const char *s, size_t size)
{
	size_t i;

	for (i = 0; i < size; ++i)
		if (s[i] == 0)
			return i;

	return size;
}

uint32_t get_dol_size (const uint8_t *header)
{
	uint8_t i;
	uint32_t offset, size;
	uint32_t max = 0;

	// iterate through the 7 code segments
	for (i = 0; i < 7; ++i)
	{
		offset = be32 (&header[i * 4]);
		size = be32 (&header[0x90 + i * 4]);
		if (offset + size > max)
			max = offset + size;
	}

	// iterate through the 11 data segments
	for (i = 0; i < 11; ++i)
	{
		offset = be32 (&header[0x1c + i * 4]);
		size = be32 (&header[0xac + i * 4]);
		if (offset + size > max)
			max = offset + size;
	}

	return max;
}

/******* FROM stdafx.h *********/

//#include "global.h"
//#include "WIIScrubberDlg.h"

/* Trucha signature */
uint8_t trucha_signature[256] =
{
	0x57, 0x61, 0x4E, 0x69, 0x4E, 0x4B, 0x6F, 0x4B,
	0x4F, 0x57, 0x61, 0x53, 0x48, 0x65, 0x52, 0x65,
	0x21, 0x8A, 0xB5, 0xBC, 0x89, 0x00, 0x8E, 0x5C,
	0x2B, 0xB6, 0x3E, 0x4D, 0x0A, 0xD7, 0xD2, 0xC4,
	0x97, 0x36, 0x82, 0xDF, 0x57, 0x06, 0x37, 0x27,
	0x96, 0xF1, 0x40, 0xD6, 0xCD, 0x36, 0xE4, 0xEE,
	0xC0, 0x99, 0xAA, 0x49, 0x99, 0x38, 0xA5, 0xC5,
	0xEE, 0xE3, 0x12, 0xF8, 0xBB, 0xE4, 0xBC, 0x52,
	0x1A, 0x3F, 0x31, 0x71, 0x45, 0x68, 0x98, 0xDB,
	0x5A, 0xD9, 0xB2, 0x27, 0x0F, 0x96, 0x15, 0xCF,
	0x2F, 0xBF, 0x18, 0xC8, 0xF7, 0xBD, 0x8D, 0xE5,
	0xA1, 0x9F, 0xDE, 0x5C, 0x83, 0x9A, 0xAE, 0x9D,
	0xD9, 0xDF, 0x0F, 0x1E, 0x47, 0xA7, 0xFA, 0xA1,
	0x80, 0xAC, 0xC8, 0x8F, 0x42, 0xDD, 0x5E, 0x71,
	0x9C, 0x76, 0x39, 0x93, 0x34, 0xC7, 0x79, 0xD5,
	0x66, 0x57, 0x31, 0xEA, 0xF1, 0xDF, 0x87, 0xCB,
	0xBE, 0x96, 0xE9, 0x05, 0x3E, 0xE3, 0xA7, 0xBE,
	0x8F, 0x6F, 0x4E, 0xD1, 0x4D, 0xAC, 0x42, 0xE9,
	0x23, 0x7C, 0x7D, 0x57, 0x43, 0xF6, 0x2C, 0xA9,
	0x4D, 0x5D, 0x93, 0x3E, 0x3C, 0x1B, 0x09, 0xFA,
	0xB1, 0xF3, 0xFF, 0xEF, 0xD6, 0xA6, 0xAE, 0x66,
	0x16, 0xFC, 0x37, 0x63, 0xA8, 0x7A, 0x4C, 0xCB,
	0xF6, 0xC9, 0x22, 0x39, 0xBF, 0x4E, 0xE2, 0x0C,
	0xAB, 0x76, 0x4B, 0xE7, 0x91, 0x54, 0xE1, 0x42,
	0x47, 0xE1, 0x32, 0x1E, 0x87, 0xE0, 0x84, 0x9D,
	0xDC, 0xBB, 0x00, 0x84, 0x35, 0x4D, 0x50, 0x2B,
	0x16, 0x72, 0x64, 0xD6, 0xC1, 0x47, 0xE2, 0x6C,
	0xBD, 0x2D, 0x54, 0x4E, 0x82, 0x35, 0x90, 0xC9,
	0x16, 0xC2, 0xE7, 0x9E, 0xA2, 0x6B, 0x3B, 0x7E,
	0x27, 0x3C, 0x03, 0x5C, 0x89, 0x53, 0x88, 0x9F,
	0xC5, 0xEC, 0x75, 0x86, 0x33, 0x58, 0xF3, 0xF0,
	0x85, 0x47, 0x3E, 0x07, 0x7C, 0xCF, 0xD1, 0x93
};

WiiDisc::WiiDisc(void* pParent)
	: m_freeMap(143432 * 2, false)
{
	m_pParent = new CWIIScrubberDlg;

	// create and blank the wii blank table
	//pFreeTable = (unsigned char *) malloc(143432*2);//malloc((4699979776 / 0x8000) * 2);
	//set them all to clear first
	//memset(pFreeTable, 0, /*(4699979776 / 0x8000)*/143432*2);
	// then set the header size to used
	markAsUsed(0, 0x40000);

	pBlankSector = (unsigned char *) malloc(0x8000);
	memset(pBlankSector, 0xFF, 0x8000);

	pBlankSector0 = (unsigned char *) malloc(0x8000);
	memset (pBlankSector0, 0, 0x8000);


	for (int i = 0; i < 20; i++)
	{
		hPartition[i] = NULL;
	}
	hDisc = NULL;

	// then clear the decrypt key
	uint8_t key[16];

	memset(key,0,16);

	AES_KEY nKey;

	memset(&nKey, 0, sizeof(AES_KEY));
	AES_set_decrypt_key (key, 128, &nKey);

}

WiiDisc::~WiiDisc()
{
	// free up the memory
	free(pBlankSector);
	free(pBlankSector0);
	delete m_pParent;

}

/*
uint8_t WiiDisc::image_parse_header (struct PartitionHeader *header, uint8_t *buffer)
{
	memset (header, 0, sizeof (struct PartitionHeader));

	header->console = buffer[0];

	// account for the Team Twizlers gotcha
	//if (false==m_pParent->m_bFORCEWII)
	//{
	header->is_gc = (header->console == 'G') ||
					(header->console == 'D') ||
					(header->console == 'P') ||
					(header->console == 'U');
	header->is_wii = (header->console == 'R') ||
					 (header->console == '_') ||
					 (header->console == 'H') ||
					 (header->console == '0') ||
					 (header->console == '4');
	//}
	//else
	//{
	//	header->is_gc = false;
	//	header->is_wii = true;
	//}

	header->gamecode[0] = buffer[1];
	header->gamecode[1] = buffer[2];
	header->region = buffer[3];
	header->publisher[0] = buffer[4];
	header->publisher[1] = buffer[5];

	header->has_magic = be32 (&buffer[0x18]) == 0x5d1c9ea3;
	strncpy (header->name, (char *) (&buffer[0x20]), 0x60);

	header->dol_offset = be32 (&buffer[0x420]);

	header->fst_offset = be32 (&buffer[0x424]);
	header->fst_size = be32 (&buffer[0x428]);

	if (header->is_wii)
	{
		header->dol_offset *= 4;
		header->fst_offset *= 4;
		header->fst_size *= 4;
	}

	return header->is_gc || header->is_wii;
}
*/

uint32_t WiiDisc::parse_fst(uint8_t *fst, const char *names, uint32_t i, struct tree *tree, uint32_t part, PNode pParent)
{
	uint64_t offset;
	uint32_t size;
	const char *name;
	uint32_t j;

	name = names + (be32 (fst + 12 * i) & 0x00ffffff);
	size = be32 (fst + 12 * i + 8);

	if (i == 0)
	{
		// directory so need to go through the directory entries
		for (j = 1; j < size; )
		{
			j = parse_fst (fst, names, j, tree, part, pParent);
		}
		return size;
	}

	if (fst[12 * i])
	{
		m_csText += name;
		m_csText += "\\";
		AddToLog(m_csText);
		//pParent = m_pParent->AddItemToTree(name, pParent);
		pParent = m_pParent->addItemToTree(pParent, name);

		for (j = i + 1; j < size; )
			j = parse_fst (fst, names, j, NULL, part, pParent);
		// now remove the directory name we just added
		// ---m_csText = m_csText.Left(m_csText.GetLength()-strlen(name) - 1);
		m_csText = m_csText.substr(0, m_csText.length() - strlen(name) - 1);
		return size;
	}
	else
	{
		offset = be32(fst + 12 * i + 4);
		if (m_imageFile->parts[part].header.is_wii)
			offset *= 4;

		/*
		CString	csTemp;
		csTemp.Format("%s [0x%lX] [0x%I64X] [0x%lX] [%d]",  name,
							  part,
			  offset,
			  size,
			  i
							);

		*/
		m_pParent->addItemToTree(pParent, name, part, offset, size, i);

		//csTemp.Format("%s%s", m_csText, name);
		//AddToLog(csTemp, image->parts[part].offset + offset, size);

		markAsUsedDC(m_imageFile->parts[part].offset + m_imageFile->parts[part].data_offset, offset, size, image->parts[part].isEncrypted);

		m_imageFile->nfiles++;
		m_imageFile->nbytes += size;
		return i + 1;
	}
}


uint32_t WiiDisc::parse_fst_and_save(uint8_t *fst, const char *names, uint32_t i, ImageFile *image, uint32_t part)
{
	//MSG msg;
	uint64_t offset;
	uint32_t size;
	const char *name;
	uint32_t j;
	CString	csTemp;

	name = names + (be32 (fst + 12 * i) & 0x00ffffff);
	size = be32 (fst + 12 * i + 8);

	m_progressHandler->setPosition(i);

	if (i == 0)
	{
		// directory so need to go through the directory entries
		for (j = 1; j < size; )
		{
			j = parse_fst_and_save(fst, names, j, image, part);
		}
		if (j!=0xFFFFFFFF)
		{
			return size;
		}
		else
		{
			return 0xFFFFFFFF;
		}
	}

	if (fst[12 * i])
	{
		// directory so....
		// create a directory and change to it
		_mkdir(name);
		_chdir(name);


		for (j = i + 1; j < size; )
		{
			j = parse_fst_and_save(fst, names, j, image, part);
		}

		// now remove the directory name we just added
		//m_csText = m_csText.Left(m_csText.GetLength()-strlen(name) - 1);
		m_csText = m_csText.substr(0, m_csText.length()-strlen(name) - 1);
		_chdir("..");
		if (j!=0xFFFFFFFF)
		{
			return size;
		}
		else
		{
			return 0xFFFFFFFF;
		}
	}
	else
	{
		// it's a file so......
		// create a filename and then save it out

		offset = be32(fst + 12 * i + 4);
		if (image->parts[part].header.isWii)
		{
			offset *= 4;
		}

		// now save it
		if (SaveDecryptedFile(name, image, part, offset, size))
		{
			return i + 1;
		}
		else
		{
			// Error writing file
			return 0xFFFFFFFF;
		}
	}
}

uint8_t WiiDisc::get_partitions (struct ImageFile *image)
{
	uint8_t buffer[16];
	uint64_t part_tbl_offset;
	uint64_t chan_tbl_offset;
	uint32_t i;

	uint8_t title_key[16];
	uint8_t iv[16];
	uint8_t partition_key[16];

	uint32_t nchans;


	// clear out the old memory allocated
	if (NULL!=image->parts)
	{
		free (image->parts);
		image->parts = NULL;
	}
	io_read (buffer, 16, image, 0x40000);
	image->nparts = 1 + be32 (buffer);

	nchans = be32 (&buffer[8]);

	// number of partitions is out by one
	DLOG << "number of partitions: " << image->nparts;
	DLOG << "number of channels: " <<  nchans;

	// store the values for later bit twiddling
	image->ChannelCount = nchans;
	image->PartitionCount = image->nparts -1;

	image->nparts += nchans;


	part_tbl_offset = uint64_t (be32 (&buffer[4])) * ((uint64_t)(4));
	chan_tbl_offset = (uint64_t )(be32 (&buffer[12])) * ((uint64_t) (4));
	DLOG << "Partition table offset: " << part_tbl_offset;
	DLOG << "Channel table offset: " << chan_tbl_offset;

	image->part_tbl_offset = part_tbl_offset;
	image->chan_tbl_offset = chan_tbl_offset;

	image->parts = (struct Partition *)
				   malloc (image->nparts * sizeof (struct Partition));
	memset (image->parts, 0, image->nparts * sizeof (struct Partition));

	for (i = 1; i < image-> nparts ; ++i)
	{
		AddToLog("--------------------------------------------------------------------------");
		AddToLog("partition:", i);

		if (i < image->nparts - nchans)
		{
			io_read (buffer, 8, image,
					 part_tbl_offset + (i - 1) * 8);

			switch (be32 (&buffer[4]))
			{
			case 0:
				image->parts[i].type = PART_DATA;
				break;

			case 1:
				image->parts[i].type = PART_UPDATE;
				break;

			case 2:
				image->parts[i].type = PART_INSTALLER;
				break;

			default:
				break;
			}

		}
		else
		{
			DLOG << "Virtual console";

			// error in WiiFuse as it 'assumes' there are only two
			// partitions before VC games

			// changed to a generic version
			io_read(buffer, 8, image,
					 chan_tbl_offset + (i - image->PartitionCount - 1) * 8);

			image->parts[i].type = PART_VC;
			image->parts[i].chan_id[0] = buffer[4];
			image->parts[i].chan_id[1] = buffer[5];
			image->parts[i].chan_id[2] = buffer[6];
			image->parts[i].chan_id[3] = buffer[7];
		}

		image->parts[i].offset = (uint64_t)(be32 (buffer)) * ((uint64_t)(4));

		AddToLog("partition offset: ", image->parts[i].offset);

		// mark the block as used
		markAsUsed(image->parts[i].offset, 0x8000);


		io_read (buffer, 8, image, image->parts[i].offset + 0x2b8);
		image->parts[i].data_offset = (uint64_t)(be32 (buffer)) << 2;
		image->parts[i].data_size = (uint64_t)(be32 (&buffer[4])) << 2;

		// now get the H3 offset
		io_read (buffer,4, image, image->parts[i].offset + 0x2b4);
		image->parts[i].h3_offset = (uint64_t)(be32 (buffer)) << 2 ;

		AddToLog("partition data offset:", image->parts[i].data_offset);
		AddToLog("partition data size:", image->parts[i].data_size);
		AddToLog("H3 offset:", image->parts[i].h3_offset);

		tmd_load (image, i);
		if (image->parts[i].tmd == NULL)
		{
			AddToLog("partition has no valid tmd");

			continue;
		}

		//sprintf (image->parts[i].title_id_str, "%016llx",
		sprintf (image->parts[i].title_id_str, "%016I64x",
				 image->parts[i].tmd->title_id);

		image->parts[i].isEncrypted = 1;
		image->parts[i].cached_block = 0xffffffff;

		memset (title_key, 0, 16);
		memset (iv, 0, 16);

		io_read (title_key, 16, image, image->parts[i].offset + 0x1bf);
		io_read (iv, 8, image, image->parts[i].offset + 0x1dc);


		AES_cbc_encrypt (title_key, partition_key, 16,
						 &image->key, iv, AES_DECRYPT);

		memcpy(image->parts[i].title_key, partition_key, 16);

		AES_set_decrypt_key (partition_key, 128, &image->parts[i].key);

		sprintf (image->parts[i].key_c, "0x"
				 "%02x%02x%02x%02x%02x%02x%02x%02x"
				 "%02x%02x%02x%02x%02x%02x%02x%02x",
				 partition_key[0], partition_key[1],
				 partition_key[2], partition_key[3],
				 partition_key[4], partition_key[5],
				 partition_key[6], partition_key[7],
				 partition_key[8], partition_key[9],
				 partition_key[10], partition_key[11],
				 partition_key[12], partition_key[13],
				 partition_key[14], partition_key[15]);


	}

	return image->nparts == 0;
}
/*
struct ImageFile * WiiDisc::image_init (const char *filename, int file_p)
{
	int fp = file_p;
	struct ImageFile *image;
	struct PartitionHeader *header;

	//OFSTRUCT OpenBuff;

	uint8_t buffer[0x440];
	m_csFilename = "";

	if(!fp) fp = _open (filename, _O_BINARY | _O_RDWR);
	//fp = OpenFile(filename, &OpenBuff, OF_READ);
	if (fp <= 0)
	{
		AfxMessageBox(filename);
		return NULL;
	}
	// get the filesize and set the range accordingly for future
	// operations
	nImageSize = _lseeki64(fp, 0L, SEEK_END);

	image = (ImageFile*)malloc(sizeof(ImageFile));

	if (!image)
	{
		// LOG_ERR ("out of memory");
		::_close (fp);
		return NULL;
	}

	memset (image, 0, sizeof (struct ImageFile));
	image->fp = fp;

	if (!io_read (buffer, 0x440, image, 0))
	{
		AfxMessageBox("reading header");
		::_close (image->fp);
		free (image);
		return NULL;
	}

	header = (struct PartitionHeader *) (malloc (sizeof (struct PartitionHeader)));

	if (!header)
	{
		::_close (image->fp);
		free (image);
		// LOG_ERR ("out of memory");
		return NULL;
	}

	image_parse_header (header, buffer);

	if (!header->is_gc && !header->is_wii)
	{
		// LOG_ERR ("unknown type for file: %s", filename);
		::_close (image->fp);
		free (header);
		free (image);
		return NULL;
	}

	if (!header->has_magic)
	{
		AddToLog("image has an invalid magic");

	}

	image->is_wii = header->is_wii;

	if (header->is_wii)
	{

		if (!CheckAndLoadKey(true, image))
		{
			free (image);
			return NULL;
		}
	}

	// Runtime crash fixed :)
	// Identified by Juster over on GBATemp.net
	// the free was occuring before in the wrong location
	// As a free was being carried out and the next line was checking
	// a value it was pointing to
	free (header);
	return image;
};
*/
int WiiDisc::image_parse (struct ImageFile *image)
{
	uint8_t buffer[0x440];
	uint8_t *fst;
	uint32_t i;
	uint8_t j, valid, nvp;

	uint32_t nfiles;

	PNode hPartitionBin;

	CString csText;


	if (m_imageFile->isWii)
	{
		DLOG << "Wii image detected";
		hDisc = m_pParent->addItemToTree(NULL, "WII DISC", dataDisc);

		get_partitions (image);
	}
	else
	{
		DLOG << "Gamecube image detected";

		m_imageFile->parts = new Partition;
		
		m_imageFile->nparts = 1;
		m_imageFile->PartitionCount = 1;
		m_imageFile->ChannelCount = 0;
		m_imageFile->part_tbl_offset = 0;
		m_imageFile->chan_tbl_offset = 0;
		m_imageFile->parts[0].type = PART_DATA;
		hDisc = m_pParent->addItemToTree(NULL, "GAMECUBE DISC", dataDisc);
	}

	_fstat (image->fp, &image->st);


	nvp = 0;
	for (i = 0; i < image->nparts; ++i)
	{

		AddToLog("------------------------------------------------------------------------------");
		AddToLog("partition:", i);
		char tbuf[64];
		sprintf(tbuf, "Partition:%d", i);
		hPartition[i] = m_pParent->addItemToTree(hDisc, tbuf, dataPartition, image->parts[i].type);
		hPartition[i]->data.partition = i;

		if (!io_read_part (buffer, 0x440, image, i, 0))
		{
			AfxMessageBox("partition header");
			return 1;
		}
		valid = 1;
		for (j = 0; j < 6; ++j)
		{
			if (!isprint (buffer[j]))
			{
				valid = 0;
				break;
			}
		}

		if (!valid)
		{
			AddToLog("invalid header for partition:", i);
			continue;
		}
		nvp++;

		image_parse_header (&image->parts[i].header, buffer);

		if (PART_UNKNOWN!=image->parts[i].type)
		{
			AddToLog("\\partition.bin", image->parts[i].offset, image->parts[i].data_offset);
			//csText.Format("%s [0x%lX] [0x%I64X] [0x%I64X] [-4]", "partition.bin", i, image->parts[i].offset, image->parts[i].data_offset);
			markAsUsed(image->parts[i].offset, image->parts[i].data_offset);
			//hPartitionBin = m_pParent->AddItemToTree(csText, hPartition[i]);
			hPartitionBin = m_pParent->addItemToTree(hPartition[i], "partition.bin", i, image->parts[i].offset, image->parts[i].data_offset, -4, dataPartitionBin);
			// add on the boot.bin
			AddToLog("\\boot.bin", image->parts[i].offset + image->parts[i].data_offset, (uint64_t)0x440);
			markAsUsedDC(image->parts[i].offset + image->parts[i].data_offset, 0, (uint64_t)0x440, image->parts[i].isEncrypted);
			//csText.Format("%s [0x%lX] [0x%I64X] [0x%I64X] [0]", "boot.bin", i, (uint64_t) 0x0, (uint64_t)0x440);
			m_pParent->addItemToTree(hPartition[i], "boot.bin", i, (uint64_t)0, (uint64_t)0x440, 0, dataFile);


			// add on the bi2.bin
			AddToLog("\\bi2.bin", image->parts[i].offset + image->parts[i].data_offset + 0x440, (uint64_t)0x2000);
			markAsUsedDC(image->parts[i].offset + image->parts[i].data_offset, 0x440, (uint64_t)0x2000, image->parts[i].isEncrypted);
			//csText.Format("%s [0x%lX] [0x%I64X] [0x%I64X] [0]", "bi2.bin", i, (uint64_t) 0x440, (uint64_t)0x2000);
			//m_pParent->AddItemToTree(csText, hPartition[i]);
			m_pParent->addItemToTree(hPartition[i], "bi2.bin", i, 0x440, 0x2000, 0, dataFile);
		}
		io_read_part (buffer, 8, image, i, 0x2440 + 0x14);
		image->parts[i].appldr_size = be32 (buffer) + be32 (&buffer[4]);
		if (image->parts[i].appldr_size > 0)
		{
			image->parts[i].appldr_size += 32;
		}

		if (image->parts[i].appldr_size > 0)
		{
			AddToLog("\\apploader.img", image->parts[i].offset+ image->parts[i].data_offset +0x2440, image->parts[i].appldr_size);
			markAsUsedDC(	image->parts[i].offset + image->parts[i].data_offset, 0x2440, image->parts[i].appldr_size, image->parts[i].isEncrypted);
			//csText.Format("%s [0x%lX] [0x%I64X] [0x%I64X] [-3]", "apploader.img", i, (uint64_t) 0x2440, (uint64_t) image->parts[i].appldr_size);
			//m_pParent->AddItemToTree(csText, hPartition[i]);
			m_pParent->addItemToTree(hPartition[i], "apploader.img", i, 0x2440, image->parts[i].appldr_size, -3, dataFile);
		}
		else
		{
			AddToLog("apploader.img not present");
		}

		if (image->parts[i].header.dol_offset > 0)
		{
			io_read_part (buffer, 0x100, image, i, image->parts[i].header.dol_offset);
			image->parts[i].header.dol_size = get_dol_size (buffer);

			// now check for error condition with bad main.dol
			if (image->parts[i].header.dol_size >=image->parts[i].data_size)
			{
				// almost certainly an error as it's bigger than the partition
				image->parts[i].header.dol_size = 0;
			}
			markAsUsedDC(	image->parts[i].offset+ image->parts[i].data_offset,
							image->parts[i].header.dol_offset,
							image->parts[i].header.dol_size,
							image->parts[i].isEncrypted
						);

			AddToLog("\\main.dol ", image->parts[i].offset + image->parts[i].data_offset + image->parts[i].header.dol_offset, image->parts[i].header.dol_size);

			//csText.Format("%s [0x%lX] [0x%I64X] [0x%I64X] [-2]", "main.dol", i, image->parts[i].header.dol_offset, image->parts[i].header.dol_size);
			m_pParent->addItemToTree(hPartition[i], "main.dol", i, image->parts[i].header.dol_offset, image->parts[i].header.dol_size, -2, dataFile);
		}
		else
		{
			AddToLog("partition has no main.dol");
		}

		if (image->parts[i].isEncrypted)
		{
			// Now add the TMD.BIN and cert.bin files - as these are part of partition.bin
			// we don't need to mark them as used - we do put them undr partition.bin in the
			// tree though

			AddToLog("\\tmd.bin", image->parts[i].offset + image->parts[i].tmdOffset, image->parts[i].tmdSize);
			//csText.Format("%s [0x%lX] [0x%I64X] [0x%I64X] [-5]", "tmd.bin", i, image->parts[i].tmd_offset, image->parts[i].tmd_size);
			m_pParent->addItemToTree(hPartitionBin, "tmd.bin", i, image->parts[i].tmdOffset, image->parts[i].tmdSize, -5, dataFile);

			AddToLog("\\cert.bin", image->parts[i].offset + image->parts[i].cert_offset, image->parts[i].cert_size);
			//csText.Format("%s [0x%lX] [0x%I64X] [0x%I64X] [-6]", "cert.bin", i, (uint64_t)image->parts[i].cert_offset, (uint64_t)image->parts[i].cert_size);
			m_pParent->addItemToTree(hPartitionBin, "cert.bin", i, (uint64_t)image->parts[i].cert_offset, (uint64_t)image->parts[i].cert_size, -6, dataFile);

			// add on the H3
			AddToLog("\\h3.bin", image->parts[i].offset + image->parts[i].h3_offset, (uint64_t)0x18000);
			markAsUsedDC(	image->parts[i].offset, image->parts[i].h3_offset, (uint64_t)0x18000, false);

			//csText.Format("%s [0x%lX] [0x%I64X] [0x%I64X] [-7]", "h3.bin", i, (uint64_t) image->parts[i].h3_offset, (uint64_t)0x18000);

			m_pParent->addItemToTree(hPartitionBin, "h3.bin", i, (uint64_t) image->parts[i].h3_offset, (uint64_t)0x18000, -7, dataFile);
		}


		if (image->parts[i].header.fst_offset > 0 && image->parts[i].header.fst_size > 0)
		{
			AddToLog("\\fst.bin ", image->parts[i].offset+image->parts[i].data_offset+image->parts[i].header.fst_offset,image->parts[i].header.fst_size);

			markAsUsedDC( image->parts[i].offset+ image->parts[i].data_offset,
						  image->parts[i].header.fst_offset,
						  image->parts[i].header.fst_size,
						  image->parts[i].isEncrypted);
			//csText.Format("%s [0x%lX] [0x%I64X] [0x%I64X] [-1]", "fst.bin", i, image->parts[i].header.fst_offset, image->parts[i].header.fst_size);
			m_pParent->addItemToTree(hPartition[i], "fst.bin", i, image->parts[i].header.fst_offset, image->parts[i].header.fst_size, -1, dataFile);

			fst = (uint8_t *) (malloc ((uint32_t)(image->parts[i].header.fst_size)));
			if (io_read_part (fst, (uint32_t)(image->parts[i].header.fst_size), image, i, image->parts[i].header.fst_offset) != image->parts[i].header.fst_size)
			{
				AfxMessageBox("fst.bin");
				free (fst);
				return 1;
			}

			nfiles = be32 (fst + 8);

			if (12 * nfiles > image->parts[i].header.fst_size)
			{
				AddToLog("invalid fst for partition", i);
			}
			else
			{
				m_csText = "\\";
				parse_fst (fst, (char *) (fst + 12 * nfiles), 0,
						   NULL, image, i, hPartition[i]);
			}
			free (fst);
		}
		else
		{
			AddToLog("partition has no fst");
		}
	}

	if (!nvp)
	{
		AddToLog("no valid partition were found, exiting");
		return 1;
	}
	return 0;
}

/*
void WiiDisc::tmd_load (struct ImageFile *image, uint32_t part)
{
	struct tmd *tmd;
	uint32_t tmd_offset, tmd_size;
	enum TmdSigType sig = SIG_UNKNOWN;

	uint64_t off, cert_size, cert_off;
	uint8_t buffer[64];
	uint16 i, s;

	off = image->parts[part].offset;
	io_read (buffer, 16, image, off + 0x2a4);

	tmd_size = be32 (buffer);
	tmd_offset = be32 (&buffer[4]) * 4;
	cert_size = be32 (&buffer[8]);
	cert_off = be32 (&buffer[12]) * 4;

// TODO: ninty way?
	
//	 if (cert_size)
//			 image->parts[part].tmd_size =
//					 cert_off - image->parts[part].tmd_offset + cert_size;
	

	off += tmd_offset;

	io_read (buffer, 4, image, off);
	off += 4;

	switch (be32 (buffer))
	{
	case 0x00010001:
		sig = SIG_RSA_2048;
		s = 0x100;
		break;

	case 0x00010000:
		sig = SIG_RSA_4096;
		s = 0x200;
		break;
	}

	if (sig == SIG_UNKNOWN)
		return;

	tmd = (struct tmd *) malloc (sizeof (struct tmd));
	memset (tmd, 0, sizeof (struct tmd));

	tmd->sigType = sig;

	image->parts[part].tmd = tmd;
	image->parts[part].tmdOffset = tmd_offset;
	image->parts[part].tmdSize = tmd_size;

	image->parts[part].cert_offset = cert_off;
	image->parts[part].cert_size = cert_size;

	tmd->sig = (unsigned char *) malloc (s);
	io_read (tmd->sig, s, image, off);
	off += s;

	off = ROUNDUP64B(off);

	io_read ((unsigned char *)&tmd->issuer[0], 0x40, image, off);
	off += 0x40;

	io_read (buffer, 26, image, off);
	off += 26;

	tmd->version = buffer[0];
	tmd->ca_crl_version = buffer[1];
	tmd->signer_crl_version = buffer[2];

	tmd->sys_version = be64 (&buffer[4]);
	tmd->title_id = be64 (&buffer[12]);
	tmd->title_type = be32 (&buffer[20]);
	tmd->group_id = be16 (&buffer[24]);

	off += 62;

	io_read (buffer, 10, image, off);
	off += 10;

	tmd->access_rights = be32 (buffer);
	tmd->title_version = be16 (&buffer[4]);
	tmd->num_contents = be16 (&buffer[6]);
	tmd->boot_index = be16 (&buffer[8]);

	off += 2;

	if (tmd->num_contents < 1)
		return;

	tmd->contents =
		(struct TmdContent *)
		malloc (sizeof (struct TmdContent) * tmd->num_contents);

	for (i = 0; i < tmd->num_contents; ++i)
	{
		io_read (buffer, 0x30, image, off);
		off += 0x30;

		tmd->contents[i].cid = be32 (buffer);
		tmd->contents[i].index = be16 (&buffer[4]);
		tmd->contents[i].type = be16 (&buffer[6]);
		tmd->contents[i].size = be64 (&buffer[8]);
		memcpy (tmd->contents[i].hash, &buffer[16], 20);

	}

	return;
}
*/

/*
int WiiDisc::io_read (void *ptr, size_t size, struct ImageFile *image, uint64_t offset)
{
	size_t bytes;
	__int64 nSeek;
	nSeek = _lseeki64 (image->fp, offset, SEEK_SET);
	if (nSeek == -1)
	{
		//DWORD x = GetLastError();
		AfxMessageBox("io_seek");
		return -1;
	}

	markAsUsed(offset, size);
	bytes = ::_read(image->fp, ptr, size);
	if (bytes != size)
	{
		DLOG << "io_read error";
	}
	return bytes;
}
*/

int WiiDisc::decrypt_block (struct ImageFile *image, uint32_t part, uint32_t block)
{
	if (block == image->parts[part].cached_block)
		return 0;


	if (io_read (image->parts[part].dec_buffer, 0x8000, image,
				 image->parts[part].offset +
				 image->parts[part].data_offset + (uint64_t)(0x8000) * (uint64_t)(block))
			!= 0x8000)
	{
		AfxMessageBox("decrypt read");
		return -1;
	}

	AES_cbc_encrypt (&image->parts[part].dec_buffer[0x400],
					 image->parts[part].cache, 0x7c00,
					 &image->parts[part].key,
					 &image->parts[part].dec_buffer[0x3d0], AES_DECRYPT);

	image->parts[part].cached_block = block;

	return 0;
}

size_t WiiDisc::io_read_part(void *ptr, size_t size, struct ImageFile *image,
							  uint32_t part, uint64_t offset)
{
	uint32_t block = (uint32_t)(offset / (uint64_t)(0x7c00));
	uint32_t cache_offset = (uint32_t)(offset % (uint64_t)(0x7c00));
	uint32_t cache_size;
	unsigned char *dst = static_cast<unsigned char*>(ptr);

	if (!image->parts[part].isEncrypted)
		return io_read (ptr, size, image,
						image->parts[part].offset + offset);

	while (size)
	{
		if (decrypt_block (image, part, block))
			return (dst - ptr);

		cache_size = size;
		if (cache_size + cache_offset > 0x7c00)
			cache_size = 0x7c00 - cache_offset;

		memcpy (dst, image->parts[part].cache + cache_offset,
				cache_size);
		dst += cache_size;
		size -= cache_size;
		cache_offset = 0;

		block++;
	}

	return dst - ptr;
}



unsigned int WiiDisc::CountBlocksUsed()
{
	unsigned int	nRetVal = 0;;
	uint64_t				nBlock = 0;
	uint64_t				i = 0;
	unsigned char	cLastBlock = 0x01;

	AddToLog("------------------------------------------------------------------------------");
	for ( i =0; i < (nImageSize / (uint64_t)(0x8000)); i++)
	{
		nRetVal += pFreeTable[i];
		if (cLastBlock!=pFreeTable[i])
		{
			// change so show
			if (1==cLastBlock)
			{
				AddToLog("Marked Content", nBlock * (uint64_t)(0x8000), i*(uint64_t)(0x8000) - 1, (i-nBlock)*32);
			}
			else
			{
				AddToLog("Empty Content", nBlock * (uint64_t)(0x8000), i*(uint64_t)(0x8000) - 1, (i-nBlock)*32);
			}
			nBlock = i;
			cLastBlock = pFreeTable[i];
		}

	}
	// output the final range
	if (1==cLastBlock)
	{
		AddToLog("Marked Content", nBlock *(uint64_t)(0x8000), nImageSize - 1, (i-nBlock)*32);
	}
	else
	{
		AddToLog("Empty Content", nBlock * (uint64_t)(0x8000), nImageSize - 1, (i-nBlock)*32);
	}
	AddToLog("------------------------------------------------------------------------------");

	return nRetVal;
}

BOOL WiiDisc::CleanupISO(CString csFileIn, CString csFileOut, int nMode, int nHeaderMode)
{
	FILE * fIn = NULL;
	FILE * fOut = NULL;
	FILE * fOutDif = NULL;

	BOOL bStatus = true; // Used for error checking on read/write
	//MSG msg;
	//int x = 0;
	unsigned char inData[0x8000];

	CString csDiffName;
	csDiffName = csFileOut;

	if (nMode != 1)
	{
		// the passed name is the save file, while if mode = 1 it's the
		// dif filename already
		// now check and replace the .iso if necessary
		if (csDiffName.find(".iso", 0) == -1U)
		{
			// not found so append
			csDiffName += ".dif";
		}
		else
		{
			// replace it
			csDiffName.replace(csDiffName.find(".iso"), 4, ".dif");
			//csDiffName.replace(".iso", ".dif");
		}
	}
	// now open files depending on the passed parameter

	switch(nMode)
	{
	case 0:
		// try and create the output file first
		fOut = fopen(csFileOut.data(), "wb");

		if (NULL==fOut)
		{
			AddToLog("Unable to create save filename");
			return false;
		}
		break;
	case 1:
		// now open the dif file only

		fOutDif = fopen(csDiffName.data(), "wb");
		if (NULL==fOutDif)
		{
			AddToLog("Unable to create dif filename");
			return false;
		}
		break;
	case 2:
		// try and create the output file first
		fOut = fopen(csFileOut.data(), "wb");

		if (NULL==fOut)
		{
			AddToLog("Unable to create save filename");
			return false;
		}
		// now open the dif file as well
		fOutDif = fopen(csDiffName.data(), "wb");
		if (NULL==fOutDif)
		{
			AddToLog("Unable to create dif filename");
			// close the other output file
			fclose(fOut);
			return false;
		}
		break;
	default:
		// non-standard value passed - so return with error
		return false;
		break;
	}

	m_progressHandler->setRange(0, (int)((nImageSize / (uint64_t)(0x8000))));
	m_progressHandler->setPosition(0);

	CString csTempString;

	switch(nMode)
	{
	case 0:
		//csTempString.Format("Saving file: %s", csFileOut);
		break;
	case 1:
		//csTempString.Format("Saving file: %s", csDiffName);
		break;
	case 2:
		//csTempString.Format("Saving files: %s\n and %s", csFileOut, csDiffName);
		break;
		// no need for a default as would have been rejected at the earlier switch statement
	}
	m_progressHandler->setText(csTempString.data());
	fIn = fopen(csFileIn.data(), "rb");
	// open the in and out files
	// read the inblock of 32K
	// check to see if we have to write it -  allow for bigger discs now
	// as well as smaller ones
	for( unsigned int i =0;
			((i < (nImageSize/ (uint64_t)(0x8000)))&&(!feof(fIn)));
			i++)
	{

		bStatus *= (0x8000==fread(inData, 1, 0x8000, fIn));
		if (0x01==pFreeTable[i])
		{
			// block is marked as used so
			switch(nMode)
			{
			case 0:
				bStatus *= (0x8000==fwrite(inData, 1, 0x8000, fOut));
				break;
			case 1:
				bStatus *= (0x0001==fwrite(pBlankSector0, 1, 1, fOutDif));
				break;
			case 2:
				bStatus *= (0x8000==fwrite(inData, 1, 0x8000, fOut));
				bStatus *= (0x0001==fwrite(pBlankSector0, 1, 1, fOutDif));
				break;
			}
		}
		else
		{
			// empty block so.......

			switch(nMode)
			{
			case 0:
				if (1==nHeaderMode)
				{
					// change back to 1.0 version.
					// As it was pretty trivial for N to check the SHA tables then it seems
					// pointless including them at the cost of 1k per sector
					bStatus *= (0x8000==fwrite(pBlankSector, 1, 0x8000, fOut));
				}
				else
				{
					// 1.0a version
					bStatus *= (0x0400==fwrite(inData, 1, 0x0400, fOut));
					bStatus *= (0x7c00==fwrite(pBlankSector, 1, 0x7c00, fOut));
				}
				break;
			case 1:
				// now create the Dif file by writing out 0s then
				// the Difd data
				bStatus *= (0x0001==fwrite(pBlankSector, 1, 1, fOutDif));
				bStatus *= (0x8000==fwrite(inData, 1, 0x8000, fOutDif));
				break;
			case 2:
				if (1==nHeaderMode)
				{
					// change back to 1.0 version.
					// As it was pretty trivial for N to check the SHA tables then it seems
					// pointless including them at the cost of 1k per sector
					bStatus *= (0x8000==fwrite(pBlankSector, 1, 0x8000, fOut));
				}
				else
				{
					// 1.0a version
					bStatus *= (0x0400==fwrite(inData, 1, 0x0400, fOut));
					bStatus *= (0x7c00==fwrite(pBlankSector, 1, 0x7c00, fOut));
				}

				bStatus *= (0x0001==fwrite(pBlankSector, 1, 1, fOutDif));
				bStatus *= (0x8000==fwrite(inData, 1, 0x8000, fOutDif));
				break;
			}
		}
		m_progressHandler->setPosition(i);
		// do the message pump thang


		/*
		if (PeekMessage(&msg, NULL, 0, 0, PM_REMOVE))
		{
			// PeekMessage has found a message--process it
			if (msg.message != WM_CANCELLED)
			{
				TranslateMessage(&msg); // Translate virt. key codes
				DispatchMessage(&msg);  // Dispatch msg. to window
			} else {
				// quit message received - simply exit

		AddToLog("Save cancelled");
		//delete pProgressBox;
				if (NULL!=fOutDif)
				{
					fclose(fOutDif);
				}
				if (NULL!=fOut)
				{
					fclose(fOut);
				}
				fclose(fIn);
				return false;
			}
		}
		*/

		if (!bStatus)
		{
			// error in read or write - don't care where, just exit with error
			//delete pProgressBox;
			if (NULL!=fOutDif)
			{
				fclose(fOutDif);
			}
			if (NULL!=fOut)
			{
				fclose(fOut);
			}
			fclose(fIn);
			return false;
		}
	}

	//delete pProgressBox;
	if (NULL!=fOutDif)
	{
		fclose(fOutDif);
	}
	if (NULL!=fOut)
	{
		fclose(fOut);
	}
	fclose(fIn);
	return true;
}

void WiiDisc::markAsUsed(offset_t offset, largesize_t size)
{
	static const offset_t maxOffset = 4699979776ULL * 2ULL;
	offset_t endOffset = offset + size;
	while(offset < endOffset && offset < maxOffset)
	{

		m_freeMap[offset / 0x8000] = true;
		offset += 0x8000;
	}
}
void WiiDisc::markAsUsedDC(offset_t partitionOffset, offset_t offset, largesize_t size, bool isEncrypted)
{
	offset_t tempOffset;
	largesize_t tempSize;

	if (isEncrypted)
	{
		// the offset and size relate to the decrypted file so.........
		// we need to change the values to accomodate the 0x400 bytes of crypto data

		tempOffset = offset / 0x7C00;
		tempOffset = tempOffset * 0x8000;
		tempOffset += partitionOffset;

		tempSize = size / 0x7c00;
		tempSize = (tempSize + 1) * 0x8000;

		// add on the offset in the first nblock for the case where data straddles blocks
		tempSize += offset % 0x7c00;
	}
	else
	{
		// unencrypted - we use the actual offsets
		tempOffset = partitionOffset + offset;
		tempSize = size;
	}
	markAsUsed(tempOffset, tempSize);

}

void WiiDisc::Reset()
{
	memset(&m_freeMap.front(), 0, m_freeMap.size() / 8);
	markAsUsed(0, 0x50000);
 
	hDisc = NULL;
	for(int i=0; i < 20; i++)
	{
		hPartition[i]=NULL;
	}

	// then clear the decrypt key
	uint8_t key[16];

	memset(key,0,16);

	AES_KEY nKey;

	memset(&nKey, 0, sizeof(AES_KEY));
	AES_set_decrypt_key (key, 128, &nKey);
}

bool WiiDisc::saveDecryptedFile(const std::string& destFilename, int partition, offset_t offset, largesize_t size, bool overrideEncrypt)
{
	uint32_t block = (uint32_t)(offset / (uint64_t)(0x7c00));
	uint32_t cache_offset = (uint32_t)(offset % (uint64_t)(0x7c00));
	uint64_t cache_size = 0;

	unsigned char cBuffer[0x8000];

	FileStream outStream(destFilename.data(), Stream::modeWrite);

	if (!m_imageFile->parts[partition].isEncrypted || overrideEncrypt)
	{
		if (-1==_lseeki64 (m_imageFile->fp, offset, SEEK_SET))
		{
			//uint32_t x = GetLastError();
			DLOG << "io_seek error";
			return false;
		}

		while(size)
		{
			cache_size = size;
			if (cache_size  > 0x8000)
			{
				cache_size = 0x8000;
			}
			::_read(m_imageFile->fp, &cBuffer[0], (uint32_t)(cache_size));
			outStream.write(cBuffer, cache_size);
			size -= cache_size;
		}
	}
	else
	{
		while (size)
		{
			if (decrypt_block (m_imageFile, partition, block))
			{
				fclose(fOut);
				return false;
			}
			cache_size = size;
			if (cache_size + cache_offset > 0x7c00)
			{
				cache_size = 0x7c00 - cache_offset;
			}

			if (cache_size != outStream.write(image->parts[part].cache + cache_offset, cache_size))
			{
				DLOG << "Error writing file";
				return false;
			}
			size -= cache_size;
			cache_offset = 0;
			block++;
		}
	}
	return true;
}

bool WiiDisc::loadDecryptedFile(const std::string& filename, uint32_t partition, uint64_t offset, uint64_t size, int fstReference)
{
	FILE * fIn;
	uint32_t		nImageSize;
	uint64_t		nfImageSize;
	uint8_t *	pPartData ;
	uint64_t		nFreeSpaceStart;
	uint32_t		nExtraData;
	uint32_t		nExtraDataBlocks;

	std::vector<char> bootBin(0x440);


	// create a 64 cluster buffer for the file

	FileStream inStream(filename.data(), Stream::modeRead);

	if (!inStream.isOpen())
	{
		DLOG << "Error opening file";
		ASSERT(0);
		return false;
	}

	// get the size of the file we are trying to load
	
	nfImageSize = inStream->size();
	nImageSize = (uint32_t) nfImageSize;


	// now get the filesize we are trying to load and make sure it is smaller
	// or the same size as the one we are trying to replace if so then a simple replace
	if (size >= nImageSize)
	{
		// simple replace
		// now need to change the boot.bin if one if fst.bin or main.dol were changed

		if (size!=nfImageSize)
		{
			// we have a different sized file being put in
			// this is obviously smaller but will require a tweak to one of the file
			// entries
			if (0<fstReference)
			{
				// normal file so change the FST.BIN
				uint8_t * pFSTBin = (unsigned char *) calloc((uint32_t)(image->parts[partition].header.fst_size),1);

				io_read_part(pFSTBin, (uint32_t)(image->parts[partition].header.fst_size), image, partition, image->parts[partition].header.fst_offset);

				// alter the entry for the passed FST Reference
				fstReference = fstReference * 0x0c;

				// update the length for the file
				Write32(pFSTBin + fstReference + 0x08L , nImageSize);

				// write out the FST.BIN
				wii_write_data_file(image, partition, image->parts[partition].header.fst_offset, (uint32_t)(image->parts[partition].header.fst_size), pFSTBin);

				// write it out
				wii_write_data_file(image, partition, offset, nImageSize, NULL, fIn, _ProgressBox);

			}
			else
			{
				switch(fstReference)
				{
				case 0:
					// - one of the files that should ALWAYS be the correct size
					DLOG << "Error as file sizes do not match and they MUST for boot.bin and bi2.bin";
					return false;
				case -1:
					// FST
					io_read_part(&bootBin[0], 0x440, image, partition, 0);

					// update the settings for the FST.BIN entry
					// this has to be rounded to the nearest 4 so.....
					if (0!=(nImageSize%4))
					{
						nImageSize = nImageSize + (4 - nImageSize%4);
					}
					Write32(&bootBin[0x428], nImageSize >> 2);
					Write32(&bootBin[0x42C], nImageSize >> 2);
					// now write it out
					wii_write_data_file(partition, 0, 0x440, &bootBin[0]);

					break;
				case -2:
					// main.dol - don't have to do anything
					break;
				case -3:
					// apploader - don't have to do anything
					break;
				case -4:
					// partition.bin
					DLOG << "Error as partition.bin MUST be 0x20000 bytes in size";
					return false;
				case -5:
					DLOG << "Error as tmd.bin MUST be same size";
					return false;
				case -6:
					DLOG << "Error as cert.bin MUST be same size";
					return false;
				case -7:
					DLOG << "Error as h3.bin MUST be 0x18000 bytes in size";
					return false;
				default:
					DLOG << "Unknown file reference passed";
					return false
				}
				// now write it out
				wii_write_data_file(partition, offset, nImageSize, NULL, fIn, _ProgressBox);
			}
		}
		else
		{
			// Equal sized file so need to check for the special cases
			if (fstReference < 0)
			{
				switch(fstReference)
				{
				case -1:
				case -2:
				case -3:
					// simple write as files are the same size
					wii_write_data_file(partition, offset, nImageSize, NULL, fIn);
					break;
				case -4:
					// Partition.bin
					// it's a direct write
					pPartData = (uint8_t *)calloc(1,(unsigned int)size);

					fread(pPartData,1,(unsigned int)size, fIn);
					DiscWriteDirect(m_imageFile->parts[partition].offset, pPartData, (unsigned int)size);
					free(pPartData);
					break;
				case -5:
					// tmd.bin;
				case -6:
					// cert.bin
				case -7:
					// h3.bin

					// same for all 3
					pPartData = (uint8_t *)calloc(1,(unsigned int)size);

					fread(pPartData,1,(unsigned int)size, fIn);
					DiscWriteDirect(m_imageFile->parts[partition].offset + offset, pPartData, (unsigned int)size);
					free(pPartData);

					break;
				default:
					DLOG << "Unknown file reference passed";
					break;
				}
			}
			else
			{
				// simple write as files are the same size
				wii_write_data_file(partition, offset, nImageSize, NULL, fIn, _ProgressBox);
			}
		}

	}
	else
	{
		// Alternatively just have to update the FST or boot.bin depending on the file we want to change
		// this will depend on whether the passed index is
		// -ve = Partition data,
		// 0 = given by boot.bin,
		// +ve = normal file

		// need to find some free space in the partition first
		nFreeSpaceStart = findRequiredFreeSpaceInPartition(partition, nImageSize);

		if (0==nFreeSpaceStart)
		{
			// no free space - so cant do it
			DLOG << "Unable to find free space to add the file :(";
			return false;
		}

		// depending on the passed offset we then need to modify either the
		// fst.bin or the boot.bin
		if (fstReference > 0)
		{
			// normal one - so read out the fst and change the values for the relevant pointer
			// before writing it out
			uint8_t * pFSTBin = (unsigned char *) calloc((uint32_t)(image->parts[partition].header.fst_size),1);

			io_read_part(pFSTBin, (uint32_t)(image->parts[partition].header.fst_size), image, partition, image->parts[partition].header.fst_offset);

			// alter the entry for the passed FST Reference
			fstReference = fstReference * 0x0c;

			// update the offset for this file
			Write32(pFSTBin + fstReference + 0x04L, uint32_t (nFreeSpaceStart >> 2));
			// update the length for the file
			Write32(pFSTBin + fstReference + 0x08L , nImageSize);

			// write out the FST.BIN
			wii_write_data_file(image, partition, image->parts[partition].header.fst_offset, (uint32_t)(image->parts[partition].header.fst_size), pFSTBin);

			// now write data file out
			wii_write_data_file(image, partition, nFreeSpaceStart, nImageSize, NULL, fIn, _ProgressBox);

		}
		else
		{

			switch(fstReference)
			{
			case -1: // FST.BIN
				// change the boot.bin file too and write that out
				io_read_part(&bootBin[0], 0x440, image, partition, 0);

				// update the settings for the FST.BIN entry
				// this has to be rounded to the nearest 4 so.....
				if (0!=(nImageSize%4))
				{
					nImageSize = nImageSize + (4 - nImageSize%4);
				}

				// update the settings for the FST.BIN entry
				Write32(pBootBin + 0x424L, uint32_t (nFreeSpaceStart >> 2));
				Write32(pBootBin + 0x428L, (uint32_t)(nImageSize >> 2));
				Write32(pBootBin + 0x42CL, (uint32_t)(nImageSize >> 2));

				// now write it out
				wii_write_data_file(image, partition, 0, 0x440, pBootBin);

				// now write it out
				wii_write_data_file(image, partition, nFreeSpaceStart, nImageSize, NULL, fIn);


				break;
			case -2: // Main.DOL
				// change the boot.bin file too and write that out
				io_read_part(pBootBin, 0x440, image, partition, 0);

				// update the settings for the main.dol entry
				Write32(pBootBin + 0x420L, uint32_t (nFreeSpaceStart >> 2));

				// now write it out
				wii_write_data_file(image, partition, 0, 0x440, pBootBin);

				// now write main.dol out
				wii_write_data_file(image, partition, nFreeSpaceStart, nImageSize, NULL, fIn);


				break;
			case -3: // Apploader.img - now this is fun! as we have to
				// move the main.dol and potentially fst.bin too  too otherwise they would be overwritten
				// also what happens if the data for those two has already been moved
				// aaaargh

				// check to see what we have to move
				// by calculating the amount of extra data we are trying to stuff in
				nExtraData = (uint32_t)(nImageSize - image->parts[partition].appldr_size);

				nExtraDataBlocks = 1 + ((nImageSize - (uint32_t)(image->parts[partition].appldr_size)) / 0x7c00);

				// check to see if we have that much free at the end of the area
				// or do we need to try and overwrite
				if (true==CheckForFreeSpace(image, partition,image->parts[partition].appldr_size + 0x2440 ,nExtraDataBlocks))
				{
					// we have enough space after the current apploader - already moved the main.dol?
					// so just need to write it out.
					wii_write_data_file(image, partition, 0x2440, nImageSize, NULL, fIn, _ProgressBox);

				}
				else
				{
					// check if we can get by with moving the main.dol
					if (nExtraData > image->parts[partition].header.dol_size)
					{
						// don't really want to be playing around here as we potentially can get
						// overwrites of all sorts of data
						AfxMessageBox("Cannot guarantee writing data correctly\nI blame nargels");
						AddToLog("Cannot guarantee a good write of apploader");
						fclose(fIn);

						free(pBootBin);
						return false;
					}
					else
					{
						// "just" need to move main.dol
						uint8_t * pMainDol = (uint8_t *) calloc((uint32_t)(image->parts[partition].header.dol_size),1);

						io_read_part(pMainDol, (uint32_t)(image->parts[partition].header.dol_size), image, partition, image->parts[partition].header.dol_offset);

						// try and get some free space for it
						nFreeSpaceStart = findRequiredFreeSpaceInPartition(image, partition, (uint32_t)(image->parts[partition].header.dol_size));

						// now unmark the original dol area
						MarkAsUnused(image->parts[partition].offset+image->parts[partition].data_offset+(((image->parts[partition].header.dol_offset)/0x7c00)*0x8000),
									 image->parts[partition].header.dol_size);

						if ((0!=nFreeSpaceStart)&&
								(true==CheckForFreeSpace(image, partition,image->parts[partition].appldr_size + 0x2440 ,nExtraDataBlocks)))
						{
							// got space so write it out
							wii_write_data_file(image, partition, nFreeSpaceStart, (uint32_t)(image->parts[partition].header.dol_size), pMainDol);

							// now do the boot.bin file too
							io_read_part(pBootBin, 0x440, image, partition, 0);

							// update the settings for the boot.BIN entry
							Write32(pBootBin + 0x420L, uint32_t (nFreeSpaceStart >> 2));

							// now write it out
							wii_write_data_file(image, partition, 0, 0x440, pBootBin);

							// now write out the apploader - we don't need to change any other data
							// as the size is inside the apploader
							wii_write_data_file(image, partition, 0x2440, nImageSize, NULL, fIn);

						}
						else
						{
							// cannot do it :(
							DLOG << "Unable to move the main.dol and find enough space for the apploader.";
							DLOG << "Unable to add larger apploader";
							free(pMainDol);
							free(pBootBin);
							return false;
						}


					}
				}
				break;
			default:
				// Unable to do these as they are set sizes and lengths
				// boot.bin and bi2.bin
				// partition.bin
				DLOG << "Unable to change that file as it is a set size in the disc image";
				DLOG << "Unable to change set size file";
				return false;
			}

		}
	}

	return true;
}

BOOL WiiDisc::CheckAndLoadKey(BOOL bLoadCrypto, struct ImageFile *image)
{
	//FILE * fp_key;

	static uint8_t LoadedKey[16] = {0xEB, 0xE4, 0x2A, 0x22, 0x5E, 0x85, 0x93, 0xE4, 0x48, 0xD9, 0xC5, 0x45, 0x73, 0x81, 0xAA, 0xF7};

	if (false==bLoadCrypto)
	{
		/*
				fp_key = fopen (KEYFILE, "rb");

				if (fp_key == NULL) {
		AfxMessageBox("Unable to open key.bin");
		return false;
				}

				if (16 != fread (LoadedKey, 1, 16, fp_key)) {
		fclose (fp_key);
		AfxMessageBox("key.bin not 16 bytes in size");
		return false;
				}

				fclose (fp_key);
		*/

		// now check to see if it's the right key
		// as we don't want to embed the key value in here then lets cheat a little ;)
		// by checking the Xor'd difference values
		if	((0x0F!=(LoadedKey[0]^LoadedKey[1]))||
				(0xCE!=(LoadedKey[1]^LoadedKey[2]))||
				(0x08!=(LoadedKey[2]^LoadedKey[3]))||
				(0x7C!=(LoadedKey[3]^LoadedKey[4]))||
				(0xDB!=(LoadedKey[4]^LoadedKey[5]))||
				(0x16!=(LoadedKey[5]^LoadedKey[6]))||
				(0x77!=(LoadedKey[6]^LoadedKey[7]))||
				(0xAC!=(LoadedKey[7]^LoadedKey[8]))||
				(0x91!=(LoadedKey[8]^LoadedKey[9]))||
				(0x1C!=(LoadedKey[9]^LoadedKey[10]))||
				(0x80!=(LoadedKey[10]^LoadedKey[11]))||
				(0x36!=(LoadedKey[11]^LoadedKey[12]))||
				(0xF2!=(LoadedKey[12]^LoadedKey[13]))||
				(0x2B!=(LoadedKey[13]^LoadedKey[14]))||
				(0x5D!=(LoadedKey[14]^LoadedKey[15])))
		{
			// handle the Korean key, in case it ever gets found
			/*
						if (AfxMessageBox("Doesn't seem to be the correct key.bin\nDo you want to use anyways??",
							MB_YESNO|MB_ICONSTOP|MB_DEFBUTTON2)==IDNO)
						{
							return false;
						}
			*/
		}
	}
	else
	{
		AES_set_decrypt_key (LoadedKey, 128, &image->key);
	}
	return true;
}


////////////////////////////////////////////////////////////
// Inverse of the be32 function - writes a 32 bit value   //
// high to low                                            //
////////////////////////////////////////////////////////////
void WiiDisc::Write32( uint8_t *p, uint32_t nVal)
{
	p[0] = (nVal >> 24) & 0xFF;
	p[1] = (nVal >> 16) & 0xFF;
	p[2] = (nVal >>  8) & 0xFF;
	p[3] = (nVal      ) & 0xFF;
}
////////////////////////////////////////////////////////////////////////////////////////
// This function takes two FSTs and merges them using a passed offset as the start    //
// location for the new data.                                                         //
// UNFINISHED - UNFINISHED - UNFINISHED ETC...........................................//
////////////////////////////////////////////////////////////////////////////////////////
BOOL WiiDisc::MergeAndRelocateFSTs(unsigned char *pFST1, uint32_t nSizeofFST1, unsigned char *pFST2, uint32_t nSizeofFST2, unsigned char *pNewFST,  uint32_t * nSizeofNewFST, uint64_t nNewOffset, uint64_t nOldOffset)
{

	uint32_t nFilesFST1 = 0;
	uint32_t nFilesFST2 = 0;
	//uint32_t nFilesNewFST = 0;
	uint32_t nStringTableOffset;

	//uint64_t	nOffsetCalc = 0;
	uint32_t nStringPad =   0;

	// extract the data for FST 1
	nFilesFST1 = be32(pFST1 + 8);

	// extract the data for FST 2
	nFilesFST2 = be32(pFST1 + 8);

	// merge the two entry offset tables (as we then will know where the string table starts)
	// copy the first one over
	memcpy(pNewFST, pFST1, nFilesFST1 * 0x0C);
	memcpy(pNewFST + (nFilesFST1 * 0x0C), pFST2 + 0x0C, (nFilesFST2 - 1)*0x0C);

	nStringTableOffset = (nFilesFST1 + nFilesFST2 -1) * 0x0c;

	// now copy the string tables
	memcpy(pNewFST + nStringTableOffset, pFST1 + (nFilesFST1 * 0x0C), nSizeofFST1 - (nFilesFST1 * 0x0C));

	// now search back to find the first non 0 character
	nStringPad = nSizeofFST1 + ((nFilesFST2 -1) * 0x0C);

	while (0==pNewFST[nStringPad])
	{
		nStringPad --;
	}
	nStringPad +=2;

	// so that we then know the real positional offset to write to

	memcpy(pNewFST + nStringPad, pFST2 + (nFilesFST2 * 0x0C), nSizeofFST2 - (nFilesFST2 * 0x0C));

	// we then need to go through both sets of data in the copied FST2 data to mark
	// them correctly

	// HOW TO HANDLE DUPLICATE FILENAMES???
	//



	// TO BE DONE - BUT NOT IN THIS APPLICATION ;)

	return true;
}

//////////////////////////////////////////////////////////////////////////////
// Invert of the mark as used - to allow for                                //
// creation of a DIF file for a specific area e.g. mariokart partition 3    //
// Not really used these days                                               //
//////////////////////////////////////////////////////////////////////////////
void WiiDisc::MarkAsUnused(uint64_t nOffset, uint64_t nSize)
{
	uint64_t nStartValue = nOffset;
	uint64_t nEndValue = nOffset + nSize;
	while((nStartValue < nEndValue)&&
			(nStartValue < (4699979776LL * 2LL)))
	{

		pFreeTable[nStartValue / (uint64_t)(0x8000)] = 0;
		nStartValue = nStartValue + ((uint64_t)(0x8000));
	}

}

BOOL WiiDisc::DiscWriteDirect(struct ImageFile *image, uint64_t nOffset, uint8_t *pData, unsigned int nSize)
{

	_int64 nSeek;

	// Simply seek to the right place
	nSeek = _lseeki64 (image->fp, nOffset, SEEK_SET);

	if (-1==nSeek)
	{
		//m_pParent->AddToLog("Seek error for write");
		AfxMessageBox("io_seek");
		return false;
	}

	if (nSize!= (unsigned)::_write(image->fp, pData, nSize))
	{
		//m_pParent->AddToLog("Write error");
		AfxMessageBox("Write error");
		return false;
	}
	return true;
}

//////////////////////////////////////////////////////////////////////////
// The infamous TRUCHA signing bug                                      //
// where we change the reserved bytes in the ticket until the SHA has a //
// 0 in the first location                                              //
//////////////////////////////////////////////////////////////////////////

BOOL WiiDisc::wii_trucha_signing(struct ImageFile *image, int partition)
{
	uint8_t *buf, hash[20];
	uint32_t size, val;

	/* Store TMD size */
	size = (uint32_t)(image->parts[partition].tmdSize);

	/* Allocate memory */
	buf = (uint8_t *)calloc(size,1);

	if (!buf)
	{
		return false;
	}

	/* Jump to the partition TMD and read it*/
	_lseeki64(image->fp, image->parts[partition].offset + image->parts[partition].tmdOffset, SEEK_SET);
	if (size!=(unsigned)::_read(image->fp, buf, size))
	{
		return false;
	}

	/* Overwrite signature with trucha signature */
	memcpy(buf + 0x04, trucha_signature, 256);

	/* SHA-1 brute force */
	hash[0] = 1;
	for (val = 0; ((val <= ULONG_MAX)&&(hash[0]!=0x00)); val++)
	{
		/* Modify TMD "reserved" field */
		memcpy(buf + 0x19A, &val, sizeof(val));

		/* Calculate SHA-1 hash */
		SHA1(buf + 0x140, size - 0x140, hash);


		// check for the bug where the first byte of the hash is 0
		if (0x00==hash[0])
		{
			/* Write modified TMD data */
			_lseeki64(image->fp, image->parts[partition].offset + image->parts[partition].tmdOffset, SEEK_SET);

			// write it out
			if (size!= (unsigned)::_write(image->fp, buf, size))
			{
				// error writing
				return  false;
			}
			else
			{
				return true;
			}
		}
	}
	return false;
}

// calculate the number of clusters

int WiiDisc::wii_nb_cluster(struct ImageFile *iso, int partition)
{
	int nRetVal = 0;

	nRetVal = (int)(iso->parts[partition].data_size / SIZE_CLUSTER);

	return nRetVal;
}

// calculate the group hash for a cluster
bool WiiDisc::wii_calc_group_hash(struct ImageFile *iso, int partition, int cluster)
{
	uint8_t h2[SIZE_H2], h3[SIZE_H3], h4[SIZE_H4];
	uint32_t group;

	/* Calculate cluster group */
	group = cluster / NB_CLUSTER_GROUP;

	/* Get H2 hash of the group */
	if (!wii_read_cluster_hashes(iso, partition, cluster, NULL, NULL, h2))
	{
		return false;
	}

	/* read the H3 table offset */
	io_read(h3, SIZE_H3, iso, iso->parts[partition].offset + iso->parts[partition].h3_offset);


	/* Calculate SHA-1 hash */
	sha1(h2, SIZE_H2, &h3[group * 0x14]);

	/* Write new H3 table */
	if (!DiscWriteDirect(iso, iso->parts[partition].h3_offset + iso->parts[partition].offset, h3, SIZE_H3))
	{
		return false;
	}


	/* Calculate H4 */
	sha1(h3, SIZE_H3, h4);

	/* Write H4 */
	if (false==DiscWriteDirect(iso, iso->parts[partition].tmdOffset + OFFSET_TMD_HASH + iso->parts[partition].offset, h4, SIZE_H4))
	{
		return false;
	}


	return true;
}

int WiiDisc::wii_read_cluster(struct ImageFile *iso, int partition, int cluster, uint8_t *data, uint8_t *header)
{
	uint8_t buf[SIZE_CLUSTER];
	uint8_t  iv[16];
	uint8_t * title_key;
	uint64_t offset;


	/* Jump to the specified cluster and copy it to memory */
	offset = iso->parts[partition].offset + iso->parts[partition].data_offset + (uint64_t)((uint64_t)cluster * (uint64_t)SIZE_CLUSTER);

	// read the correct location block in
	io_read(buf, SIZE_CLUSTER, iso, offset);

	/* Set title key */
	title_key =  &(iso->parts[partition].title_key[0]);

	/* Copy header if required*/
	if (header)
	{
		/* Set IV key to all 0's*/
		memset(iv, 0, sizeof(iv));

		/* Decrypt cluster header */
		aes_cbc_dec(buf, header, SIZE_CLUSTER_HEADER, title_key, iv);
	}

	/* Copy data if required */
	if (data)
	{
		/* Set IV key to correct location*/
		memcpy(iv, &buf[OFFSET_CLUSTER_IV], 16);

		/* Decrypt cluster data */
		aes_cbc_dec(&buf[0x400], data, SIZE_CLUSTER_DATA, title_key,  &iv[0]);

	}

	return 0;
}

int WiiDisc::wii_write_cluster(struct ImageFile *iso, int partition, int cluster, uint8_t *in)
{
	uint8_t h0[SIZE_H0];
	uint8_t h1[SIZE_H1];
	uint8_t h2[SIZE_H2];

	uint8_t *data;
	uint8_t *header;
	uint8_t *title_key;

	uint8_t iv[16];

	uint32_t group,
	subgroup,
	f_cluster,
	nb_cluster,
	pos_cluster,
	pos_header;

	uint64_t offset;

	uint32_t i;
	//int ret = 0;

	/* Calculate cluster group and subgroup */
	group = cluster / NB_CLUSTER_GROUP;
	subgroup = (cluster % NB_CLUSTER_GROUP) / NB_CLUSTER_SUBGROUP;

	/* First cluster in the group */
	f_cluster = group * NB_CLUSTER_GROUP;

	/* Get number of clusters in this group */
	nb_cluster = wii_nb_cluster(iso, partition) - f_cluster;
	if (nb_cluster > NB_CLUSTER_GROUP)
		nb_cluster = NB_CLUSTER_GROUP;

	/* Allocate memory */
	data   = (uint8_t *)calloc(SIZE_CLUSTER_DATA * NB_CLUSTER_GROUP, 1);
	header = (uint8_t *)calloc(SIZE_CLUSTER_HEADER * NB_CLUSTER_GROUP, 1);
	if (!data || !header)
		return 1;

	/* Read group clusters and headers */
	for (i = 0; i < nb_cluster; i++)
	{
		uint8_t *d_ptr = &data[SIZE_CLUSTER_DATA * i];
		uint8_t *h_ptr = &header[SIZE_CLUSTER_HEADER * i];

		/* Read cluster */
		if (wii_read_cluster(iso, partition, f_cluster + i, d_ptr, h_ptr))
		{
			free(data);
			free(header);
			return false;
		}
	}

	/* Calculate new cluster H0 table */
	for (i = 0; i < SIZE_CLUSTER_DATA; i += 0x400)
	{
		uint32_t idx = (i / 0x400) * 20;

		/* Calculate SHA-1 hash */
		sha1(&in[i], 0x400, &h0[idx]);
	}

	/* Write new cluster and H0 table */
	pos_header  = ((cluster - f_cluster) * SIZE_CLUSTER_HEADER);
	pos_cluster = ((cluster - f_cluster) * SIZE_CLUSTER_DATA);

	memcpy(&data[pos_cluster], in, SIZE_CLUSTER_DATA);
	memcpy(&header[pos_header + OFFSET_H0], h0, SIZE_H0);

	/* Calculate H1 */
	for (i = 0; i < NB_CLUSTER_SUBGROUP; i++)
	{
		uint32_t pos = SIZE_CLUSTER_HEADER * ((subgroup * NB_CLUSTER_SUBGROUP) + i);
		uint8_t tmp[SIZE_H0];

		/* Cluster exists? */
		if ((pos / SIZE_CLUSTER_HEADER) > nb_cluster)
			break;

		/* Get H0 */
		memcpy(tmp, &header[pos + OFFSET_H0], SIZE_H0);

		/* Calculate SHA-1 hash */
		sha1(tmp, SIZE_H0, &h1[20 * i]);
	}

	/* Write H1 table */
	for (i = 0; i < NB_CLUSTER_SUBGROUP; i++)
	{
		uint32_t pos = SIZE_CLUSTER_HEADER * ((subgroup * NB_CLUSTER_SUBGROUP) + i);

		/* Cluster exists? */
		if ((pos / SIZE_CLUSTER_HEADER) > nb_cluster)
			break;

		/* Write H1 table */
		memcpy(&header[pos + OFFSET_H1], h1, SIZE_H1);
	}

	/* Calculate H2 */
	for (i = 0; i < NB_CLUSTER_SUBGROUP; i++)
	{
		uint32_t pos = (NB_CLUSTER_SUBGROUP * i) * SIZE_CLUSTER_HEADER;
		uint8_t tmp[SIZE_H1];

		/* Cluster exists? */
		if ((pos / SIZE_CLUSTER_HEADER) > nb_cluster)
			break;

		/* Get H1 */
		memcpy(tmp, &header[pos + OFFSET_H1], SIZE_H1);

		/* Calculate SHA-1 hash */
		sha1(tmp, SIZE_H1, &h2[20 * i]);
	}

	/* Write H2 table */
	for (i = 0; i < nb_cluster; i++)
	{
		uint32_t nb = SIZE_CLUSTER_HEADER * i;

		/* Write H2 table */
		memcpy(&header[nb + OFFSET_H2], h2, SIZE_H2);
	}

	/* Set title key */
	title_key = &(iso->parts[partition].title_key[0]);

	/* Encrypt headers */
	for (i = 0; i < nb_cluster; i++)
	{
		uint8_t *ptr = &header[SIZE_CLUSTER_HEADER * i];

		uint8_t phData[SIZE_CLUSTER_HEADER];

		/* Set IV key */
		memset(iv, 0, 16);

		/* Encrypt */
		aes_cbc_enc(ptr, (uint8_t*) phData, SIZE_CLUSTER_HEADER, title_key, iv);
		memcpy(ptr, (uint8_t*)phData, SIZE_CLUSTER_HEADER);
	}

	/* Encrypt clusters */
	for (i = 0; i < nb_cluster; i++)
	{
		uint8_t *d_ptr = &data[SIZE_CLUSTER_DATA * i];
		uint8_t *h_ptr = &header[SIZE_CLUSTER_HEADER * i];

		uint8_t phData[SIZE_CLUSTER_DATA];


		/* Set IV key */
		memcpy(iv, &h_ptr[OFFSET_CLUSTER_IV], 16);

		/* Encrypt */
		aes_cbc_enc(d_ptr, (uint8_t*) phData, SIZE_CLUSTER_DATA, title_key, iv);
		memcpy(d_ptr, (uint8_t*)phData, SIZE_CLUSTER_DATA);
	}

	/* Jump to first cluster in the group */
	offset = iso->parts[partition].offset + iso->parts[partition].data_offset + (uint64_t)((uint64_t)f_cluster * (uint64_t)SIZE_CLUSTER);

	/* Write new clusters */
	for (i = 0; i < nb_cluster; i++)
	{
		uint8_t *d_ptr = &data[SIZE_CLUSTER_DATA * i];
		uint8_t *h_ptr = &header[SIZE_CLUSTER_HEADER * i];

		/* Write cluster header */
		if (true==DiscWriteDirect(iso, offset, h_ptr, SIZE_CLUSTER_HEADER))
		{
			// written ok, add value to offset
			offset = offset + SIZE_CLUSTER_HEADER;

			if (true==DiscWriteDirect(iso, offset, d_ptr, SIZE_CLUSTER_DATA))
			{
				offset = offset + SIZE_CLUSTER_DATA;
			}
			else
			{
				free(data);
				free(header);
				return false;

			}
		}
		else
		{
			// free memory and return error
			free(data);
			free(header);
			return false;
		}
	}

	/* Recalculate global hash table */
	if (wii_calc_group_hash(iso, partition, cluster))
	{
		free(data);
		free(header);
		return false;
	}

	/* Free memory */
	free(data);
	free(header);

	return true;
}


bool WiiDisc::wii_read_cluster_hashes(struct ImageFile *iso, int partition, int cluster, uint8_t *h0, uint8_t *h1, uint8_t *h2)
{
	uint8_t buf[SIZE_CLUSTER_HEADER];

	/* Read cluster header */
	if (wii_read_cluster(iso, partition, cluster, NULL, buf))
		return false;

	if (NULL!=h0)
		memcpy(h0, buf + OFFSET_H0, SIZE_H0);
	if (NULL!=h1)
		memcpy(h1, buf + OFFSET_H1, SIZE_H1);
	if (NULL!=h2)
		memcpy(h2, buf + OFFSET_H2, SIZE_H2);

	return true;
}

int WiiDisc::wii_read_data(struct ImageFile *iso, int partition, uint64_t offset, uint32_t size, uint8_t **out)
{
	uint8_t *buf, *tmp;
	uint32_t cluster_start, clusters, i, offset_start;


	/* Calculate some needed information */
	cluster_start = (uint32_t)(offset / (uint64_t)(SIZE_CLUSTER_DATA));
	clusters = (uint32_t)(((offset + (uint64_t)(size)) / (uint64_t)(SIZE_CLUSTER_DATA))) - (cluster_start - 1);
	offset_start = (uint32_t)(offset - (cluster_start * (uint64_t)(SIZE_CLUSTER_DATA)));

	/* Allocate memory */
	buf = (uint8_t *)calloc(clusters * SIZE_CLUSTER_DATA,1);
	if (!buf)
		return 1;

	/* Read clusters */
	for (i = 0; i < clusters; i++)
		if (wii_read_cluster(iso, partition, cluster_start + i, &buf[SIZE_CLUSTER_DATA * i], NULL))
			return 1;

	/* Allocate memory */
	tmp = (uint8_t *)calloc(size,1);
	if (!tmp)
		return 1;

	/* Copy specified data */
	memcpy(tmp, buf + offset_start, size);

	/* Free unused memory */
	free(buf);

	/* Set pointer address */
	*out = tmp;

	return 0;
}


void WiiDisc::sha1(uint8_t *data, uint32_t len, uint8_t *hash)
{
	SHA1(data, len, hash);
}

void WiiDisc::aes_cbc_enc(uint8_t *in, uint8_t *out, uint32_t len, uint8_t *key, uint8_t *iv)
{
	AES_KEY aes_key;

	/* Set encryption key */
	AES_set_encrypt_key(key, 128, &aes_key);

	/* Decrypt data */
	AES_cbc_encrypt(in, out, len, &aes_key, iv, AES_ENCRYPT);
}

void WiiDisc::aes_cbc_dec(uint8_t *in, uint8_t *out, uint32_t len, uint8_t *key, uint8_t *iv)
{
	AES_KEY aes_key;

	/* Set decryption key */
	AES_set_decrypt_key(key, 128, &aes_key);

	/* Decrypt data */
	AES_cbc_encrypt(in, out, len, &aes_key, iv, AES_DECRYPT);
}

largesize_t WiiDisc::findRequiredFreeSpaceInPartition(uint64_t nPartition, uint32_t nRequiredSize)
{

	// search through the free space to find a free area that is at least
	// the required size. We can then return the position of the free space
	// relative to the data area of the partition
	char cLastBlock = 1; // assume (!) that we have data at the partition start

	int nRequiredBlocks = (nRequiredSize / 0x7c00);

	if (0!=(nRequiredSize%0x7c00))
	{
		// we require an extra block
		nRequiredBlocks++;
	}

	offset_t nReturnOffset = 0;

	offset_t nStartOffset = m_imageFile->parts[nPartition].offset + m_imageFile->parts[nPartition].data_offset;

	offset_t nEndOffset = nStartOffset + m_imageFile->parts[nPartition].data_size;
	offset_t nCurrentOffset = nStartOffset;

	offset_t nMarkedStart = 0;
	int nFreeBlocks = 0;
	int nBlock = 0;

	// now go through the marked list to find the free area of the required size
	while (nCurrentOffset < nEndOffset)
	{
		nBlock = (uint32_t)(nCurrentOffset / (uint64_t)(0x8000));
		if (cLastBlock!=pFreeTable[nBlock])
		{
			// change
			if (1==cLastBlock)
			{
				// we have the first empty space
				nMarkedStart = nCurrentOffset;
				nFreeBlocks = 1;
			}
			// else we just store the value and wait for one of the other fallouts
		}
		else
		{
			// same so if we have a potential run
			if (0==cLastBlock)
			{
				// add the block to the size
				nFreeBlocks ++;
				// now check to see if we have enough
				if (nFreeBlocks >= nRequiredBlocks)
				{
					// BINGO! - convert into relative offset from data start
					// and in encrypted format
					nReturnOffset = ((nMarkedStart - nStartOffset) / (uint64_t) 0x8000) * (uint64_t)(0x7c00);
					return nReturnOffset;
				}
			}
		}
		cLastBlock = pFreeTable[nBlock];

		nCurrentOffset += 0x8000;
	}

	// if we get here then we didn't find some space :(

	return 0;
}

/////////////////////////////////////////////////////////////
// Check to see if we have free space for so many blocks   //
/////////////////////////////////////////////////////////////

BOOL WiiDisc::CheckForFreeSpace(uint32_t nPartition, uint64_t nOffset, uint32_t nBlocks)
{

	// convert offset to block representation
	uint32_t nBlockOffsetStart = 0;

	nBlockOffsetStart = (uint32_t)((m_imageFile->parts[nPartition].data_offset + m_imageFile->parts[nPartition].offset) / (uint64_t)0x8000);
	nBlockOffsetStart = nBlockOffsetStart + (uint32_t)(nOffset / (uint64_t) 0x7c00);
	if (0!=nOffset%0x7c00)
	{
		// starts part way into a block so need to check the number of blocks plus one
		nBlocks++;
		// and the start is up by one as we know that there must be data in the current
		// block
		nBlockOffsetStart++;
	}

	for (uint32_t x = 0; x < nBlocks; x++)
	{
		if (1==pFreeTable[nBlockOffsetStart+x])
		{
			return false;
		}
	}
	return true;
}

//////////////////////////////////////////////////////////////////////////
// Routine deletes the highlighted partition                            //
// does this by moving all the sucessive data up in the partition table //
// to overwrite the deleted partition                                   //
// It then updates the partition count                                  //
// Also works on channels                                               //
//////////////////////////////////////////////////////////////////////////
/*
BOOL WIIDisc::DeletePartition(uint32_t nPartition)
{

	uint8_t	buffer[16];
	uint64_t	WriteLocation;
	int	i;

	memset(buffer,0,16);

	// check the partition is either a partition or a channel
	if (PART_VC == m_imageFile->parts[nPartition].type)
	{
		// use the channels

		// find out which partition we are really deleting
		// as the value is offset by the number of real partitions
		nPartition = nPartition - m_imageFile->PartitionCount;

		// update the count of channels in the correct location
		Write32(buffer, m_imageFile->ChannelCount -1);
		DiscWriteDirect(m_imageFile, (uint64_t) 0x40008, buffer, 4);

		// create the updated channel list in the correct location on the disc
		WriteLocation = m_imageFile->chan_tbl_offset + (uint64_t)(8)*(uint64_t)(nPartition - 1);

		for (i = nPartition; i < m_imageFile->ChannelCount; i++)
		{
			// read the next partition info
			io_read(buffer, 8, m_imageFile, m_imageFile->chan_tbl_offset + (uint64_t)(8)*(uint64_t)(i));
			// write it out over the deleted one
			DiscWriteDirect(m_imageFile, WriteLocation, buffer, 8);
			WriteLocation = WriteLocation + 8;
		}
		// now overwrite the last one with blanks
		memset(buffer,0,16);
		DiscWriteDirect(m_imageFile, WriteLocation, buffer, 8);

	}
	else
	{
		// it's the partition table

		// update the count of partitions
		Write32(buffer, m_imageFile->PartitionCount -1);
		DiscWriteDirect(m_imageFile, (uint64_t) 0x40000, buffer, 4);

		// create the partition table
		WriteLocation = m_imageFile->part_tbl_offset + (uint64_t)(8)*(uint64_t)(nPartition - 1);

		for (i = nPartition; i < m_imageFile->PartitionCount; i++)
		{
			// read the next partition info
			io_read(buffer, 8, m_imageFile, m_imageFile->part_tbl_offset + (uint64_t)(8)*(uint64_t)(i));
			// write it out over the deleted one
			DiscWriteDirect(m_imageFile, WriteLocation, buffer, 8);
			WriteLocation = WriteLocation + 8;
		}
		// now overwrite the last one with blanks
		memset(buffer,0,16);
		DiscWriteDirect(m_imageFile, WriteLocation, buffer, 8);

	}

	return true;
}
*/

//////////////////////////////////////////////////////////////////////////
// Resize the partition data size field                                 //
// as some discs have 'interesting' values in here                      //
//////////////////////////////////////////////////////////////////////////
/*
BOOL WIIDisc::ResizePartition(uint32_t nPartition)
{
	uint64_t nCurrentSize = 0;
	uint64_t nMinimumSize = 0;
	uint64_t nMaximumSize = 0;
	uint64_t nNewSize = 0;

	uint8_t buffer[16];

	// Get size of current partition
	nCurrentSize = m_imageFile->parts[nPartition].data_size;
	nNewSize = nCurrentSize;

	// calculate maximum size (based on next partition start)
	// or disc size if the last one

	if ((nPartition+1)==m_imageFile->nparts)
	{
		nMaximumSize = nImageSize;
	}
	else
	{
		nMaximumSize = m_imageFile->parts[nPartition+1].offset;
	}
	nMaximumSize = nMaximumSize - m_imageFile->parts[nPartition].offset;
	nMaximumSize = nMaximumSize - m_imageFile->parts[nPartition].data_offset;

	// calculate minimum size by looking for where the data is
	// on the disc backwards from the current partition data end
	// create the window with the data

	nMinimumSize = SearchBackwards(nMaximumSize, m_imageFile->parts[nPartition].offset + m_imageFile->parts[nPartition].data_offset);

	// create window and
	// and then ask for the values
	CResizePartition * pWindow = new CResizePartition();


	pWindow->SetRanges(nMinimumSize, nCurrentSize, nMaximumSize);

	if (IDOK==pWindow->DoModal())
	{
		// if values changed and OK pressed then update the correct pointer in the disc
		// image
		nNewSize = pWindow->GetNewSize();

		delete pWindow;
		if (nNewSize == nCurrentSize)
		{
			AddToLog("Sizes the same");
			return false;
		}

		// now simply write out the new size and store it
		m_imageFile->parts[nPartition].data_size = nNewSize;
		Write32(buffer, (uint32_t)((uint64_t) nNewSize >> 2));
		DiscWriteDirect(m_imageFile->parts[nPartition].offset + 0x2bc, buffer, 4);

		return true;
	}
	// don't even need to reparse as the values will be updated internally
	delete pWindow;
	return false;
}
*/


uint64_t WiiDisc::SearchBackwards(uint64_t nStartPosition, uint64_t nEndPosition)
{

	uint64_t nCurrentBlock;
	uint64_t nEndBlock;
	uint64_t	nStartBlock;

	nCurrentBlock = (nStartPosition + nEndPosition - 1)/ (uint64_t)(0x8000);
	nStartBlock = nCurrentBlock;

	nEndBlock = nEndPosition / (uint64_t)(0x8000);

	while (nCurrentBlock > nEndBlock)
	{
		if (0==pFreeTable[nCurrentBlock])
		{
			nCurrentBlock --;
		}
		else
		{
			// if it's the first block then we are at the start position
			if (nStartBlock==nCurrentBlock)
			{
				return (nCurrentBlock - nEndBlock + 1)* ((uint64_t)(0x8000));
			}
			else
			{
				return (nCurrentBlock - nEndBlock )* ((uint64_t)(0x8000));
			}
		}
	}
	return 0;
}


////////////////////////////////////////////////////////////////////////////
// Modification of the write_cluster function to write multiple clusters  //
// in one sitting. This means the disc access should then be minimized    //
// It also allows for a file to be used for the input instead of a memory //
// pointer as that allows for larger files to be updated. I'm talking to  //
// you Okami.....                                                         //
////////////////////////////////////////////////////////////////////////////
bool WiiDisc::wii_write_clusters(struct ImageFile *iso, int partition, int cluster, uint8_t *in, uint32_t nClusterOffset, uint32_t nBytesToWrite, FILE * fIn)
{
	uint8_t h0[SIZE_H0];
	uint8_t h1[SIZE_H1];
	uint8_t h2[SIZE_H2];

	uint8_t *data;
	uint8_t *header;
	uint8_t *title_key;

	uint8_t iv[16];

	uint32_t group,
	subgroup,
	f_cluster,
	nb_cluster,
	pos_cluster,
	pos_header;

	uint64_t offset;

	uint32_t i;
	int j;

	//int ret = 0;

	int nClusters = 0;

	/* Calculate cluster group and subgroup */
	group = cluster / NB_CLUSTER_GROUP;
	subgroup = (cluster % NB_CLUSTER_GROUP) / NB_CLUSTER_SUBGROUP;

	/* First cluster in the group */
	f_cluster = group * NB_CLUSTER_GROUP;

	/* Get number of clusters in this group */
	nb_cluster = wii_nb_cluster(iso, partition) - f_cluster;
	if (nb_cluster > NB_CLUSTER_GROUP)
		nb_cluster = NB_CLUSTER_GROUP;

	/* Allocate memory */
	data   = (uint8_t *)calloc(SIZE_CLUSTER_DATA * NB_CLUSTER_GROUP, 1);
	header = (uint8_t *)calloc(SIZE_CLUSTER_HEADER * NB_CLUSTER_GROUP, 1);
	if (!data || !header)
		return false;

	// if we are replacing a full set of clusters then we don't
	// need to do any reading as we just need to overwrite the
	// blanked data


	// calculate number of clusters of data to write
	nClusters = ((nBytesToWrite -1)/ SIZE_CLUSTER_DATA)+1;

	if (nBytesToWrite!=(NB_CLUSTER_GROUP*SIZE_CLUSTER_DATA))
	{
		/* Read group clusters and headers */
		for (i = 0; i < nb_cluster; i++)
		{
			uint8_t *d_ptr = &data[SIZE_CLUSTER_DATA * i];
			uint8_t *h_ptr = &header[SIZE_CLUSTER_HEADER * i];

			/* Read cluster */
			if (wii_read_cluster(iso, partition, f_cluster + i, d_ptr, h_ptr))
			{
				free(data);
				free(header);
				return false;
			}
		}
	}
	else
	{
		// memory already cleared
	}

	// now overwrite the data in the correct location
	// be it from file data or from the memory location
	/* Write new cluster and H0 table */
	pos_header  = ((cluster - f_cluster) * SIZE_CLUSTER_HEADER);
	pos_cluster = ((cluster - f_cluster) * SIZE_CLUSTER_DATA);


	// we read from either memory or a file
	if (NULL!=fIn)
	{
		fread(&data[pos_cluster + nClusterOffset],1, nBytesToWrite, fIn);
	}
	else
	{
		// data
		memcpy(&data[pos_cluster + nClusterOffset], in, nBytesToWrite);
	}

	// now for each cluster we need to...
	for(j = 0; j < nClusters; j++)
	{
		// clear the data for the table
		memset(h0, 0, SIZE_H0);

		/* Calculate new clusters H0 table */
		for (i = 0; i < SIZE_CLUSTER_DATA; i += 0x400)
		{
			uint32_t idx = (i / 0x400) * 20;

			/* Calculate SHA-1 hash */
			sha1(&data[pos_cluster + (j * SIZE_CLUSTER_DATA) + i], 0x400, &h0[idx]);
		}

		// save the H0 data
		memcpy(&header[pos_header + (j * SIZE_CLUSTER_HEADER)], h0, SIZE_H0);

		// now do the H1 data for the subgroup
		/* Calculate H1's */
		sha1(&header[pos_header + (j * SIZE_CLUSTER_HEADER)], SIZE_H0, h1);

		// now copy to all the sub cluster locations
		for (int k=0; k < NB_CLUSTER_SUBGROUP; k++)
		{
			// need to get the position of the first block we are changing
			// which is the start of the subgroup for the current cluster
			uint32_t nSubGroup = ((cluster + j) % NB_CLUSTER_GROUP) / NB_CLUSTER_SUBGROUP;

			uint32_t pos = (SIZE_CLUSTER_HEADER * nSubGroup * NB_CLUSTER_SUBGROUP) + (0x14 * ((cluster +j)%NB_CLUSTER_SUBGROUP));

			memcpy(&header[pos + (k * SIZE_CLUSTER_HEADER) + OFFSET_H1], h1, 20);
		}

	}


	// now we need to calculate the H2's for all subgroups
	/* Calculate H2 */
	for (i = 0; i < NB_CLUSTER_SUBGROUP; i++)
	{
		uint32_t pos = (NB_CLUSTER_SUBGROUP * i) * SIZE_CLUSTER_HEADER;

		/* Cluster exists? */
		if ((pos / SIZE_CLUSTER_HEADER) > nb_cluster)
			break;

		/* Calculate SHA-1 hash */
		sha1(&header[pos + OFFSET_H1], SIZE_H1, &h2[20 * i]);
	}

	/* Write H2 table */
	for (i = 0; i < nb_cluster; i++)
	{
		/* Write H2 table */
		memcpy(&header[(SIZE_CLUSTER_HEADER * i) + OFFSET_H2], h2, SIZE_H2);
	}

	// update the H3 key table here
	/* Calculate SHA-1 hash */
	sha1(h2, SIZE_H2, &m_h3[group * 0x14]);


	// now encrypt and write

	/* Set title key */
	title_key = &(iso->parts[partition].title_key[0]);

	/* Encrypt headers */
	for (i = 0; i < nb_cluster; i++)
	{
		uint8_t *ptr = &header[SIZE_CLUSTER_HEADER * i];

		uint8_t phData[SIZE_CLUSTER_HEADER];

		/* Set IV key */
		memset(iv, 0, 16);

		/* Encrypt */
		aes_cbc_enc(ptr, (uint8_t*) phData, SIZE_CLUSTER_HEADER, title_key, iv);
		memcpy(ptr, (uint8_t*)phData, SIZE_CLUSTER_HEADER);
	}

	/* Encrypt clusters */
	for (i = 0; i < nb_cluster; i++)
	{
		uint8_t *d_ptr = &data[SIZE_CLUSTER_DATA * i];
		uint8_t *h_ptr = &header[SIZE_CLUSTER_HEADER * i];

		uint8_t phData[SIZE_CLUSTER_DATA];


		/* Set IV key */
		memcpy(iv, &h_ptr[OFFSET_CLUSTER_IV], 16);

		/* Encrypt */
		aes_cbc_enc(d_ptr, (uint8_t*) phData, SIZE_CLUSTER_DATA, title_key, iv);
		memcpy(d_ptr, (uint8_t*)phData, SIZE_CLUSTER_DATA);
	}

	/* Jump to first cluster in the group */
	offset = iso->parts[partition].offset + iso->parts[partition].data_offset + (uint64_t)((uint64_t)f_cluster * (uint64_t)SIZE_CLUSTER);

	for (i = 0; i < nb_cluster; i++)
	{
		uint8_t *d_ptr = &data[SIZE_CLUSTER_DATA * i];
		uint8_t *h_ptr = &header[SIZE_CLUSTER_HEADER * i];

		if (true==DiscWriteDirect(iso, offset, h_ptr, SIZE_CLUSTER_HEADER))
		{
			// written ok, add value to offset
			offset = offset + SIZE_CLUSTER_HEADER;

			if (true==DiscWriteDirect(iso, offset, d_ptr, SIZE_CLUSTER_DATA))
			{
				offset = offset + SIZE_CLUSTER_DATA;
			}
			else
			{
				free(data);
				free(header);
				return false;

			}
		}
		else
		{
			// free memory and return error
			free(data);
			free(header);
			return false;
		}
	}


	// already calculated the H3 and H4 hashes - rely on surrounding code to
	// read and write those out

	/* Free memory */
	free(data);
	free(header);

	return true;
}

////////////////////////////////////////////////////////////////////////////
// Heavily optimised file write routine so that the minimum number of     //
// SHA calculations have to be performed                                  //
// We do this by writing in 1 clustergroup per write and calculate the    //
// Offset to write the data in the minimum number of chunks               //
// A bit like lumpy chunk packer from the Atari days......................//
////////////////////////////////////////////////////////////////////////////
BOOL WiiDisc::wii_write_data_file(struct ImageFile *iso, int partition, uint64_t offset, uint64_t size, uint8_t *in, FILE * fIn, IWiiDiscProcessHandler* _ProgressBox)
{
	uint32_t cluster_start, clusters, offset_start;

	uint64_t i;

	uint32_t nClusterCount;
	uint32_t nWritten = 0;
	//MSG msg;


	/* Calculate some needed information */
	cluster_start = (uint32_t)(offset / (uint64_t)(SIZE_CLUSTER_DATA));
	clusters = (uint32_t)(((offset + size) / (uint64_t)(SIZE_CLUSTER_DATA)) - (cluster_start - 1));
	offset_start = (uint32_t)(offset - (cluster_start * (uint64_t)(SIZE_CLUSTER_DATA)));


	// read the H3 and H4
	io_read(m_h3, SIZE_H3, iso, iso->parts[partition].offset + iso->parts[partition].h3_offset);

	/* Write clusters */
	i = 0;
	nClusterCount = 0;

	if(_ProgressBox)
	{
		_ProgressBox->setPosition(0);
		_ProgressBox->setRange(0, clusters - 1);
	}


	if(_ProgressBox) _ProgressBox->setText("Replacing file: please wait");
	while( i < size)
	{
		if(_ProgressBox) _ProgressBox->setPosition(nClusterCount);

		// do the message pump thang
		/*
		  if (PeekMessage(&msg,
			  NULL,
			  0,
			  0,
			  PM_REMOVE))
		  {
			  // PeekMessage has found a message--process it
			  if (msg.message != WM_CANCELLED)
			  {
				  TranslateMessage(&msg); // Translate virt. key codes
				  DispatchMessage(&msg);  // Dispatch msg. to window
			  }
			else
			{
				// quit message received - simply exit
				//delete pProgressBox;
				AddToLog("Load cancelled - disc probably unusable");
				AfxMessageBox("Load cancelled - disc probably unusable in current state");
				return false;
			}
		  }
		  */
		// now the fun bit as we need to cater for the start position changing as well as the
		// wrap over
		if ((0!=((cluster_start+nClusterCount)%64))||
				(0!=offset_start))
		{
			// not at the start so our max size is different
			// and also our cluster offset
			nWritten = (NB_CLUSTER_GROUP - (cluster_start%64))* SIZE_CLUSTER_DATA;
			nWritten = nWritten - offset_start;

			// max check
			if (nWritten > size)
			{
				nWritten = (uint32_t)size;
			}

			if (false==wii_write_clusters(iso, partition, cluster_start, in, offset_start, nWritten, fIn))
			{
				// Error
				//delete pProgressBox;
				AfxMessageBox("Error writing clusters");
				return false;
			}
			// round up the cluster count
			nClusterCount = NB_CLUSTER_GROUP - (cluster_start % NB_CLUSTER_GROUP);
		}
		else
		{
			// potentially full block
			nWritten = NB_CLUSTER_GROUP * SIZE_CLUSTER_DATA;

			// max check
			if (nWritten > (size-i))
			{
				nWritten = (uint32_t)(size-i);
			}

			if (false==wii_write_clusters(iso, partition, cluster_start + nClusterCount, in, offset_start, nWritten, fIn))
			{
				// Error
				//delete pProgressBox;
				AfxMessageBox("Error writing clusters");
				return false;
			}
			// we simply add a full cluster block
			nClusterCount = nClusterCount + NB_CLUSTER_GROUP;

		}
		offset_start = 0;
		i += nWritten;


	}

	//delete pProgressBox;

	// write out H3 and H4

	if (false==DiscWriteDirect(iso, iso->parts[partition].h3_offset + iso->parts[partition].offset, m_h3, SIZE_H3))
	{
		AfxMessageBox("Unable to write H3 table");
		return false;
	}


	/* Calculate H4 */
	sha1(m_h3, SIZE_H3, m_h4);

	/* Write H4 */
	if (false==DiscWriteDirect(iso, iso->parts[partition].tmdOffset + OFFSET_TMD_HASH + iso->parts[partition].offset, m_h4, SIZE_H4))
	{
		AfxMessageBox("Unable to write H4 value");
		return false;
	}

	// sign it
	wii_trucha_signing(iso, partition);

	return true;
}

/*
HoRRoR

BOOL WIIDisc::SetBootMode(image_file *image)
{
	uint8_t cOldValue;
	int i;

	unsigned char cModes[5] = {'R','_','H','0','4'};
	CString csText;

	// get the current first byte of data from the passed ISO
	io_read(&cOldValue, 1, image, 0);

	for (i = 0; i < 5; i++)
	{
		if (cOldValue==cModes[i])
		{
			break;
		}
	}

	// check for error - not found
	// should NEVER get error as it would have failed the initial parse
	// routine
	if (5==i)
	{
		csText.Format("Current mode not valid = %x [%c]", cOldValue, cOldValue);
		AfxMessageBox(csText);
		return false;
	}

	// Create the change display
	// create window and
	// and then ask for the values

	CBootMode * pWindow = new CBootMode();
	pWindow->SetBootMode(i);

	if (IDOK==pWindow->DoModal())
	{
		// if values changed and OK pressed then update the correct pointer in the disc
		// image
		if (i!=pWindow->GetBootMode())

		{
			// changed so alter byte
			DiscWriteDirect(image, 0, &cModes[pWindow->GetBootMode()], 1);
			csText.Format("Boot mode now [%c]", cModes[pWindow->GetBootMode()]);
			AddToLog(csText);
		}
		else
		{
			// same value
			AddToLog("Same boot mode - no action taken");
		}


	}
	else
	{
		AddToLog("Boot change cancelled");
	}
	delete pWindow;
	return true;
}
*/

BOOL WiiDisc::AddPartition(BOOL bChannel, uint64_t nOffset, uint64_t nDataSize, uint8_t * pText)
{

	// just try and see if this works at the moment
	uint8_t	buffer[16];
	uint64_t	WriteLocation;

	memset(buffer,0,16);

	// check the partition is either a partition or a channel
	if (true==bChannel)
	{
		// use the channels
		// update the count of channels in the correct location
		Write32(buffer, m_imageFile->ChannelCount +1);
		DiscWriteDirect(m_imageFile, (uint64_t) 0x40008, buffer, 4);

		// check to see if we actually have any channels defined and hence a value in the channel table offset
		if (0==m_imageFile->chan_tbl_offset)
		{
			// we need to create the table from scratch
			m_imageFile->chan_tbl_offset = 0x41000;
			Write32(buffer, 0x41000 >> 2);
			DiscWriteDirect(m_imageFile, (uint64_t) 0x4000C, buffer, 4);
		}
		// create the updated channel list in the correct location on the disc
		WriteLocation = m_imageFile->chan_tbl_offset + (uint64_t)(8)*(uint64_t)(m_imageFile->ChannelCount);
		// write out the correct data block
		// set the buffer for start location and channel name
		Write32(buffer, (uint32_t)(nOffset>>2));
		buffer[4] = pText[0];
		buffer[5] = pText[1];
		buffer[6] = pText[2];
		buffer[7] = pText[3];

		DiscWriteDirect(WriteLocation, buffer, 8);

	}
	else
	{
		// it's the partition table

		// update the count of partitions
		Write32(buffer, m_imageFile->PartitionCount +1);
		DiscWriteDirect(m_imageFile, (uint64_t) 0x40000, buffer, 4);

		// create the partition table entry
		WriteLocation = m_imageFile->part_tbl_offset + (uint64_t)(8)*(uint64_t)(m_imageFile->PartitionCount);

		// set the buffer
		Write32(buffer, (uint32_t)(nOffset>>2));
		Write32(buffer+4, 0);

		DiscWriteDirect(m_imageFile, WriteLocation, buffer, 8);

	}

	// now create the necessary fake entries for all the data block values
	// h3 = 0x2b4
	Write32(buffer, 0x8000 >> 2);
	// data offset = 0x2b8
	Write32(buffer+4, 0x20000 >> 2);
	// data size = 0x2bc
	Write32(buffer+8, (uint32_t)(nDataSize >> 2));
	DiscWriteDirect(m_imageFile, nOffset+0x2b4, buffer, 12);

	// Should now create a fake boot.bin etc. to avoid disc reads and allow you to modify the
	// partition



	return true;
}

/////////////////////////////////////////////////////////////
// Function to find out the maximum size of a partition    //
// that can be added to the current image                  //
/////////////////////////////////////////////////////////////
uint64_t WiiDisc::GetFreeSpaceAtEnd()
{
	uint64_t nRetVal;

	// simple enough calculation in that we simply take the last partitions
	// offset and size and 0x1800 off the image size

	if (1==m_imageFile->nparts)
	{
		// no partitions here. We now use the image size minus the
		// default offset of 0x50000

		nRetVal = nImageSize - 0x50000;
	}
	else
	{
		// it's equal to the image minus size of the last partition and offset
		nRetVal = nImageSize - m_imageFile->parts[m_imageFile->nparts-1].offset - m_imageFile->parts[m_imageFile->nparts-1].data_offset
				  - m_imageFile->parts[m_imageFile->nparts-1].data_size;
	}

	return nRetVal;
}

////////////////////////////////////////////////////////////
// Gets the start of the partion space                    //
////////////////////////////////////////////////////////////
uint64_t WiiDisc::GetFreePartitionStart()
{
	uint64_t nRetVal;

	if (1==m_imageFile->nparts)
	{
		// default offset of 0x50000

		nRetVal = 0x50000;
	}
	else
	{
		// get the first free byte at the end
		nRetVal = m_imageFile->parts[m_imageFile->nparts-1].offset +  m_imageFile->parts[m_imageFile->nparts-1].data_offset
				  + m_imageFile->parts[m_imageFile->nparts-1].data_size;
	}



	return nRetVal;
}
/////////////////////////////////////////////////////////////
// Goes through the partitions moving them up and updating //
// the partition table                                     //
/////////////////////////////////////////////////////////////

BOOL WiiDisc::DoTheShuffle()
{

	BOOL bRetVal = false;
	uint64_t nStoreLocation = 0x50000;
	uint64_t nPartitionStart;
	uint64_t nLength = 0;
	uint64_t nWriteLocation;

	uint8_t	nBuffer[4];

	for (unsigned int i=1; i < m_imageFile->nparts; i++)
	{

		// get the length and start of the partition
		nPartitionStart = m_imageFile->parts[i].offset;
		nLength = m_imageFile->parts[i].data_size + 0x20000;

		// check to see if we need to move it
		if (nPartitionStart != nStoreLocation)
		{
			// move the partition down

			if (false==CopyDiscDataDirect(i, nPartitionStart, nStoreLocation, nLength))
			{
				// cancelled
				return false;
			}
			// show we have modified something

			bRetVal = true;
			Write32(nBuffer, (uint32_t)(nStoreLocation >> 2));
			// update the correct table
			if (i > image->PartitionCount)
			{
				// use the channel table
				// create the updated channel list in the correct location on the disc
				nWriteLocation = image->chan_tbl_offset + (uint64_t)(8)*(uint64_t)(i - image->PartitionCount -1);
				DiscWriteDirect(image, nWriteLocation, nBuffer, 4);
			}
			else
			{
				// use the partition table
				nWriteLocation = image->part_tbl_offset + (uint64_t)(8)*(uint64_t)(i-1);
				DiscWriteDirect(image, nWriteLocation, nBuffer, 4);
			}
		}
		nStoreLocation = nLength + nStoreLocation;
	}
	return bRetVal;
}

//////////////////////////////////////////////////////////////
// Copy data between two parts of the disc image            //
//////////////////////////////////////////////////////////////
BOOL WiiDisc::CopyDiscDataDirect(ImageFile * image, int nPart, uint64_t nSource, uint64_t nDest, uint64_t nLength)
{
//	MSG msg;

	// optomise for 32k chunks
	uint64_t nCount;
	uint32_t nBlocks = 0;
	uint32_t nBlockCount = 0;
	uint32_t nReadCount = 0;

	uint8_t * pData;

	// try and use 1 meg at a time
	pData = (uint8_t *)malloc(0x100000);

	nCount = 0;
	nBlocks =0;
	nBlockCount = (uint32_t)((nLength / 0x100000) + 1);

	// now open a progress bar
	if(m_progressHandler) m_progressHandler->setRange(0, nBlockCount);

	if(m_progressHandler) m_progressHandler->setPosition(0);

	CString csTempString;

	//csTempString.Format("Copying down partition %d", nPart);
	if(m_progressHandler) m_progressHandler->setText(csTempString.data());

	// now the loop
	while (nCount < nLength)
	{

		if(m_progressHandler) m_progressHandler->setPosition(nBlocks);

		nReadCount = 0x100000;
		if (nReadCount > (nLength-nCount))
		{
			nReadCount = (uint32_t)(nLength - nCount);
		}

		io_read(pData, nReadCount, image, nSource);

		// usual message pump
		/*
		if (PeekMessage(&msg,
						NULL,
						0,
						0,
						PM_REMOVE))
		{
			// PeekMessage has found a message--process it
			if (msg.message != WM_CANCELLED)
			{
				TranslateMessage(&msg); // Translate virt. key codes
				DispatchMessage(&msg);  // Dispatch msg. to window
			}
			else
			{
				AddToLog("Cancelled - probably unusable now");
				//delete pProgressBox;
				return false;
			}
		}
*/

		DiscWriteDirect(image, nDest, pData, nReadCount);

		nDest = nDest + nReadCount;
		nSource = nSource + nReadCount;
		nBlocks++;
		nCount = nCount + nReadCount;
	}
	//delete pProgressBox;


	free(pData);
	return true;
}
////////////////////////////////////////////////////////////////////
// Save a decrypted partition out                                 //
////////////////////////////////////////////////////////////////////
bool WiiDisc::saveDecryptedPartition(const std::string& filename, ImageFile *image, uint32_t nPartition)
{
//	MSG msg;

	// now open a progress bar
	uint64_t	nStartOffset;
	uint64_t nLength;
	uint64_t nOffset = 0;

	uint8_t * pData;
	FILE * fOut;
	uint32_t nBlockCount = 0;

	fOut = fopen(filename.data(), "wb");

	if (NULL==fOut)
	{
		// Error
		return false;
	}

	// now get the parameters we need to save
	nStartOffset = image->parts[nPartition].offset;
	nLength = image->parts[nPartition].data_size;

	pData = (uint8_t *)malloc(0x20000);

	// save the first 0x20000 bytes direct as thats the partition.bin
	io_read(pData,0x20000, image, nStartOffset);
	fwrite(pData,1, 0x20000, fOut);
	if(m_progressHandler)
	{
		m_progressHandler->setRange(0, (uint32_t)(nLength / 0x8000));
		m_progressHandler->setPosition(0);
		m_progressHandler->setText("Saving partition");
	}
	// then step through the clusters
	nStartOffset = 0;
	for (uint64_t nCount = 0; nCount < nLength; nCount = nCount + 0x8000)
	{
		if(m_progressHandler) m_progressHandler->setPosition(nBlockCount);
		io_read_part(pData, 0x7c00, image, nPartition, nOffset);
		// usual message pump
		/*
		if (PeekMessage(&msg,
						NULL,
						0,
						0,
						PM_REMOVE))
		{
			// PeekMessage has found a message--process it
			if (msg.message != WM_CANCELLED)
			{
				TranslateMessage(&msg); // Translate virt. key codes
				DispatchMessage(&msg);  // Dispatch msg. to window
			}
			else
			{
				AddToLog("Cancelled save");
				//delete pProgressBox;
				free(pData);
				return false;
			}
		}
		*/
		fwrite(pData, 1,0x7c00, fOut);
		nOffset = nOffset + 0x7c00;
		nBlockCount++;
	}

	//delete pProgressBox;
	fclose(fOut);
	free(pData);
	return true;
}
////////////////////////////////////////////////////////
// Load a decrypted partition of data and fill the    //
// partition up with it                               //
////////////////////////////////////////////////////////
bool WiiDisc::loadDecryptedPartition(const std::string& name, ImageFile *image, int nPartition)
{
	// now open a progress bar
	uint64_t	nStartOffset;
	uint64_t nLength;

	uint8_t * pData;
	FILE * fIn;
	//uint32_t nBlockCount = 0;

	uint64_t nFileSize;

	fIn = fopen(name.data(), "rb");

	if (NULL==fIn)
	{
		// Error
		return false;
	}

	// now get the parameters we need to save
	nStartOffset = image->parts[nPartition].offset;
	nLength = image->parts[nPartition].data_size;


	// now check the size of the file we are trying to read in
	nFileSize = _lseeki64(fIn->_file, 0L, SEEK_END);
	_lseeki64(fIn->_file, 0L, SEEK_SET);

	// now account for the partition header and the actual number of clusters of data
	if (nLength < (((nFileSize - 0x20000)/0x7c00)* 0x8000))
	{
		// not enough space for the partition load
		AfxMessageBox("File too big to load into partition");
		fclose(fIn);
		return false;
	}

	pData = (uint8_t *)malloc(0x20000);

	// save the first 0x20000 bytes direct as thats the partition.bin
	fread(pData,1,0x20000, fIn);
	DiscWriteDirect(image, nStartOffset, pData, 0x20000);

	// now really need to parse the header for the new partition as the
	// title key etc. will be different
	get_partitions(image);

	// now write the file out
	if (false==wii_write_data_file(image, nPartition, 0, nFileSize-0x20000,NULL, fIn))
	{
		fclose(fIn);
		free(pData);
		return false;
	}


	fclose(fIn);
	free(pData);
	return true;
}

//////////////////////////////////////////////////////////////////////
// Shrink the data up in the partition                              //
// we just move the data up in the partition by finding out where   //
// the free space in the middle is and copying the data down from   //
// above it                                                         //
// we then update the fst.bin to take off however much we did       //
// to save time we copy from one cluster group star to another as   //
// then we don't need to recalculate the sha tables, just copy them //
// we also need to sign at the end                                  //
//////////////////////////////////////////////////////////////////////

bool WiiDisc::doPartitionShrink(int partition)
{
	ASSERT(0, "Not implemented yet!");
	return false;
/*
	uint64_t nClusterSource;
	uint64_t nSourceDataOffset;
	uint64_t nClusterDestination;
	uint64_t nDestinationDataOffset;

	uint64_t nSourceClusterGroup;
	uint64_t nDestClusterGroup;
	uint64_t nClusterGroups;

	uint32_t nDifference;

	uint64_t i;

	// allocate space for the fst.bin

	uint8_t * pFST = (uint8_t *)malloc((uint32_t)(image->parts[nPartition].header.fst_size));

	// allocate space for the data size (as we modify it
	uint8_t nDataSize[4];

	// read the fst.bin and data size files
	io_read_part(pFST, (uint32_t)(image->parts[nPartition].header.fst_size), image, nPartition, image->parts[nPartition].header.fst_offset);
	io_read(nDataSize, 0x0004, image, image->parts[nPartition].offset + 0x2bC);

	// find the first empty block from main.dol onwards
	nClusterDestination = findFirstData(image->parts[nPartition].offset + image->parts[nPartition].data_offset+image->parts[nPartition].header.dol_offset,
										image->parts[nPartition].data_size-image->parts[nPartition].header.dol_offset, false);

	// check for error condition
	if (0==nClusterDestination)
	{
		AfxMessageBox("Unable to find space to remove or main.dol incorrect");
		free(pFST);
		return false;
	}

	// change it to a higher cluster boundary
	nDestinationDataOffset = nClusterDestination - (image->parts[nPartition].offset + image->parts[nPartition].data_offset);
	nDestClusterGroup = (nDestinationDataOffset / (0x8000*NB_CLUSTER_GROUP))+1;
	nDestinationDataOffset = nDestClusterGroup * NB_CLUSTER_GROUP * 0x7c00;
	nClusterDestination = nDestClusterGroup * NB_CLUSTER_GROUP * 0x8000 + image->parts[nPartition].offset + image->parts[nPartition].data_offset;

	// now find the start of the data
	nClusterSource = findFirstData(nClusterDestination,
								   image->parts[nPartition].data_size - nDestClusterGroup* NB_CLUSTER_GROUP * 0x8000,
								   true);

	if (0==nClusterSource)
	{
		AfxMessageBox("Unable to find space to remove or main.dol incorrect");
		free(pFST);
		return false;

	}
	// change to a lower cluster boundary
	nSourceDataOffset = nClusterSource - (image->parts[nPartition].offset + image->parts[nPartition].data_offset);
	nSourceClusterGroup = ((nSourceDataOffset/ 0x8000)/NB_CLUSTER_GROUP);
	nSourceDataOffset = nSourceClusterGroup * NB_CLUSTER_GROUP * 0x7c00;
	nClusterSource = nSourceClusterGroup * NB_CLUSTER_GROUP * 0x8000 + image->parts[nPartition].offset + image->parts[nPartition].data_offset;

	// calculate number we need to copy
	nClusterGroups = (image->parts[nPartition].data_size / (0x8000 * NB_CLUSTER_GROUP)) - nSourceClusterGroup;


	// check to see if it's worth doing

	if (nSourceClusterGroup==nDestClusterGroup)
	{
		// same source/dest so pointless
		AfxMessageBox("Pointless doing it as source and dest are the same group");
		free(pFST);
		return false;
	}

	// read the h3 table
	io_read(h3, SIZE_H3, image, image->parts[nPartition].offset + image->parts[nPartition].h3_offset);

	// move the data down
	CopyDiscDataDirect(image, nPartition, nClusterSource, nClusterDestination, nClusterGroups*0x8000*NB_CLUSTER_GROUP);

	// update the h3 and save out as the write file use it
	for (i = 0; i < nClusterGroups; i++)
	{
		memcpy(&h3[(nDestClusterGroup+i)* 0x14], &h3[(nSourceClusterGroup +i)*0x14], 0x14);
	}
	DiscWriteDirect(image, image->parts[nPartition].offset + image->parts[nPartition].h3_offset, h3, SIZE_H3);

	// now update the fst table entries
	nDifference = (uint32_t)(((nSourceClusterGroup - nDestClusterGroup) * NB_CLUSTER_GROUP * 0x7c00) >> 2);

	uint32_t nFSTEntries  = be32(pFST + 8);
	uint32_t nTempOffset;

	for (i = 0; i < nFSTEntries; i++)
	{
		// if a file
		if (pFST[i*0x0C]==0x00)
		{
			// get current offset
			nTempOffset = be32(pFST + i*0x0c + 4);
			// take off difference
			nTempOffset = nTempOffset - nDifference;
			// save entry
			Write32(pFST + i*0x0c + 4,nTempOffset);
		}
	}
	// save the fst.bin
	wii_write_data_file(image, nPartition, image->parts[nPartition].header.fst_offset, image->parts[nPartition].header.fst_size, pFST);

	// update the data size in boot.bin
	uint32_t nSize = be32(nDataSize);

	nDifference = (uint32_t)(((nSourceClusterGroup - nDestClusterGroup) * NB_CLUSTER_GROUP * 0x8000) >> 2);

	Write32(nDataSize, nSize - nDifference);

	// save it

	DiscWriteDirect(image, image->parts[nPartition].offset + 0x2bc, nDataSize, 4);
	// sign it

	wii_trucha_signing(image, nPartition);

	free(pFST);
	// free the memory
	return true;
	*/
}

//////////////////////////////////////////////////////////////////////
// Search for the first block of data that is marked as either used //
// or unused                                                        //
//////////////////////////////////////////////////////////////////////
uint64_t WiiDisc::findFirstData(uint64_t nStartOffset, uint64_t nLength, BOOL bUsed)
{
	uint64_t nBlock = nStartOffset / 0x8000;
	uint64_t nEndBlock = (nStartOffset + nLength - 1) / 0x8000;

	while(nBlock < nEndBlock)
	{
		if (bUsed)
		{
			if (pFreeTable[nBlock] == 1)
			{
				return nBlock * 0x8000;
			}
		}
		else
		{
			if (pFreeTable[nBlock] == 0)
			{
				return nBlock * 0x8000;
			}
		}
		nBlock++;
	}
	return 0;

}


// Save all the files in a partition to the passed directory
bool WiiDisc::extractPartitionFiles(int partition, const std::string& destDirectory)
{
	ASSERT(partition >= 0 && partition < m_imageFile->partitionCount());
	const size_t fstSize = m_imageFile->parts[partition].header.fst_size;
	std::vector<unsigned char> fst(fstSize);

	if (io_read_part(&fst[0], fstSize, m_imageFile, partition, m_imageFile->parts[partition].header.fst_offset) != fstSize)
	{
		DLOG << "fst.bin read error";
		ASSERT(0);
		return false;
	}

	int fileCount = be32(&fst[8]);

	if(m_progressHandler)
	{
		m_progressHandler->setRange(0, fileCount);
		m_progressHandler->setPosition(0);
		m_progressHandler->setText("Saving partition of data");
	}

	int processedFiles = parse_fst_and_save(&fst[0], reinterpret_cast<const char*>(&fst[0]) + 12 * fileCount, 0, partition);

	
	if (processedFiles != fileCount)
	{
		DLOG << "Error writing files out";
		return false;
	}
	return true;
}

}

#endif