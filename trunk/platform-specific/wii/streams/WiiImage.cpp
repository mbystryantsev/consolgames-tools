#include "WiiImage.h"
#include <core.h>
#include <sha.h>
#include <sstream>
#include <MemoryStream.h>
#include "WiiFileStream.h"

LOG_CATEGORY("WiiImage")

#pragma pack(push, 1)

typedef u8 HashData[20];
typedef u8 ClusterData[SIZE_CLUSTER_DATA];

struct SHA1Hash
{
	HashData hash;
	u8& operator[](int index)
	{
		return hash[index];
	}
	const u8& operator[](int index) const
	{
		return hash[index];
	}
};

struct ClusterHeader
{
	HashData h0[31];
	u8 _padding0[20];
	HashData h1[8];
	u8 _padding1[32];
	HashData h2[8];
	u8 _padding2[32];
};

#pragma pack(pop)

namespace Consolgames
{

WiiImage::DummyProgressHandler WiiImage::s_dummyProgressHandler;

WiiImage::WiiImage()
	: m_progressHandler(NULL)
{

}

void WiiImage::setProgressHandler(IProgressHandler* handler)
{
	m_progressHandler = handler;
}

bool WiiImage::open(const std::wstring& filename, Stream::OpenMode mode)
{
	m_stream.reset(new FileStream(filename, mode));
	if (!m_stream->opened())
	{
		return false;
	}
	if (m_stream->seek(0, Stream::seekSet) != 0)
	{
		return false;
	}
	if (!readHeader())
	{
		return false;
	}
	return parseImage();
}

bool WiiImage::readHeader()
{
	char buffer[0x440];
	if (m_stream->read(buffer, 0x440) != 0x440)
	{
		return false;
	}

	m_header = PartitionHeader::parse(buffer);

	if (!m_header.isGamecube() && !m_header.isWii())
	{
		DLOG << "Unknown image type!";
		return false;
	}
	if (!m_header.hasMagic)
	{
		DLOG << "Image has an invalid magic.";
		return false;
	}

	m_isWii = m_header.isWii();

	if (m_header.isWii() && !checkAndLoadKey(true))
	{
		return false;
	}
	return true;
}

bool WiiImage::checkAndLoadKey(bool loadCrypto)
{
	static const u8 key[16] = {0xEB, 0xE4, 0x2A, 0x22, 0x5E, 0x85, 0x93, 0xE4, 0x48, 0xD9, 0xC5, 0x45, 0x73, 0x81, 0xAA, 0xF7};

	if (!loadCrypto)
	{
		// now check to see if it's the right key
		// as we don't want to embed the key value in here then lets cheat a little ;)
		// by checking the Xor'd difference values
		if	((0x0F!=(key[0]^key[1]))||
				(0xCE!=(key[1]^key[2]))||
				(0x08!=(key[2]^key[3]))||
				(0x7C!=(key[3]^key[4]))||
				(0xDB!=(key[4]^key[5]))||
				(0x16!=(key[5]^key[6]))||
				(0x77!=(key[6]^key[7]))||
				(0xAC!=(key[7]^key[8]))||
				(0x91!=(key[8]^key[9]))||
				(0x1C!=(key[9]^key[10]))||
				(0x80!=(key[10]^key[11]))||
				(0x36!=(key[11]^key[12]))||
				(0xF2!=(key[12]^key[13]))||
				(0x2B!=(key[13]^key[14]))||
				(0x5D!=(key[14]^key[15])))
		{
			// handle the Korean key, in case it ever gets found
			DLOG << "Doesn't seem to be the correct key";
			return false;
		}
	}
	else
	{
		AES_set_decrypt_key(key, 128, &m_key);
	}

	return true;
}

bool WiiImage::loadParitions()
{
	u8 buffer[16];
	u64 part_tbl_offset;
	u64 chan_tbl_offset;
	
	io_read(buffer, 16, 0x40000);
	m_partitionCount = be32(buffer);
	m_channelCount = be32(&buffer[8]);
	m_generalPartitionCount = m_partitionCount + m_channelCount;

	// number of partitions is out by one
	DLOG << "Number of partitions: " << m_partitionCount;
	DLOG << "Number of channels: " << m_channelCount;
	DLOG << "Total number of partitions: " << m_generalPartitionCount;

	part_tbl_offset = static_cast<u64>(be32(&buffer[4])) * 4;
	chan_tbl_offset = static_cast<u64>(be32(&buffer[12])) * 4;

	DLOG << "Partition table offset: " << part_tbl_offset;
	DLOG << "Channel table offset: " << chan_tbl_offset;

	m_partitions.resize(m_generalPartitionCount);

	for (int i = 0; i < m_partitionCount + m_channelCount; i++)
	{
		if (i < m_partitionCount)
		{
			m_partitions[i].m_index = i;

			io_read(buffer, 8, part_tbl_offset + i * 8);

			switch (be32(&buffer[4]))
			{
			case 0:
				m_partitions[i].type = PART_DATA;
				break;

			case 1:
				m_partitions[i].type = PART_UPDATE;
				break;

			case 2:
				m_partitions[i].type = PART_INSTALLER;
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
			io_read(buffer, 8, chan_tbl_offset + (i - m_partitionCount) * 8);

			m_partitions[i].type = PART_VC;
			m_partitions[i].chan_id[0] = buffer[4];
			m_partitions[i].chan_id[1] = buffer[5];
			m_partitions[i].chan_id[2] = buffer[6];
			m_partitions[i].chan_id[3] = buffer[7];
		}

		m_partitions[i].offset = static_cast<offset_t>(be32(buffer)) * 4;

		DLOG << "Partition " << i << " offset: " << HEX << m_partitions[i].offset;

		// mark the block as used
		markAsUsed(m_partitions[i].offset, 0x8000);

		io_read (buffer, 8, m_partitions[i].offset + 0x2b8);
		m_partitions[i].dataOffset = (u64)(be32 (buffer)) << 2;
		m_partitions[i].dataSize = (u64)(be32 (&buffer[4])) << 2;

		// now get the H3 offset
		io_read (buffer, 4, m_partitions[i].offset + 0x2b4);
		m_partitions[i].h3_offset = (u64)(be32 (buffer)) << 2 ;

		DLOG << "Partition " << i << " data offset: " << HEX << m_partitions[i].dataOffset;
		DLOG << "partition " << i << " data size: " << HEX << m_partitions[i].dataSize;
		DLOG << "H3 offset: " << HEX << m_partitions[i].h3_offset;

		loadTmd(i);

		if (m_partitions[i].tmd.isNull())
		{
			DLOG << "Partition has no valid tmd";
			continue;
		}

		//sprintf (image->parts[i].title_id_str, "%016llx",
		sprintf(m_partitions[i].title_id_str, "%016I64x", m_partitions[i].tmd->title_id);

		m_partitions[i].isEncrypted = true;
		m_partitions[i].cached_block = 0xffffffff;


		u8 title_key[16];
		memset(title_key, 0, 16);
		io_read(title_key, 16, m_partitions[i].offset + 0x1bf);

		u8 iv[16];
		memset(iv, 0, 16);
		io_read(iv, 8, m_partitions[i].offset + 0x1dc);


		u8 partition_key[16];
		AES_cbc_encrypt (title_key, partition_key, 16, &m_key, iv, AES_DECRYPT);
		memcpy(m_partitions[i].title_key, partition_key, 16);
		AES_set_decrypt_key(partition_key, 128, &m_partitions[i].key);
	}

	return (m_generalPartitionCount > 0);
}

largesize_t WiiImage::io_read(void* ptr, largesize_t size, offset_t offset)
{
	largesize_t bytesReaded;
	
	VERIFY(m_stream->seek(offset, Stream::seekSet) == offset);

	bytesReaded = m_stream->read(ptr, size);
	ASSERT(bytesReaded == size);

	markAsUsed(offset, size);

	return bytesReaded;
}

void WiiImage::loadTmd(int partition)
{
	TmdSigType sigType = SIG_UNKNOWN;

	offset_t offset = m_partitions[partition].offset;
	u8 buffer[64];

	io_read(buffer, 16, offset + 0x2A4);

	u32 tmdSize  = be32(buffer);
	offset_t tmdOffset   = be32(&buffer[4]) * 4;
	u32 certSize = be32(&buffer[8]);
	offset_t certOffset  = be32(&buffer[12]) * 4;

	// TODO: ninty way?

	//	 if (cert_size)
	//			 image->parts[part].tmd_size =
	//					 cert_off - image->parts[part].tmd_offset + cert_size;


	offset += tmdOffset;

	io_read(buffer, 4, offset);
	offset += 4;

	int sigSize = 0;

	switch (be32(buffer))
	{
	case 0x00010001:
		sigType = SIG_RSA_2048;
		sigSize = 0x100;
		break;

	case 0x00010000:
		sigType = SIG_RSA_4096;
		sigSize = 0x200;
		break;
	}

	ASSERT(sigType != SIG_UNKNOWN);

	Tmd tmd;
	memset(&tmd, 0, sizeof(tmd));
	tmd.sigType = sigType;

	m_partitions[partition].tmdOffset = tmdOffset;
	m_partitions[partition].tmdSize = tmdSize;
	m_partitions[partition].certOffset = certOffset;
	m_partitions[partition].certSize = certSize;

	tmd.signature.resize(sigSize);
	io_read(&tmd.signature[0], sigSize, offset);
	offset += sigSize;
	offset = ROUNDUP64B(offset);

	io_read(&tmd.issuer[0], 0x40, offset);
	offset += 0x40;

	io_read(buffer, 26, offset);
	offset += 26;

	tmd.version = buffer[0];
	tmd.ca_crl_version = buffer[1];
	tmd.signer_crl_version = buffer[2];

	tmd.sys_version = be64(&buffer[4]);
	tmd.title_id = be64(&buffer[12]);
	tmd.title_type = be32(&buffer[20]);
	tmd.group_id = be16(&buffer[24]);

	offset += 62;

	io_read(buffer, 10, offset);
	offset += 10;

	tmd.accessRights = be32(buffer);
	tmd.titleVersion = be16(&buffer[4]);
	tmd.numContents = be16(&buffer[6]);
	tmd.bootIndex = be16(&buffer[8]);

	offset += 2;

	if (tmd.numContents < 1)
		return;

	tmd.contents.resize(tmd.numContents);
	for (int i = 0; i < tmd.numContents; i++)
	{
		io_read(buffer, 0x30, offset);
		offset += 0x30;

		tmd.contents[i].cid = be32(buffer);
		tmd.contents[i].index = be16(&buffer[4]);
		tmd.contents[i].type = static_cast<WiiPartitionType>(be16(&buffer[6]));
		tmd.contents[i].size = be64(&buffer[8]);
		memcpy(tmd.contents[i].hash, &buffer[16], 20);
	}

	m_partitions[partition].tmd = tmd;
	return;
}


u32 WiiImage::parse_fst_and_save(u8 *fst, const char* names, int i, int part)
{
	const char* name = names + (be32 (fst + 12 * i) & 0x00ffffff);
	u32 size = be32(fst + 12 * i + 8);

	if (i == 0)
	{
		u32 j = 0;
		// directory so need to go through the directory entries
		for (j = 1; j < size; )
		{
			j = parse_fst_and_save(fst, names, j, part);
		}

		return (j != -1) ? size : -1;
	}

	if (fst[12 * i])
	{
		//_mkdir(name);
		//_chdir(name);
		u32 j = 0;
		for (j = i + 1; j < size; )
		{
			j = parse_fst_and_save(fst, names, j, part);
		}

		// now remove the directory name we just added
		//m_csText = m_csText.Left(m_csText.GetLength()-strlen(name) - 1);
		//m_csText = m_csText.substr(0, m_csText.length()-strlen(name) - 1);
		//_chdir("..");
		return (j != -1) ? size : -1;
	}
	else
	{
		u32 offset = be32(fst + 12 * i + 4);
		if (m_partitions[part].header.isWii())
		{
			offset *= 4;
		}

		std::wstring str(name, name + strlen(name));
		saveDecryptedFile(str, part, offset, size);
		return i + 1;
	}
	return -1;
}

void WiiImage::saveDecryptedFile(const std::wstring& destFilename, int partition, offset_t offset, largesize_t size, bool overrideEncrypt)
{
	u32 block = static_cast<u32>(offset / 0x7C00);
	u32 cacheOffset = static_cast<u32>(offset % 0x7C00);
	u64 cacheSize = 0;

	unsigned char cBuffer[0x8000];

	FileStream outStream(destFilename, Stream::modeWrite);

	if (!m_partitions[partition].isEncrypted || overrideEncrypt)
	{
		VERIFY(m_stream->seek(offset, Stream::seekSet) == offset);
		while(size)
		{
			cacheSize = size;
			if (cacheSize  > 0x8000)
			{
				cacheSize = 0x8000;
			}
			VERIFY(m_stream->read(&cBuffer[0], cacheSize) == cacheSize);
			outStream.write(cBuffer, cacheSize);
			size -= cacheSize;
		}
	}
	else
	{
		while (size > 0)
		{
			decryptBlock(partition, block);

			cacheSize = size;
			if (cacheSize + cacheOffset > 0x7c00)
			{
				cacheSize = 0x7c00 - cacheOffset;
			}

			VERIFY(outStream.write(m_partitions[partition].cache + cacheOffset, cacheSize) == cacheSize);

			size -= cacheSize;
			cacheOffset = 0;
			block++;
		}
	}
}

void WiiImage::decryptBlock(int partition, int block)
{
	ASSERT(partition >= 0 && partition < static_cast<int>(m_partitions.size()));

	const largesize_t blockSize = 0x8000;

	if (block == m_partitions[partition].cached_block)
	{
		return;
	}

	const offset_t offsetInPartition =  blockSize * block;
	ASSERT(offsetInPartition < m_partitions[partition].dataSize);

	const offset_t offset = m_partitions[partition].offset + m_partitions[partition].dataOffset + offsetInPartition;

	VERIFY(io_read(m_partitions[partition].dec_buffer, blockSize, offset) == blockSize);

	AES_cbc_encrypt (&m_partitions[partition].dec_buffer[0x400], m_partitions[partition].cache, 0x7c00,
		&m_partitions[partition].key, &m_partitions[partition].dec_buffer[0x3d0], AES_DECRYPT);

	m_partitions[partition].cached_block = block;
}

largesize_t WiiImage::io_read_part(void* ptr, largesize_t size, int partition, offset_t offset)
{
	if (!m_partitions[partition].isEncrypted)
	{
		return io_read(ptr, size, m_partitions[partition].offset + offset);
	}

	u32 block = static_cast<u32>(offset / 0x7C00ULL);
	u32 cache_offset = static_cast<u32>(offset % 0x7C00ULL);
	u32 cache_size = 0;
	unsigned char* dst = static_cast<unsigned char*>(ptr);

	while (size)
	{
		decryptBlock(partition, block);

		cache_size = static_cast<u32>(size);
		if (cache_size + cache_offset > 0x7c00)
		{
			cache_size = 0x7c00 - cache_offset;
		}

		memcpy(dst, m_partitions[partition].cache + cache_offset, cache_size);
		dst += cache_size;
		size -= cache_size;
		cache_offset = 0;

		block++;
	}

	return static_cast<u32>(dst - reinterpret_cast<unsigned char*>(ptr));
}

bool WiiImage::loadDecryptedFile(const std::wstring& filename, u32 partition, offset_t offset, largesize_t size, int fstReference)
{
	u8 bootBin[0x440];

	FileStream inStream(filename.data(), Stream::modeRead);
	ASSERT(inStream.opened());

	if (!inStream.opened())
	{
		return false;
	}

	const largesize_t inFileSize = inStream.size();
	largesize_t imageSize = inFileSize;


	// now get the filesize we are trying to load and make sure it is smaller
	// or the same size as the one we are trying to replace if so then a simple replace
	if (size >= imageSize)
	{
		// now need to change the boot.bin if one if fst.bin or main.dol were changed
		if (size != inFileSize)
		{
			// we have a different sized file being put in
			// this is obviously smaller but will require a tweak to one of the file
			// entries
			if (fstReference > 0)
			{
				// normal file so change the FST.BIN
				std::vector<u8> fstData(m_partitions[partition].header.fstSize);
				//u8 * pFSTBin = (unsigned char *) calloc(m_partitions[partition].header.fstSize, 1);

				io_read_part(&fstData[0], m_partitions[partition].header.fstSize, partition, m_partitions[partition].header.fstOffset);

				// alter the entry for the passed FST Reference
				fstReference = fstReference * 0x0c;

				// update the length for the file
				store32(&fstData[0] + fstReference + 0x08L , static_cast<u32>(imageSize));

				// write out the FST.BIN
				wii_write_data_file(partition, m_partitions[partition].header.fstOffset, &fstData[0], m_partitions[partition].header.fstSize);

				// write it out
				wii_write_data_file(partition, offset, &inStream, imageSize);

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
					io_read_part(&bootBin[0], 0x440, partition, 0);

					// update the settings for the FST.BIN entry
					// this has to be rounded to the nearest 4 so.....
					if (imageSize % 4 != 0)
					{
						imageSize += 4 - (imageSize % 4);
					}
					store32(&bootBin[0x428], static_cast<u32>(imageSize >> 2));
					store32(&bootBin[0x42C], static_cast<u32>(imageSize >> 2));
					// now write it out
					wii_write_data_file(partition, 0, &bootBin[0], 0x440);

					break;
				case -2:
				case -3:
					// main.dol, apploader - don't have to do anything
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
					return false;
				}
				// now write it out
				wii_write_data_file(partition, offset, &inStream, imageSize);
			}
		}
		else
		{
			// Equal sized file so need to check for the special cases
			if (fstReference < 0)
			{
				switch(fstReference)
				{
				case refFst:
				case refMain:
				case refApploader:
					// simple write as files are the same size
					wii_write_data_file(partition, offset, &inStream, imageSize);
					break;
				case refPartition:
					// Partition.bin
					// it's a direct write
					writeDirect(m_partitions[partition].offset, &inStream, size);
					break;
				case refTmd:
				case refCert:
				case refH3:
					// same for all 3
					writeDirect(m_partitions[partition].offset + offset, &inStream, size);
					break;
				default:
					DLOG << "Unknown file reference passed";
					break;
				}
			}
			else
			{
				// simple write as files are the same size
				wii_write_data_file(partition, offset, &inStream, imageSize);
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
		offset_t freeSpaceStart = findRequiredFreeSpaceInPartition(partition, imageSize);

		if (freeSpaceStart == 0)
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
			std::vector<u8> fstData(m_partitions[partition].header.fstSize);

			io_read_part(&fstData[0], m_partitions[partition].header.fstSize, partition, m_partitions[partition].header.fstOffset);

			// alter the entry for the passed FST Reference
			fstReference = fstReference * 0x0c;

			// update the offset for this file
			store32(&fstData[0] + fstReference + 0x04L, static_cast<u32>(freeSpaceStart >> 2));
			// update the length for the file
			store32(&fstData[0] + fstReference + 0x08L , static_cast<u32>(imageSize));

			// write out the FST.BIN
			wii_write_data_file(partition, m_partitions[partition].header.fstOffset, &fstData[0], m_partitions[partition].header.fstSize);

			// now write data file out
			wii_write_data_file(partition, freeSpaceStart, &inStream, imageSize);

		}
		else
		{

			switch(fstReference)
			{
			case -1: // FST.BIN
				// change the boot.bin file too and write that out
				io_read_part(&bootBin[0], 0x440, partition, 0);

				// update the settings for the FST.BIN entry
				// this has to be rounded to the nearest 4 so.....
				if (0!=(imageSize%4))
				{
					imageSize = imageSize + (4 - imageSize%4);
				}

				// update the settings for the FST.BIN entry
				store32(bootBin + 0x424L, u32 (freeSpaceStart >> 2));
				store32(bootBin + 0x428L, (u32)(imageSize >> 2));
				store32(bootBin + 0x42CL, (u32)(imageSize >> 2));

				// now write it out
				wii_write_data_file(partition, 0, bootBin, 0x440);

				// now write it out
				wii_write_data_file( partition, freeSpaceStart, &inStream, imageSize);


				break;
			case -2: // Main.DOL
				// change the boot.bin file too and write that out
				io_read_part(bootBin, 0x440, partition, 0);

				// update the settings for the main.dol entry
				store32(bootBin + 0x420L, u32 (freeSpaceStart >> 2));

				// now write it out
				wii_write_data_file(partition, 0, bootBin, 0x440);

				// now write main.dol out
				wii_write_data_file(partition, freeSpaceStart, &inStream, imageSize);


				break;
			case -3: 
			{
				// Apploader.img - now this is fun! as we have to
				// move the main.dol and potentially fst.bin too  too otherwise they would be overwritten
				// also what happens if the data for those two has already been moved
				// aaaargh

				// check to see what we have to move
				// by calculating the amount of extra data we are trying to stuff in
				const u32 nExtraData = static_cast<u32>(imageSize - m_partitions[partition].appldrSize);
				const u32 nExtraDataBlocks = 1 + static_cast<u32>((imageSize - m_partitions[partition].appldrSize) / 0x7c00);

				// check to see if we have that much free at the end of the area
				// or do we need to try and overwrite
				if (checkForFreeSpace(partition, m_partitions[partition].appldrSize + 0x2440, nExtraDataBlocks))
				{
					// we have enough space after the current apploader - already moved the main.dol?
					// so just need to write it out.
					wii_write_data_file(partition, 0x2440, &inStream, imageSize);

				}
				else
				{
					// check if we can get by with moving the main.dol
					if (nExtraData > m_partitions[partition].header.dolSize)
					{
						// don't really want to be playing around here as we potentially can get
						// overwrites of all sorts of data
						DLOG << "Cannot guarantee a good write of apploader";
						return false;
					}
					
					// "just" need to move main.dol
					std::vector<u8> mainDolData(m_partitions[partition].header.dolSize);

					io_read_part(&mainDolData[0], m_partitions[partition].header.dolSize, partition, m_partitions[partition].header.dolOffset);

					// try and get some free space for it
					freeSpaceStart = findRequiredFreeSpaceInPartition(partition, m_partitions[partition].header.dolSize);

					// now unmark the original dol area
					markAsUnused(m_partitions[partition].offset + m_partitions[partition].dataOffset+(((m_partitions[partition].header.dolOffset) / 0x7c00) * 0x8000),
						m_partitions[partition].header.dolSize);

					if (freeSpaceStart > 0 && checkForFreeSpace(partition, m_partitions[partition].appldrSize + 0x2440 ,nExtraDataBlocks))
					{
						// got space so write it out
						wii_write_data_file(partition, freeSpaceStart, &mainDolData[0], m_partitions[partition].header.dolSize);

						// now do the boot.bin file too
						io_read_part(bootBin, 0x440, partition, 0);

						// update the settings for the boot.BIN entry
						store32(bootBin + 0x420L, static_cast<u32>(freeSpaceStart >> 2));

						// now write it out
						wii_write_data_file(partition, 0, bootBin, 0x440);

						// now write out the apploader - we don't need to change any other data
						// as the size is inside the apploader
						wii_write_data_file(partition, 0x2440, &inStream, imageSize);

					}
					else
					{
						DLOG << "Unable to move the main.dol and find enough space for the apploader.";
						return false;
					}

				}
				break;
			}
			default:
				// Unable to do these as they are set sizes and lengths boot.bin and bi2.bin
				// partition.bin
				DLOG << "Unable to change that file as it is a set size in the disc image";
				return false;
			}

		}
	}

	return true;
}

bool WiiImage::wii_trucha_signing(int partition)
{
	u8 hash[20];

	const u32 size = m_partitions[partition].tmdSize;
	std::vector<u8> buffer(size);

	readDirect(m_partitions[partition].offset + m_partitions[partition].tmdOffset, &buffer[0], size);

	/* Overwrite signature with trucha signature */
	memcpy(&buffer[0x04], s_truchaSignature, 256);

	/* SHA-1 brute force */
	hash[0] = 1;

	for (u32 val = 0; val <= ULONG_MAX && hash[0] != 0x00; val++)
	{
		/* Modify TMD "reserved" field */
		memcpy(&buffer[0x19A], &val, sizeof(val));

		/* Calculate SHA-1 hash */
		SHA1(&buffer[0x140], size - 0x140, hash);

		// check for the bug where the first byte of the hash is 0
		if (hash[0] == 0)
		{
			/* Write modified TMD data */
			writeDirect(m_partitions[partition].offset + m_partitions[partition].tmdOffset, &buffer[0], size);
			return true;
		}
	}
	return false;
}

void WiiImage::readDirect(offset_t offset, void* data, largesize_t size)
{
	VERIFY(m_stream->seek(offset, Stream::seekSet) == offset);
	VERIFY(m_stream->read(data, size) == size);
}

bool WiiImage::writeDirect(offset_t offset, const void* data, largesize_t size)
{
	if (m_stream->seek(offset, Stream::seekSet) != offset)
	{
		return false;
	}
	if (m_stream->write(data, size) != size)
	{
		return false;
	}
	return true;
}

void WiiImage::store32(void* data, u32 value)
{
	u8* p = reinterpret_cast<u8*>(data);
	p[0] = (value >> 24) & 0xFF;
	p[1] = (value >> 16) & 0xFF;
	p[2] = (value >>  8) & 0xFF;
	p[3] = (value	  ) & 0xFF;
}


const u8 WiiImage::s_truchaSignature[256] =
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

const PartitionHeader& WiiImage::firstPartitionHeader()
{
	return m_header;
}

bool WiiImage::setPartition(int partition)
{
	ASSERT(partition >= 0 && partition < m_partitionCount);
	if (partition < 0 || partition >= m_partitionCount)
	{
		return false;
	}
	m_currentPartition= partition;
	//m_position = 0;
	return true;
}

int WiiImage::currentPartition() const
{
	return m_currentPartition;
}

int WiiImage::dataPartition() const
{
	return findDataPartitionIndex();
}

bool WiiImage::setDataPartition()
{
	return setPartition(findDataPartitionIndex());
}

int WiiImage::findDataPartitionIndex() const
{
	for (size_t i = 0; i < m_partitions.size(); i++)
	{
		if (m_partitions[i].type == PART_DATA)
		{
			return i;
		}
	}
	return -1;
}


bool WiiImage::parseImage()
{
	u8 buffer[0x440];

	if (m_header.isWii())
	{
		DLOG << "Wii image detected";
		loadParitions();
	}
	else
	{
		DLOG << "Gamecube image detected";

		m_partitions.resize(1);
		m_partitionCount = 1;
		m_channelCount = 0;
		//m_imageFile->part_tbl_offset = 0;
		//m_imageFile->chan_tbl_offset = 0;
		//m_imageFile->parts[0].type = PART_DATA;
	}

	u8 nvp = 0;
	for (int i = 0; i < m_partitionCount; i++)
	{
		if (!io_read_part (buffer, 0x440, i, 0))
		{
			DLOG << "Unable to read partition " << i << " header!";
			return false;
		}
		bool valid = true;
		for (int j = 0; j < 6; ++j)
		{
			if (!isprint(buffer[j]))
			{
				valid = false;
				break;
			}
		}

		if (!valid)
		{
			DLOG << "invalid header for partition: " << i;
			continue;
		}
		nvp++;

		WiiPartition& partition = m_partitions[i];
		partition.header = PartitionHeader::parse(buffer);

		if (partition.type != PART_UNKNOWN)
		{
			DLOG << i << ":/partition.bin " << HEX << partition.offset << " " << partition.dataOffset;
			markAsUsed(partition.offset, partition.dataOffset);
			partition.addFilesystemObject("partition.bin", partition.offset, partition.dataOffset, refPartition, dataPartitionBin);
			
			DLOG << i << ":/boot.bin " << HEX << (partition.offset + partition.dataOffset) << " " << 0x440;
			markAsUsedDC(partition.offset + partition.dataOffset, 0, 0x440, partition.isEncrypted);
			partition.addFilesystemObject("boot.bin", 0, 0x440, 0, dataFile);

			DLOG << i << ":/bi2.bin " << HEX << (partition.offset + partition.dataOffset + 0x440) << " " << 0x2000;
			markAsUsedDC(partition.offset + partition.dataOffset, 0x440, 0x2000, partition.isEncrypted);
			partition.addFilesystemObject("bi2.bin", 0x440, 0x2000, 0, dataFile);
		}
		
		io_read_part(buffer, 8, i, 0x2440 + 0x14);
		partition.appldrSize = be32(buffer) + be32(&buffer[4]);
		if (partition.appldrSize > 0)
		{
			partition.appldrSize += 32;
		}

		if (partition.appldrSize > 0)
		{
			DLOG << i << ":/apploader.img " << HEX << (partition.offset + partition.dataOffset + 0x2440) << " " << partition.appldrSize;
			markAsUsedDC(partition.offset + partition.dataOffset, 0x2440, partition.appldrSize, partition.isEncrypted);
			partition.addFilesystemObject("apploader.img", 0x2440, partition.appldrSize, refApploader, dataFile);
		}
		else
		{
			DLOG << "apploader.img not present";
		}

		if (partition.header.dolOffset > 0)
		{
			io_read_part(buffer, 0x100, i, partition.header.dolOffset);
			partition.header.dolSize = calcDolSize(buffer);

			// now check for error condition with bad main.dol
			if (partition.header.dolSize >=partition.dataSize)
			{
				// almost certainly an error as it's bigger than the partition
				partition.header.dolSize = 0;
			}
			markAsUsedDC(	partition.offset+ partition.dataOffset,
				partition.header.dolOffset,
				partition.header.dolSize,
				partition.isEncrypted
				);

			DLOG << i << ":/main.dol " << HEX << (partition.offset + partition.dataOffset + partition.header.dolOffset) << " " << partition.header.dolSize;
			partition.addFilesystemObject("main.dol", partition.header.dolOffset, partition.header.dolSize, refMain, dataFile);
		}
		else
		{
			DLOG << "partition has no main.dol";
		}

		if (partition.isEncrypted)
		{
			// Now add the TMD.BIN and cert.bin files - as these are part of partition.bin
			// we don't need to mark them as used - we do put them under partition.bin in the
			// tree though

			DLOG << i << ":/tmd.bin " << HEX << (partition.offset + partition.tmdOffset) << " " << partition.tmdSize;
			partition.addFilesystemObject("tmd.bin", partition.tmdOffset, partition.tmdSize, refTmd, dataFile);

			DLOG << i << ":/cert.bin " << HEX << (partition.offset + partition.certOffset) << " " << partition.certSize;
			partition.addFilesystemObject("cert.bin", partition.certOffset, partition.certSize, refCert, dataFile);

			// add on the H3
			DLOG << i << ":/h3.bin " << HEX << (partition.offset + partition.h3_offset) << " " << 0x18000;
			markAsUsedDC(	partition.offset, partition.h3_offset, 0x18000, false);
			partition.addFilesystemObject("h3.bin", partition.h3_offset, 0x18000, refH3, dataFile);
		}

		if (partition.header.fstOffset > 0 && partition.header.fstSize > 0)
		{
			DLOG << i << ":/fst.bin " << HEX << (partition.offset + partition.dataOffset + partition.header.fstOffset) << " " << partition.header.fstSize;

			markAsUsedDC( partition.offset+ partition.dataOffset,
				partition.header.fstOffset,
				partition.header.fstSize,
				partition.isEncrypted);
			partition.addFilesystemObject("fst.bin", partition.header.fstOffset, partition.header.fstSize, refFst, dataFile);

			std::vector<u8> fstData(partition.header.fstSize);
			if (io_read_part(&fstData[0], partition.header.fstSize, i, partition.header.fstOffset) != partition.header.fstSize)
			{
				DLOG << "fst.bin";
				return false;
			}

			partition.fileCount = be32(&fstData[8]);

			if (static_cast<u32>(partition.fileCount * 12) > partition.header.fstSize)
			{
				DLOG << "invalid fst for partition " << i;
			}
			else
			{
				partition.parseFst(&fstData[0], 0, NULL);
			}
		}
		else
		{
			DLOG << "Partition has no fst!";
		}
	}

	if (!nvp)
	{
		DLOG << "no valid partition were found, exiting";
		return false;
	}

	// find out the partition with data in

	int partition = findDataPartitionIndex();
	if (partition < 0)
	{
		DLOG << "Unable to found data partition!";
		return false;
	}
	m_currentPartition = partition;

	// now clear out the junk data in the name
	for (int i = 0; i< 0x60; i++)
	{
		if (isprint(m_partitions[partition].header.name[i]))
		{
			m_partitions[partition].header.name[i] = ' ';
		}
	}

	switch (m_partitions[partition].header.region)
	{
		case 'P':
			DLOG << "Region Code: PAL";
			break;
		case 'E':
			DLOG << "Region Code: NTSC";
			break;
		case 'J':
			DLOG << "Region Code: JAP";
			break;
		default:
			// unknown or not quite right
			DLOG << "Region Code: " << m_partitions[partition].header.region << "?";
			break;
	}
	return true;
}

u32 WiiImage::calcDolSize(const u8* header)
{
	u8 i;
	u32 offset, size;
	u32 max = 0;

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

bool WiiImage::checkForFreeSpace(int partition, offset_t offset, int blockCount) const
{
	partition;
	offset;
	blockCount;
	return true;
#if 0
	// convert offset to block representation
	u32 nBlockOffsetStart = 0;

	nBlockOffsetStart = (u32)((m_imageFile->parts[nPartition].data_offset + m_imageFile->parts[nPartition].offset) / (u64)0x8000);
	nBlockOffsetStart = nBlockOffsetStart + (u32)(nOffset / (u64) 0x7c00);
	if (0!=nOffset%0x7c00)
	{
		// starts part way into a block so need to check the number of blocks plus one
		nBlocks++;
		// and the start is up by one as we know that there must be data in the current
		// block
		nBlockOffsetStart++;
	}

	for (u32 x = 0; x < nBlocks; x++)
	{
		if (1==pFreeTable[nBlockOffsetStart+x])
		{
			return false;
		}
	}
	return true;
#endif
}

void WiiImage::close()
{
	m_stream.reset();
}

Tree<FileInfo>::Node* WiiImage::searchFile(const std::string& name, Tree<FileInfo>::Node* folder)
{
	if (folder == NULL)
	{
		folder = &m_partitions[m_currentPartition].m_filesystem.root();
	}

	Tree<FileInfo>::Node* result = NULL;
	Tree<FileInfo>::Node* node = folder->firstChild();
	
	while (node != NULL)
	{
		if (node->data().dataType == dataFile)
		{
			if (node->data().name == name)
			{
				return node;
			}
		}
		else
		{
			if ((result = findFile(name, node)))
			{
				return result;
			}
		}
		node = node->next();
	}
	return result;
}

Tree<FileInfo>::Node* WiiImage::findFile(const std::string& path, Tree<FileInfo>::Node* folder)
{
	if (folder == NULL)
	{
		folder = &m_partitions[m_currentPartition].m_filesystem.root();
	}

	std::istringstream f(path);
	std::string name;	
	while (std::getline(f, name, '/'))
	{
		Tree<FileInfo>::Node* node = folder->firstChild();
		while (node != NULL)
		{
			if (node->data().name == name)
			{
				break;
			}
			node = node->next();
		}
		if (node == NULL)
		{
			return NULL;
		}
		if (f.eof())
		{
			return node;
		}
		folder = node;
	}

	return NULL;
}

Consolgames::WiiFileStream* WiiImage::openFile(const std::string& path, Stream::OpenMode mode)
{
	if (m_stream->openMode() != Stream::modeReadWrite && m_stream->openMode() != mode)
	{
		return NULL;
	}

	Tree<FileInfo>::Node* info = findFile(path);
	if (info == NULL)
	{
		return NULL;
	}

	return new WiiFileStream(*this, info->data().partition, info->data().offset, info->data().size);
}

//////////////////////////////////////////////////////////////////////////
// CLUSTERS
//////////////////////////////////////////////////////////////////////////

bool WiiImage::wii_read_cluster(int partition, int cluster, u8 *data, u8 *header)
{
	u8 buf[SIZE_CLUSTER];
	u8  iv[16];

	/* Jump to the specified cluster and copy it to memory */
	offset_t offset = m_partitions[partition].offset + m_partitions[partition].dataOffset + static_cast<offset_t>(cluster) * SIZE_CLUSTER;

	// read the correct location block in
	io_read(buf, SIZE_CLUSTER, offset);

	/* Set title key */
	const u8* title_key =  &m_partitions[partition].title_key[0];

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

	return true;
}

bool WiiImage::wii_read_cluster_hashes(int partition, int cluster, u8 *h0, u8 *h1, u8 *h2)
{
	u8 buf[SIZE_CLUSTER_HEADER];

	/* Read cluster header */
	if (!wii_read_cluster(partition, cluster, NULL, buf))
	{
		return false;
	}

	if (NULL!=h0)
		memcpy(h0, buf + OFFSET_H0, SIZE_H0);
	if (NULL!=h1)
		memcpy(h1, buf + OFFSET_H1, SIZE_H1);
	if (NULL!=h2)
		memcpy(h2, buf + OFFSET_H2, SIZE_H2);

	return true;
}

// calculate the group hash for a cluster
bool WiiImage::wii_calc_group_hash(int partition, int cluster)
{
	u8 h2[SIZE_H2];
	u8 h3[SIZE_H3];
	u8 h4[SIZE_H4];

	/* Calculate cluster group */
	u32 group = cluster / NB_CLUSTER_GROUP;

	/* Get H2 hash of the group */
	if (!wii_read_cluster_hashes(partition, cluster, NULL, NULL, h2))
	{
		return false;
	}

	/* read the H3 table offset */
	io_read(h3, SIZE_H3, m_partitions[partition].offset + m_partitions[partition].h3_offset);


	/* Calculate SHA-1 hash */
	sha1(h2, SIZE_H2, &h3[group * 0x14]);

	/* Write new H3 table */
	if (!writeDirect(m_partitions[partition].h3_offset + m_partitions[partition].offset, h3, SIZE_H3))
	{
		return false;
	}


	/* Calculate H4 */
	sha1(h3, SIZE_H3, h4);

	/* Write H4 */
	if (!writeDirect(m_partitions[partition].tmdOffset + OFFSET_TMD_HASH + m_partitions[partition].offset, h4, SIZE_H4))
	{
		return false;
	}

	return true;
}

bool WiiImage::wii_write_clusters(int partition, int cluster, int offsetInCluster, int bytesToWrite, Stream* inStream)
{
	// TODO: Refactor
	HashData h1;
	HashData h2[8];

	const int clusterGroup = cluster / NB_CLUSTER_GROUP;
	const int firstClusterInGroup = clusterGroup * NB_CLUSTER_GROUP;

	/* Get number of clusters in this group */
	int clustersInGroup = wii_nb_cluster(partition) - firstClusterInGroup;
	if (clustersInGroup > NB_CLUSTER_GROUP)
	{
		clustersInGroup = NB_CLUSTER_GROUP;
	}

	std::vector<u8> data(SIZE_CLUSTER_DATA * NB_CLUSTER_GROUP);
	std::vector<ClusterHeader> headers(NB_CLUSTER_GROUP);
	
	// if we are replacing a full set of clusters then we don't
	// need to do any reading as we just need to overwrite the
	// blanked data


	const int clusterCount = ((bytesToWrite + offsetInCluster - 1) / SIZE_CLUSTER_DATA) + 1;

	if (bytesToWrite != (NB_CLUSTER_GROUP * SIZE_CLUSTER_DATA))
	{
		/* Read group clusters and headers */
		for (int i = 0; i < clustersInGroup; i++)
		{
			u8 *d_ptr = &data[SIZE_CLUSTER_DATA * i];
			if (!wii_read_cluster(partition, firstClusterInGroup + i, d_ptr, reinterpret_cast<u8*>(&headers[i])))
			{
				return false;
			}
		}
	}

	// now overwrite the data in the correct location
	// be it from file data or from the memory location
	/* Write new cluster and H0 table */
	const int firstClusterIndexInGroup = cluster - firstClusterInGroup;
	const int firstClusterDataOffset = firstClusterIndexInGroup * SIZE_CLUSTER_DATA;

	inStream->read(&data[firstClusterDataOffset + offsetInCluster], bytesToWrite);

	for (int clusterIndex = 0; clusterIndex < clusterCount; clusterIndex++)
	{
		int clusterIndexInGroup = firstClusterIndexInGroup + clusterIndex;

		/* Calculate new clusters H0 table */
		for (int i = 0; i < 31; i++)
		{
			sha1(&data[firstClusterDataOffset + clusterIndex * SIZE_CLUSTER_DATA + i * 0x400], 0x400, &headers[clusterIndexInGroup].h0[i][0]);
		}
		sha1(&headers[clusterIndexInGroup].h0[0][0], SIZE_H0, h1);

		// now copy to all the sub cluster locations
		const u32 subgroupIndex = clusterIndexInGroup / NB_CLUSTER_SUBGROUP;
		const int clusterIndexInSubgroup = clusterIndexInGroup % NB_CLUSTER_SUBGROUP;
		for (int cluster = 0; cluster < NB_CLUSTER_SUBGROUP; cluster++)
		{
			// need to get the position of the first block we are changing
			// which is the start of the subgroup for the current cluster
			memcpy(&headers[subgroupIndex * NB_CLUSTER_SUBGROUP + cluster].h1[clusterIndexInSubgroup], h1, 20);
		}

	}

	// now we need to calculate the H2's for all subgroups
	/* Calculate H2 */
	for (int i = 0; i < 8; i++)
	{
		/* Cluster exists? */
		if (i * NB_CLUSTER_SUBGROUP > clustersInGroup)
		{
			break;
		}

		sha1(&headers[i * 8].h1[0][0], SIZE_H1, &h2[i][0]);
	}

	/* Write H2 table */
	for (int i = 0; i < clustersInGroup; i++)
	{
		memcpy(&headers[i].h2, h2, SIZE_H2);
	}

	// update the H3 key table here
	sha1(&h2[0][0], SIZE_H2, &m_h3[clusterGroup * 0x14]);

	// now encrypt and write
	const u8* title_key = &(m_partitions[partition].title_key[0]);

	/* Encrypt headers */
	for (int i = 0; i < clustersInGroup; i++)
	{
		u8 *ptr = reinterpret_cast<u8*>(&headers[i]);

		u8 phData[SIZE_CLUSTER_HEADER];

		/* Set IV key */
		u8 iv[16] = {};

		/* Encrypt */
		aes_cbc_enc(ptr, (u8*) phData, SIZE_CLUSTER_HEADER, title_key, iv);
		memcpy(ptr, (u8*)phData, SIZE_CLUSTER_HEADER);
	}

	/* Encrypt clusters */
	for (int i = 0; i < clustersInGroup; i++)
	{
		u8 *d_ptr = &data[SIZE_CLUSTER_DATA * i];
		const u8 *h_ptr = reinterpret_cast<const u8*>(&headers[i]);

		u8 phData[SIZE_CLUSTER_DATA];

		u8 iv[16];
		std::copy(&h_ptr[OFFSET_CLUSTER_IV], &h_ptr[OFFSET_CLUSTER_IV] + 16, iv);

		/* Encrypt */
		aes_cbc_enc(d_ptr, (u8*) phData, SIZE_CLUSTER_DATA, title_key, iv);
		memcpy(d_ptr, (u8*)phData, SIZE_CLUSTER_DATA);
	}

	/* Jump to first cluster in the group */
	offset_t offset = m_partitions[partition].offset + m_partitions[partition].dataOffset + (u64)((u64)firstClusterInGroup * (u64)SIZE_CLUSTER);

	for (int i = 0; i < clustersInGroup; i++)
	{
		const u8 *d_ptr = &data[SIZE_CLUSTER_DATA * i];
		const u8 *h_ptr = reinterpret_cast<const u8*>(&headers[i]);

		if (!writeDirect(offset, h_ptr, SIZE_CLUSTER_HEADER))
		{
			return false;
		}
		offset += SIZE_CLUSTER_HEADER;

		if (!writeDirect(offset, d_ptr, SIZE_CLUSTER_DATA))
		{
			return false;
		}
		offset += SIZE_CLUSTER_DATA;
	}


	// already calculated the H3 and H4 hashes - rely on surrounding code to
	// read and write those out

	return true;
}

void WiiImage::sha1(const u8 *data, u32 len, u8 *hash)
{
	SHA1(data, len, hash);
}

void WiiImage::aes_cbc_enc(const u8 *in, u8 *out, u32 len, const u8 *key, u8 *iv)
{
	AES_KEY aes_key;

	/* Set encryption key */
	AES_set_encrypt_key(key, 128, &aes_key);

	/* Decrypt data */
	AES_cbc_encrypt(in, out, len, &aes_key, iv, AES_ENCRYPT);
}

void WiiImage::aes_cbc_dec(const u8* in, u8* out, u32 len, const u8* key, u8 *iv)
{
	AES_KEY aes_key;

	/* Set decryption key */
	AES_set_decrypt_key(key, 128, &aes_key);

	/* Decrypt data */
	AES_cbc_encrypt(in, out, len, &aes_key, iv, AES_DECRYPT);
}

bool WiiImage::wii_write_cluster(int partition, int cluster, const u8* in)
{
	// TODO: Delegate to wii_read_clusters

	u8 h0[SIZE_H0];
	u8 h1[SIZE_H1];
	u8 h2[SIZE_H2];

	u8 iv[16];

	/* Calculate cluster group and subgroup */
	int group = cluster / NB_CLUSTER_GROUP;
	int subgroup = (cluster % NB_CLUSTER_GROUP) / NB_CLUSTER_SUBGROUP;

	/* First cluster in the group */
	int f_cluster = group * NB_CLUSTER_GROUP;

	/* Get number of clusters in this group */
	int nb_cluster = wii_nb_cluster(partition) - f_cluster;
	if (nb_cluster > NB_CLUSTER_GROUP)
	{
		nb_cluster = NB_CLUSTER_GROUP;
	}

	/* Allocate memory */
	std::vector<u8> data(SIZE_CLUSTER_DATA * NB_CLUSTER_GROUP);
	std::vector<u8> header(SIZE_CLUSTER_HEADER * NB_CLUSTER_GROUP);

	/* Read group clusters and headers */
	for (int i = 0; i < nb_cluster; i++)
	{
		u8 *d_ptr = &data[SIZE_CLUSTER_DATA * i];
		u8 *h_ptr = &header[SIZE_CLUSTER_HEADER * i];

		/* Read cluster */
		if (!wii_read_cluster(partition, f_cluster + i, d_ptr, h_ptr))
		{
			return false;
		}
	}

	/* Calculate new cluster H0 table */
	for (int i = 0; i < SIZE_CLUSTER_DATA; i += 0x400)
	{
		int index = (i / 0x400) * 20;

		/* Calculate SHA-1 hash */
		sha1(&in[i], 0x400, &h0[index]);
	}

	/* Write new cluster and H0 table */
	int pos_header  = ((cluster - f_cluster) * SIZE_CLUSTER_HEADER);
	int pos_cluster = ((cluster - f_cluster) * SIZE_CLUSTER_DATA);

	memcpy(&data[pos_cluster], in, SIZE_CLUSTER_DATA);
	memcpy(&header[pos_header + OFFSET_H0], h0, SIZE_H0);

	/* Calculate H1 */
	for (int i = 0; i < NB_CLUSTER_SUBGROUP; i++)
	{
		const int pos = SIZE_CLUSTER_HEADER * ((subgroup * NB_CLUSTER_SUBGROUP) + i);
		u8 tmp[SIZE_H0];

		/* Cluster exists? */
		if ((pos / SIZE_CLUSTER_HEADER) > nb_cluster)
		{
			break;
		}

		/* Get H0 */
		memcpy(tmp, &header[pos + OFFSET_H0], SIZE_H0);

		/* Calculate SHA-1 hash */
		sha1(tmp, SIZE_H0, &h1[20 * i]);
	}

	/* Write H1 table */
	for (int i = 0; i < NB_CLUSTER_SUBGROUP; i++)
	{
		const int pos = SIZE_CLUSTER_HEADER * ((subgroup * NB_CLUSTER_SUBGROUP) + i);

		/* Cluster exists? */
		if ((pos / SIZE_CLUSTER_HEADER) > nb_cluster)
		{
			break;
		}

		/* Write H1 table */
		memcpy(&header[pos + OFFSET_H1], h1, SIZE_H1);
	}

	/* Calculate H2 */
	for (int i = 0; i < NB_CLUSTER_SUBGROUP; i++)
	{
		const int pos = (NB_CLUSTER_SUBGROUP * i) * SIZE_CLUSTER_HEADER;
		u8 tmp[SIZE_H1];

		/* Cluster exists? */
		if ((pos / SIZE_CLUSTER_HEADER) > nb_cluster)
		{
			break;
		}

		/* Get H1 */
		memcpy(tmp, &header[pos + OFFSET_H1], SIZE_H1);

		/* Calculate SHA-1 hash */
		sha1(tmp, SIZE_H1, &h2[20 * i]);
	}

	/* Write H2 table */
	for (int i = 0; i < nb_cluster; i++)
	{
		u32 nb = SIZE_CLUSTER_HEADER * i;

		/* Write H2 table */
		memcpy(&header[nb + OFFSET_H2], h2, SIZE_H2);
	}

	/* Set title key */
	const u8* title_key = &(m_partitions[partition].title_key[0]);

	/* Encrypt headers */
	for (int i = 0; i < nb_cluster; i++)
	{
		u8 *ptr = &header[SIZE_CLUSTER_HEADER * i];
		u8 phData[SIZE_CLUSTER_HEADER];

		/* Set IV key */
		memset(iv, 0, 16);

		/* Encrypt */
		aes_cbc_enc(ptr, phData, SIZE_CLUSTER_HEADER, title_key, iv);
		memcpy(ptr, phData, SIZE_CLUSTER_HEADER);
	}

	/* Encrypt clusters */
	for (int i = 0; i < nb_cluster; i++)
	{
		u8 *d_ptr = &data[SIZE_CLUSTER_DATA * i];
		const u8 *h_ptr = &header[SIZE_CLUSTER_HEADER * i];

		u8 phData[SIZE_CLUSTER_DATA];


		/* Set IV key */
		memcpy(iv, &h_ptr[OFFSET_CLUSTER_IV], 16);

		/* Encrypt */
		aes_cbc_enc(d_ptr, phData, SIZE_CLUSTER_DATA, title_key, iv);
		memcpy(d_ptr, phData, SIZE_CLUSTER_DATA);
	}

	/* Jump to first cluster in the group */
	largesize_t offset = m_partitions[partition].offset + m_partitions[partition].dataOffset + static_cast<largesize_t>(f_cluster) * SIZE_CLUSTER;

	/* Write new clusters */
	for (int i = 0; i < nb_cluster; i++)
	{
		const u8 *d_ptr = &data[SIZE_CLUSTER_DATA * i];
		const u8 *h_ptr = &header[SIZE_CLUSTER_HEADER * i];

		/* Write cluster header */
		if (writeDirect(offset, h_ptr, SIZE_CLUSTER_HEADER))
		{
			// written ok, add value to offset
			offset += SIZE_CLUSTER_HEADER;

			if (writeDirect(offset, d_ptr, SIZE_CLUSTER_DATA))
			{
				offset += SIZE_CLUSTER_DATA;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}

	if (!wii_calc_group_hash(partition, cluster))
	{
		return false;
	}
	return true;
}

int WiiImage::wii_nb_cluster(int partition) const
{
	return static_cast<int>(m_partitions[partition].dataSize / SIZE_CLUSTER);
}

bool WiiImage::wii_write_data_file(int partition, offset_t offset, Stream* file, largesize_t size)
{
	DLOG << "Write data file from " << HEX << offset << " to " << (offset + size);

	progressHandler().startProgress("writeFile", static_cast<int>((size + SIZE_CLUSTER - 1) / SIZE_CLUSTER));

	const int firstCluster = static_cast<int>(offset / SIZE_CLUSTER_DATA);
	int offset_start = static_cast<int>(offset - firstCluster * SIZE_CLUSTER_DATA);

	// read the H3 and H4
	io_read(m_h3, SIZE_H3, m_partitions[partition].offset + m_partitions[partition].h3_offset);

	/* Write clusters */
	int writen = 0;
	int currentCluster = 0;
	while (writen < size)
	{
		if (progressHandler().stopRequested())
		{
			return false;
		}

		int toWrite = 0;
		if (((firstCluster + currentCluster) % NB_CLUSTER_GROUP) != 0 || offset_start != 0)
		{
			// not at the start so our max size is different
			// and also our cluster offset
			toWrite = std::min<int>(static_cast<int>(size), (NB_CLUSTER_GROUP - (firstCluster % NB_CLUSTER_GROUP)) * SIZE_CLUSTER_DATA - offset_start);

			if (!wii_write_clusters(partition, firstCluster, offset_start, toWrite, file))
			{
				DLOG << "Error writing clusters";
				return false;
			}
			// round up the cluster count
			currentCluster = NB_CLUSTER_GROUP - (firstCluster % NB_CLUSTER_GROUP);
		}
		else
		{
			// potentially full block
			toWrite = std::min<int>(static_cast<int>(size - writen), NB_CLUSTER_GROUP * SIZE_CLUSTER_DATA);

			if (!wii_write_clusters(partition, firstCluster + currentCluster, offset_start, toWrite, file))
			{
				DLOG << "Error writing clusters";
				return false;
			}
			// we simply add a full cluster block
			currentCluster += NB_CLUSTER_GROUP;

		}
		offset_start = 0;
		writen += toWrite;

		progressHandler().progress(static_cast<int>(currentCluster));
	}

	if (!writeDirect(m_partitions[partition].h3_offset + m_partitions[partition].offset, m_h3, SIZE_H3))
	{
		DLOG << "Unable to write H3 table";
		return false;
	}

	sha1(m_h3, SIZE_H3, m_h4);
	if (!writeDirect(m_partitions[partition].tmdOffset + OFFSET_TMD_HASH + m_partitions[partition].offset, m_h4, SIZE_H4))
	{
		DLOG << "Unable to write H4 value";
		return false;
	}

	wii_trucha_signing(partition);

	return true;
}

bool WiiImage::wii_write_data_file(int partition, offset_t offset, void* data, largesize_t size)
{
	MemoryStream stream(data, static_cast<ptrdiff_t>(size));
	return wii_write_data_file(partition, offset, &stream, size);
}

bool WiiImage::wii_write_data(int partition, offset_t offset, Stream* file, largesize_t size)
{
	/* Calculate some needed information */
	u32 cluster_start = (u32)(offset / (u64)(SIZE_CLUSTER_DATA));
	u32 offset_start = (u32)(offset - (cluster_start * (u64)(SIZE_CLUSTER_DATA)));

	/* Write clusters */
	int writen = 0;
	int clusterCount = 0;
	while (writen < size)
	{
		int toWrite = 0;
		if (((cluster_start + clusterCount) % 64) != 0 || offset_start != 0)
		{
			// not at the start so our max size is different
			// and also our cluster offset
			toWrite = (NB_CLUSTER_GROUP - (cluster_start%64))* SIZE_CLUSTER_DATA;
			toWrite = toWrite - offset_start;

			// max check
			if (toWrite > size)
			{
				toWrite = (int)size;
			}

			if (!wii_write_clusters(partition, cluster_start, offset_start, toWrite, file))
			{
				DLOG << "Error writing clusters";
				return false;
			}
			// round up the cluster count
			clusterCount = NB_CLUSTER_GROUP - (cluster_start % NB_CLUSTER_GROUP);
		}
		else
		{
			// potentially full block
			toWrite = NB_CLUSTER_GROUP * SIZE_CLUSTER_DATA;

			// max check
			if (toWrite > (size-writen))
			{
				toWrite = (u32)(size-writen);
			}

			if (!wii_write_clusters(partition, cluster_start + clusterCount, offset_start, toWrite, file))
			{
				DLOG << "Error writing clusters";
				return false;
			}
			// we simply add a full cluster block
			clusterCount = clusterCount + NB_CLUSTER_GROUP;

		}
		offset_start = 0;
		writen += toWrite;


	}
	return true;
}

//////////////////////////////////////////////////////////////////////////

template<typename T1, typename T2, typename T3>
static std::string formatErrorData(T1 v1, T2 v2, T3 v3)
{
	std::stringstream result;
	result << v1 << ';' << v2 << ';' << v3;
	return result.str();
}

template<typename T1, typename T2, typename T3, typename T4>
static std::string formatErrorData(T1 v1, T2 v2, T3 v3, T4 v4)
{
	std::stringstream result;
	result << v1 << ';' << v2 << ';' << v3 << ';' << v4;
	return result.str();
}

bool WiiImage::checkPartition(int partition)
{
	const int groupCount = static_cast<int>(m_partitions[partition].dataSize / (SIZE_CLUSTER * NB_CLUSTER_GROUP));
	offset_t offset = m_partitions[partition].offset + m_partitions[partition].dataOffset;

	std::vector<SHA1Hash> actualH3Hashes(groupCount);
	readDirect(m_partitions[partition].offset + m_partitions[partition].h3_offset, &actualH3Hashes[0], sizeof(HashData) * groupCount);

	// Checking signature...
// 	{
// 		const u32 size = m_partitions[partition].tmdSize;
// 		std::vector<u8> buffer(size);
// 
// 		readDirect(m_partitions[partition].offset + m_partitions[partition].tmdOffset, &buffer[0], size);
// 		HashData contentHash;
// 		HashData signatureHash;
// 		sha1(&buffer[0x140], size - 0x140, contentHash);
// 		sha1(&buffer[4], 256, signatureHash);
// 
// 		if (!std::equal(signatureHash, signatureHash + 20, contentHash))
// 		{
// 			u8 decryptedSignature[256];
// 
// 			RSA_public_decrypt()
// 			if (signatureHash[0] != 0 && contentHash[0] != 0)
// 			{
// 				DLOG << "Signature check failed!";
// 				return false;
// 			}
// 		}
// 	}

	std::vector<SHA1Hash> expectedH3Hashes(groupCount);
	std::vector<u8> data(64 * SIZE_CLUSTER_DATA);
	// array for each cluster and each hash
	std::vector<ClusterHeader> headers(64);

	progressHandler().startProgress("checkPartition", groupCount);

	for (int group = 0; group < groupCount; group++)
	{
		if (progressHandler().stopRequested())
		{
			return false;
		}

		for (int i = 0; i < NB_CLUSTER_GROUP; i++)
		{
			const int clusterIndex = group * NB_CLUSTER_GROUP + i;
			const offset_t clusterOffset = clusterIndex * SIZE_CLUSTER_DATA;
			const offset_t clusterPhOffset = clusterOffset + m_partitions[partition].offset + SIZE_CLUSTER_HEADER * clusterIndex + m_partitions[partition].dataOffset;

			u8 buf[SIZE_CLUSTER_DATA];
			readDirect(offset, buf, SIZE_CLUSTER_HEADER);

			u8 iv[16] = {};
			aes_cbc_dec(buf, reinterpret_cast<u8*>(&headers[i]), SIZE_CLUSTER_HEADER, m_partitions[partition].title_key, iv);
			std::copy(&buf[OFFSET_CLUSTER_IV], &buf[OFFSET_CLUSTER_IV] + 16, iv);

			readDirect(offset + SIZE_CLUSTER_HEADER, buf, SIZE_CLUSTER_DATA);
			aes_cbc_dec(buf, &data[SIZE_CLUSTER_DATA * i], SIZE_CLUSTER_DATA, m_partitions[partition].title_key, iv);

			for (int j = 0; j < 31; j++)
			{
				HashData hash = {};
				sha1(&data[SIZE_CLUSTER_DATA * i + 0x400 * j], 0x400, &hash[0]);

				if (!std::equal(&hash[0], &hash[0] + 20, headers[i].h0[j]))
				{
					DLOG << "h0 does not match! Cluster: " << clusterIndex << " (partition offset: " << clusterOffset
						<< ", physical offset: " << clusterPhOffset << ")";
					m_lastErrorData = formatErrorData(partition, "h0", i);
					return false;
				}
			}

			offset += SIZE_CLUSTER;
		}

		HashData h1[8][8] = {};
		for (int subgroup = 0; subgroup < 8; subgroup++)
		{
			for (int cluster = 0; cluster < 8; cluster++)
			{
				sha1(&headers[subgroup * 8 + cluster].h0[0][0], 20 * 31, &h1[subgroup][cluster][0]);
			}
		}

		HashData h2[8] = {};
		for (int gr = 0; gr < 8; gr++)
		{
			sha1(&h1[gr][0][0], 8 * 20, &h2[gr][0]);
		}

		for (int cluster = 0; cluster < NB_CLUSTER_GROUP; cluster++)
		{
			const int clusterIndex = group * NB_CLUSTER_GROUP + cluster;
			const offset_t clusterOffset = clusterIndex * SIZE_CLUSTER_DATA;
			const offset_t clusterPhOffset = clusterOffset + m_partitions[partition].offset + SIZE_CLUSTER_HEADER * clusterIndex + m_partitions[partition].dataOffset;
			
			if (!std::equal(&h2[0][0], &h2[0][0] + 8 * 20, &headers[cluster].h2[0][0]))
			{
				DLOG << "h2 does not match! Cluster: " << clusterIndex << " (partition offset: " << clusterOffset
					<< ", physical offset: " << clusterPhOffset << ")";
				m_lastErrorData = formatErrorData(partition, "h2", cluster);
				return false;
			}
			for (int i = 0; i < 8; i++)
			{
				if (!std::equal(&h1[cluster / 8][i][0], &h1[cluster / 8][i][0] + 20, &headers[cluster].h1[i][0]))
				{
					DLOG << "h1 of " << i << " cluster does not match! Cluster: " << clusterIndex << " (partition offset: " << clusterOffset
						<< ", physical offset: " << clusterPhOffset << ")";
					m_lastErrorData = formatErrorData(partition, "h1", cluster, i);
					return false;
				}
			}
		}

		sha1(&h2[0][0], sizeof(HashData) * 8, &expectedH3Hashes[group][0]);
		if (!std::equal(&expectedH3Hashes[group][0], &expectedH3Hashes[group][0] + sizeof(HashData), &actualH3Hashes[group][0]))
		{
			DLOG << "h0 does not match! Cluster group: " << group;
			m_lastErrorData = formatErrorData(partition, "h0_group", group);
			return false;
		}

		progressHandler().progress(group);
	}
	progressHandler().finishProgress();

	return true;
}

std::string WiiImage::discId() const
{
	return m_header.discId();
}

std::string WiiImage::lastErrorData() const
{
	return m_lastErrorData;
}

}
