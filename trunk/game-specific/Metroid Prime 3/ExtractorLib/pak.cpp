#include "pak.h"
#include "lzo/lzoconf.h"
#include "lzo/lzo1x.h"
#include <FileStream.h>
#include <ImageFileStream.h>
#include <stdio.h>
#include <io.h>
#include <algorithm>

static int lzo1x_init_code = lzo_init();

using namespace Consolgames;

#define ALIGN 0x40
#define CHUNK 0x4000
#define MAX_CHUNK 0x10000
#define MAX_LZO_SIZE(size) (size + size / 16 + 64 + 3)

static std::wstring strToWStr(const std::string& str)
{
	std::wstring result(str.begin(), str.end());
	return result;
}

static uint32 alignSize(uint32 size)
{
	return ((size + (ALIGN - 1)) / ALIGN) * ALIGN;
}

std::string hashToStr(const Hash& hash)
{
	std::string str(16, '\0');
#ifdef _MSC_VER
	sprintf_s(&str[0], str.size() + 1, "%16.16I64X", hash);
#else
	sprintf(&str[0], "%16.16I64X", hash);
#endif
	return str;
}

Hash hashFromData(const char* c)
{
	Hash hash = 0;
	for (int i = 0; i < 8; i++)
	{
		hash <<= 8;
		hash |= static_cast<uint8>(c[i]);
	}
	return hash;
}


int PakArchive::findSegment(ResType type) const
{
	for (size_t i = 0; i < m_segments.size(); i++)
	{
		if (m_segments[i].res == type)
		{
			return i;
		}
	}
	return -1;
}

int PakArchive::getSegmentOffset(int index) const
{
	int result = 0;
	for(int i = 0; i < index; i++)
	{
		result += m_segments[i].size;
	}
	return result;
}

bool PakArchive::extractFile(const FileRecord& file, Stream* out)
{
	m_stream->seek(m_dataOffset + file.offset, Stream::seekSet);

	if (file.packed)
	{
		CompressedFileHeader header = readCmpdFileHeader();

		switch (header.type)
		{
			case CompressedFileHeader::Normal:
			{
				CompressedStreamHeader cmpdHeader = readCmpdStreamHeader();
				decompressLzo(m_stream, cmpdHeader.lzoSize, out);
				break;
			}
			case CompressedFileHeader::Texture:
			{
				m_stream->readUInt32(); // 12
				m_stream->readUInt32(); // 12
				CompressedStreamHeader cmpdHeader = readCmpdStreamHeader();

				const bool packed = ((cmpdHeader.flags & FlagCompressed) != 0);
				out->writeStream(m_stream, 12);
				
				if (!packed)
				{
					out->writeStream(m_stream, cmpdHeader.dataSize);
				}
				else
				{
					decompressLzo(m_stream, cmpdHeader.lzoSize, out);
				}
				break;
			}
		}
	}
	else
	{
		out->writeStream(m_stream, file.size);
	}
	
	return true;
}

bool PakArchive::extractFile(Hash filenameHash, Consolgames::Stream* out)
{
	for (size_t i = 0; i < m_files.size(); i++)
	{
		if (m_files[i].hash == filenameHash)
		{
			return extractFile(m_files[i], out);
		}
	}
	return false;
}

uint32 PakArchive::compressLzo(Stream* in, int size, Stream* out, void* lzoWorkMem)
{
	unsigned int lzo_size = 0;
	const int cChunk = 0x4000;
	uint8 buf[cChunk];
	std::vector<uint8> compressionBuffer(MAX_LZO_SIZE(cChunk));
	while (size > 0)
	{
		int chunk = min(cChunk, size);
		lzo_uint lzoChunk = 0;
		uint16 lzoChunkStored = 0;
		size -= chunk;
		in->read(buf, chunk);
		VERIFY(lzo1x_999_compress(buf, chunk, &compressionBuffer[0], &lzoChunk, lzoWorkMem) == LZO_E_OK);
		lzo_size += lzoChunk + 2;
		lzoChunkStored = endian16(static_cast<uint16>(lzoChunk));
		out->write(&lzoChunkStored, 2);
		out->write(&compressionBuffer[0], lzoChunk);
	}
	return lzo_size;
}

uint32 PakArchive::compressLzo(Stream* in, int size, Stream *out)
{
	return compressLzo(in, size, out, &m_lzoWorkMem[0]);
}

void PakArchive::decompressLzo(Stream* lzoStream, uint32 lzoSize, Stream* outStream)
{
	uint8 lzoBuffer[MAX_CHUNK];
	uint8 decompressionBuffer[MAX_LZO_SIZE(MAX_CHUNK)];
	while (lzoSize > 0)
	{
		unsigned short chunk = endian16(lzoStream->readUInt16());
		lzoSize -= 2;
		lzoStream->read(&lzoBuffer[0], chunk);
		lzoSize -= chunk;
		unsigned long size = 0;
		VERIFY(lzo1x_decompress(&lzoBuffer[0], chunk, &decompressionBuffer[0], &size, NULL) == LZO_E_OK);
		outStream->write(&decompressionBuffer[0], size);
	}
}

uint32 PakArchive::storeFile(Stream* file, Stream* stream, bool isPacked, bool isTexture, uint8 flags)
{
	int size = static_cast<int>(file->size());
	uint32 totalSize = 0;
	offset_t offset = stream->position();

	if (isPacked)
	{
		CompressedFileHeader header;
		header.sign = "CMPD";
		header.type = isTexture ? endian32(2) : endian32(1);

		CompressedStreamHeader cmpdHeader;
		cmpdHeader.flags = (flags == 0xFF) ? (FlagCompressed | (isTexture ? FlagTexture : FlagData)) : flags;
		cmpdHeader.dataSize = endian32(isTexture ? (size - 12) : size);	
		stream->seek(offset + sizeof(CompressedFileHeader) + sizeof(CompressedStreamHeader), Stream::seekSet);

		if (isTexture)
		{
			size -= 12;
			stream->seek(8, Stream::seekCur);
			stream->writeStream(file, 12);
			totalSize += 12;
		}

		const bool dataPacked = ((cmpdHeader.flags & FlagCompressed) != 0);

		if (dataPacked)
		{
			const uint32 lzoSize = compressLzo(file, size, stream);
			cmpdHeader.lzoSize = endian32(lzoSize) >> 8;
			totalSize += lzoSize;
		}
		else
		{
			stream->writeStream(file, size);
			totalSize += size;
		}

		stream->seek(offset, Stream::seekSet);
		stream->write(&header, sizeof(header));
		if (isTexture)
		{
			stream->writeUInt32(endian32(12));
			stream->writeUInt32(endian32(12));
			totalSize += 8;
		}
		stream->write(&cmpdHeader, sizeof(cmpdHeader)); 
		totalSize += sizeof(CompressedFileHeader) + sizeof(CompressedStreamHeader);
	}
	else
	{
		stream->writeStream(file, size);
		totalSize = size;
	}

	stream->seek(offset + totalSize, Stream::seekSet);
	int padding = (ALIGN - (totalSize % ALIGN)) % ALIGN;
	
	if (isPacked)
	{
		totalSize += padding;
	}

	while (padding > 0)
	{
		stream->writeUInt8(0xFF);
		padding--;
	}
	return totalSize;
}

uint32 PakArchive::storeFile(const std::wstring& filename, Stream* stream, bool isPacked, bool isTexture, uint8 flags)
{
	FileStream file(filename, Stream::modeRead);
	return storeFile(&file, stream, isPacked, isTexture, flags);
}

void PakArchive::swapFileEndian(FileRecord& fileRecord)
{
	fileRecord.packed = endian32(fileRecord.packed);
	fileRecord.size   = endian32(fileRecord.size);
	fileRecord.offset = endian32(fileRecord.offset);
	fileRecord.hash = endian64(fileRecord.hash);
}

bool PakArchive::open(Stream* pak)
{
	m_stream = NULL;

	pak->seek(0, Stream::seekSet);
	pak->read(&m_header, sizeof(PakHeader));
	if (m_header.tag02 != 0x02000000 && m_header.tag40 != 0x40000000)
	{
		DLOG << "Invalid signature!";
		return false;
	}

	pak->seek(ALIGN, Stream::seekSet);
	const int fileCount = endian32(pak->readUInt32());
	ASSERT(fileCount < 10000);
	m_segments.resize(fileCount);

	if (m_segments.empty())
	{
		return false;
	}

	pak->read(&m_segments[0], m_segments.size() * sizeof(SegmentRecord));
	for (size_t i = 0; i < m_segments.size(); i++)
	{
		m_segments[i].size = endian32(m_segments[i].size);
	}

	m_strgIndex = -1;
	m_rshdIndex = -1;
	m_dataIndex = -1;
	m_strgOffset = 0;
	m_rshdOffset = 0;
	m_dataOffset = 0;

	m_strgIndex = findSegment("STRG");
	if (m_strgIndex == -1)
	{
		return false;
	}
	
	m_rshdIndex = findSegment("RSHD");
	if (m_rshdIndex == -1)
	{
		return false;
	}

	m_dataIndex = findSegment("DATA");
	if (m_dataIndex == -1)
	{
		return false;
	}


	m_strgOffset = getSegmentOffset(m_strgIndex) + ALIGN * 2;
	m_rshdOffset = getSegmentOffset(m_rshdIndex) + ALIGN * 2;
	m_dataOffset = getSegmentOffset(m_dataIndex) + ALIGN * 2;

	pak->seek(m_rshdOffset, Stream::seekSet);
	m_files.resize(endian32(pak->readUInt32()));

	if (m_files.empty())
	{
		return false;
	}

	pak->read(&m_files[0], sizeof(FileRecord) * m_files.size());
	
	std::for_each(m_files.begin(), m_files.end(), swapFileEndian);

	if (m_strgIndex != -1)
	{
		pak->seek(m_strgOffset, Stream::seekSet);
		m_names.resize(endian32(pak->readUInt32()));
		
		if (!m_names.empty())
		{
			std::vector<char> buffer(m_segments[m_strgIndex].size - 4);
			pak->read(&buffer[0], buffer.size());
			
			const char* c = &buffer[0];
			for (size_t i = 0; i < m_names.size(); i++)
			{
				m_names[i].name = c;
				c += m_names[i].name.size() + 1;
				m_names[i].res = c;
				c += 4;
				m_names[i].hash = hashFromData(c);
				c += 8;
			}
		}
	}

	m_stream = pak;
	return true;
}

bool PakArchive::open(const std::wstring& filename)
{
	m_fileStream.reset(new FileStream(filename, Stream::modeRead));
	if (!m_fileStream->opened())
	{
		return false;
	}

	return open(m_fileStream.get());
}

std::string PakArchive::findName(const Hash& hash) const
{
	for (size_t i = 0; i < m_names.size(); i++)
	{
		if(m_names[i].hash == hash)
		{
			return m_names[i].name;
		}
	}
	return std::string();
}

bool PakArchive::extract(const std::wstring& outDir, const std::set<ResType>& types, bool useNames)
{
	if (!opened())
	{
		return false;
	}

	initProgress(m_files.size());

	for (size_t i = 0; i < m_files.size(); i++)
	{
		if (stopRequested())
		{
			return false;
		}

		if (types.empty() || types.find(m_files[i].res) != types.end())
		{
			std::string filename = m_files[i].name();
			progress(i, filename.c_str());
			
			std::wstring path;

			bool nameFound = false;
			if (useNames)
			{
				std::wstring name = strToWStr(findName(m_files[i].hash));
				if (!name.empty())
				{
					path = outDir + std::wstring(PATH_SEPARATOR_STR_L) + name + std::wstring(L".") + strToWStr(m_files[i].res.toString());
					nameFound = true;
				}
			}
			if (!nameFound)
			{
				path = outDir + std::wstring(PATH_SEPARATOR_STR_L) + strToWStr(filename);
			}
		  
			FileStream stream(path, Stream::modeWrite);
			if (!stream.opened())
			{
				return false;
			}

			extractFile(m_files[i], &stream);
		}
	}
	
	finishProgress();

	return true;
}

std::wstring PakArchive::findFile(const std::vector<std::wstring>& inputDirs, Hash hash, ResType res) const
{
	const std::wstring filename = strToWStr(hashToStr(hash)) + L"." + strToWStr(res.toString());
	for (size_t i = 0; i < inputDirs.size(); i++)
	{
		std::wstring path = inputDirs[i] + PATH_SEPARATOR_STR_L + filename;
		if(_waccess(path.c_str(), 0) == 0)
		{
			return path;
		}
	}
	return std::wstring();
}

bool PakArchive::rebuild(Consolgames::Stream* outStream, const std::vector<std::wstring>& inputDirs,
		const std::set<ResType>& types, const std::map<Hash,Hash>& mergeMap)
{
	for (std::map<Hash,Hash>::const_iterator it = mergeMap.begin(); it != mergeMap.end(); it++)
	{
		if (mergeMap.find(it->second) != mergeMap.end())
		{
			// Possible recursive or dead-end mapping
			return false;
		}
	}

	initProgress(fileCount());

	unsigned int offset = m_dataOffset;

	std::vector<FileRecord> files(fileCount());

	for (size_t i = 0; i < files.size(); i++)
	{	
		if (stopRequested())
		{
			return false;
		}

		progress(i, NULL);
		files[i] = m_files[i];
		if (!mergeMap.empty() && mergeMap.find(files[i].hash) != mergeMap.end()
			&& findFileRecord(mergeMap.find(files[i].hash)->second, m_files) != NULL)
		{
			continue;
		}
		files[i].offset = offset - m_dataOffset;
		outStream->seek(offset, Stream::seekSet);

		bool fileReplaced = false;
		if(types.empty() || types.find(files[i].res) != types.end())
		{
			std::wstring filename = findFile(inputDirs, files[i].hash, files[i].res);
			if (!filename.empty())
			{
				bool isTexture = false;
				uint8 flags = 0xFF;
				// read flags
				if (files[i].packed != 0)
				{
					m_stream->seek(m_dataOffset + m_files[i].offset, Stream::seekSet);
					CompressedFileHeader fileHeader = readCmpdFileHeader();
					isTexture = fileHeader.isTexture();
					ASSERT(fileHeader.type == CompressedFileHeader::Normal || fileHeader.type == CompressedFileHeader::Texture);

					m_stream->seek(m_dataOffset + m_files[i].offset + sizeof(CompressedFileHeader) + (isTexture ? 8 : 0), Stream::seekSet);
					flags = m_stream->readUInt8();
				}

				files[i].size = alignSize(storeFile(filename, outStream, (files[i].packed != 0), isTexture, flags));
				fileReplaced = true;
			}
		}
		
		if (!fileReplaced)
		{
			m_stream->seek(m_dataOffset + m_files[i].offset, Stream::seekSet);
			outStream->writeStream(m_stream, files[i].size);
		}
		offset += files[i].size;
		offset = ((offset + (ALIGN - 1)) / ALIGN) * ALIGN;
	}

	for (std::map<Hash,Hash>::const_iterator it = mergeMap.begin(); it != mergeMap.end(); it++)
	{
		FileRecord* mappedRecord = findFileRecord(it->first, files);
		if (mappedRecord == NULL)
		{
			continue;
		}
		const FileRecord* sourceRecord = findFileRecord(it->second, files);
		if (sourceRecord == NULL)
		{
			continue;
		}
		mappedRecord->offset = sourceRecord->offset;
		mappedRecord->size = sourceRecord->size;
		mappedRecord->packed = sourceRecord->packed;
	}

	outStream->seek(0, Stream::seekSet);
	outStream->write(&m_header, sizeof(m_header));
	outStream->seek(ALIGN, Stream::seekSet);
	int segmentCount = endian32(m_segments.size());
	outStream->write(&segmentCount, 4);
	
	std::vector<SegmentRecord> segments(m_segments.size());
	for (size_t i = 0; i < m_segments.size(); i++)
	{
		segments[i].res = m_segments[i].res;
		segments[i].size = endian32(m_segments[i].size);
	}
	segments[m_dataIndex].size = endian32(offset - m_dataOffset);
	outStream->write(&segments[0], segments.size() * sizeof(SegmentRecord)); 
								 
	outStream->seek(m_rshdOffset, Stream::seekSet);
	uint32 fileCount = endian32(files.size());
	outStream->write(&fileCount, 4);
	
	std::for_each(files.begin(), files.end(), swapFileEndian);
	outStream->write(&files[0], files.size() * sizeof(FileRecord));

	m_stream->seek(m_strgOffset, Stream::seekSet);
	outStream->seek(m_strgOffset, Stream::seekSet);
	outStream->writeStream(m_stream, m_segments[m_strgIndex].size); 

	finishProgress();

	return true;
}

bool PakArchive::rebuild(const std::wstring& destName, const std::vector<std::wstring>& inputDirs, const std::set<ResType>& types, const std::map<Hash,Hash>& mergeMap)
{
	FileStream stream(destName, Stream::modeWrite);
	if (!stream.opened())
	{
		return false;
	}
	return rebuild(&stream, inputDirs, types, mergeMap);
}

void PakArchive::initProgress(int count)
{
	if (m_progressHandler != NULL)
	{
		m_progressHandler->init(count);
	}
}

void PakArchive::progress(int value, const char* message)
{
	if (m_progressHandler != NULL)
	{
		m_progressHandler->progress(value, message);
	}
}


void PakArchive::finishProgress()
{
	if (m_progressHandler != NULL)
	{
		m_progressHandler->finish();
	}
}

bool PakArchive::stopRequested()
{
	if (m_progressHandler != NULL)
	{
		return m_progressHandler->stopRequested();
	}
	return false;
}

bool PakArchive::opened() const
{
	return (m_stream != NULL);
}

PakArchive::PakArchive()
	: m_lzoWorkMem(LZO1X_999_MEM_COMPRESS)
	, m_stream(NULL)
	, m_progressHandler(NULL)
{
}

int PakArchive::fileCount() const
{
	return static_cast<int>(m_files.size());
}

CompressedFileHeader PakArchive::readCmpdFileHeader()
{
	CompressedFileHeader fileHeader;
	m_stream->read(&fileHeader, sizeof(fileHeader));
	fileHeader.type = endian32(fileHeader.type);
	return fileHeader;
}

CompressedStreamHeader PakArchive::readCmpdStreamHeader()
{
	CompressedStreamHeader cmpdHeader;
	m_stream->read(&cmpdHeader, sizeof(cmpdHeader));
	cmpdHeader.lzoSize = endian32(cmpdHeader.lzoSize << 8);
	cmpdHeader.dataSize = endian32(cmpdHeader.dataSize);
	return cmpdHeader;
}

void PakArchive::setProgressHandler(IPakProgressHandler* handler)
{
	m_progressHandler = handler;
}

std::vector<Hash> PakArchive::fileNamehashesList() const
{
	std::vector<Hash> hashes;
	for (size_t i = 0; i < m_files.size(); i++)
	{
		hashes.push_back(m_files[i].hash);
	}
	return hashes;
}

FileRecord* PakArchive::findFileRecord(Hash hash, std::vector<FileRecord>& files)
{
	for (size_t i = 0; i < files.size(); i++)
	{
		if (files[i].hash == hash)
		{
			return &files[i];
		}
	}
	return NULL;
}

const std::vector<FileRecord>& PakArchive::files() const
{
	return m_files;
}

Stream* PakArchive::openFileDirect(Hash hash)
{
	const FileRecord* file = findFileRecord(hash, m_files);
	if (file == NULL)
	{
		return NULL;
	}
	return new ImageFileStream(m_stream, m_dataOffset + file->offset, file->size, Stream::modeRead);
}