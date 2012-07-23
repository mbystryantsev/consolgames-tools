#include "pak.h"
#include "miniLZO/minilzo.h"
#include <FileStream.h>
#include <ImageFileStream.h>
#include <stdio.h>
#include <io.h>
#include <algorithm>

using namespace Consolgames;

#define endian(v) (((unsigned int)v >> 24) | (((unsigned int)v >> 8) & 0xFF00) | (((unsigned int)v << 8) & 0xFF0000) | ((unsigned int)v << 24))
#define endianw(v) ((v >> 8) | (v << 8))

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
		hash |= static_cast<u8>(c[i]);
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
		CompressedFileHeader header;
		m_stream->read(&header, sizeof(header));
		header.type = endian(header.type);

		switch(header.type)
		{
			case 1:
			{
				CompressedStreamHeader cmpdHeader = readCmpdStreamHeader();
				decompressLzo(m_stream, cmpdHeader.lzoSize, out);
				break;
			}
			case 2:
			{
				m_stream->read32(); // 12
				m_stream->read32(); // 12
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
u32 PakArchive::compressLzo(Stream* in, int size, Stream *out)
{
	unsigned int lzo_size = 0;
	u8 buf[CHUNK];
	std::vector<u8> compressionBuffer(CHUNK * 2);
	while (size > 0)
	{
		int chunk = min(CHUNK, size);
		lzo_uint lzoChunk = 0;
		u16 lzoChunkStored = 0;
		size -= chunk;
		in->read(buf, chunk);
		lzo1x_1_compress(buf, chunk, &compressionBuffer[0], &lzoChunk, &m_lzoWorkMem[0]);
		lzo_size += lzoChunk + 2;
		lzoChunkStored = endian16(static_cast<u16>(lzoChunk));
		out->write(&lzoChunkStored, 2);
		out->write(&compressionBuffer[0], lzoChunk);
	}
	return lzo_size;
}

void PakArchive::decompressLzo(Stream* lzoStream, u32 lzoSize, Stream* outStream)
{
	//std::vector<u8> lzoBuffer(CHUNK);
	//std::vector<u8> decompressionBuffer(0x800000);
	u8 lzoBuffer[CHUNK];
	u8 decompressionBuffer[0x10000];
	while (lzoSize > 0)
	{
		unsigned short chunk = endian16(lzoStream->read16());
		lzoSize -= 2;
		lzoStream->read(&lzoBuffer[0], chunk);
		lzoSize -= chunk;
		unsigned long size = 0;
		lzo1x_decompress(&lzoBuffer[0], chunk, &decompressionBuffer[0], &size, NULL);
		outStream->write(&decompressionBuffer[0], size);
	}
}

u32 PakArchive::storeFile(Stream* file, Stream* stream, bool isPacked, bool isTexture)
{
	int size = static_cast<int>(file->size());
	u32 totalSize = 0;
	offset_t offset = stream->tell();

	if (isPacked)
	{
		CompressedFileHeader header;
		header.sign = "CMPD";
		header.type = isTexture ? endian32(2) : endian32(1);

		CompressedStreamHeader cmpdHeader;
		cmpdHeader.flags = FlagCompressed | (isTexture ? FlagTexture : FlagData);
		cmpdHeader.dataSize = endian32(isTexture ? (size - 12) : size);	
		stream->seek(offset + sizeof(CompressedFileHeader) + sizeof(CompressedStreamHeader), Stream::seekSet);

		if (isTexture)
		{
			size -= 12;
			stream->seek(8, Stream::seekCur);
			stream->writeStream(file, 12);
			totalSize += 12;
		}

		const u32 lzoSize = compressLzo(file, size, stream);
		cmpdHeader.lzoSize = endian32(lzoSize) >> 8;
		totalSize += lzoSize;

		stream->seek(offset, Stream::seekSet);
		stream->write(&header, sizeof(header));
		if (isTexture)
		{
			stream->write32(12);
			stream->write32(12);
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
	int padding = totalSize % ALIGN;
	while (padding > 0)
	{
		stream->write8(0xFF);
		padding--;
	}
	return totalSize;
}

u32 PakArchive::storeFile(const std::string& filename, Stream* stream, bool isPacked, bool isTexture)
{
	FileStream file(filename, Stream::modeRead);
	return storeFile(&file, stream, isPacked, isTexture);
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
	pak->seek(ALIGN, Stream::seekSet);
	m_segments.resize(endian32(pak->read32()));

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
	m_files.resize(endian32(pak->read32()));

	if (m_files.empty())
	{
		return false;
	}

	pak->read(&m_files[0], sizeof(FileRecord) * m_files.size());
	
	std::for_each(m_files.begin(), m_files.end(), swapFileEndian);

	if (m_strgIndex != -1)
	{
		pak->seek(m_strgOffset, Stream::seekSet);
		m_names.resize(endian32(pak->read32()));
		
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

bool PakArchive::open(const std::string& filename)
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

bool PakArchive::extract(const std::string& outDir, const std::set<ResType>& types, bool useNames)
{
	if (!opened())
	{
		return false;
	}

	initProgress(m_files.size());

	for (size_t i = 0; i < m_files.size(); i++)
	{
		if (types.empty() || types.find(m_files[i].res) != types.end())
		{
			std::string filename = m_files[i].name();
			progress(i, filename.c_str());
			
			std::string path;

			bool nameFound = false;
			if (useNames)
			{
				std::string name = findName(m_files[i].hash);
				if (!name.empty())
				{
					path = outDir + std::string(PATH_SEPARATOR_STR) + name + std::string(".") + m_files[i].res.toString();
					nameFound = true;
				}
			}
			if (!nameFound)
			{
				path = outDir + std::string(PATH_SEPARATOR_STR) + filename;
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

std::string findFile(const std::vector<std::string>& inputDirs, Hash hash, ResType res)
{
	const std::string filename = hashToStr(hash) + "." + res.toString();
	for (size_t i = 0; i < inputDirs.size(); i++)
	{
		std::string path = inputDirs[i] + PATH_SEPARATOR_STR + filename;
		if(_access(path.c_str(), 0) == 0)
		{
			return path;
		}
	}
	return std::string();
}

bool PakArchive::rebuild(Consolgames::Stream* outStream, const std::vector<std::string>& inputDirs,
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
			std::string filename = findFile(inputDirs, files[i].hash, files[i].res);
			if (!filename.empty())
			{
				files[i].size = storeFile(filename, outStream, (files[i].packed != 0), (files[i].res == "TXTR"));
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
	int segmentCount = endian(m_segments.size());
	outStream->write(&segmentCount, 4);
	
	std::vector<SegmentRecord> segments(m_segments.size());
	for (size_t i = 0; i < m_segments.size(); i++)
	{
		segments[i].res = m_segments[i].res;
		segments[i].size = endian(m_segments[i].size);
	}
	segments[m_dataIndex].size = endian32(offset - m_dataOffset);
	outStream->write(&segments[0], segments.size() * sizeof(SegmentRecord)); 
								 
	outStream->seek(m_rshdOffset, Stream::seekSet);
	u32 fileCount = endian32(files.size());
	outStream->write(&fileCount, 4);
	
	std::for_each(files.begin(), files.end(), swapFileEndian);
	outStream->write(&files[0], files.size() * sizeof(FileRecord));

	m_stream->seek(m_strgOffset, Stream::seekSet);
	outStream->seek(m_strgOffset, Stream::seekSet);
	outStream->writeStream(m_stream, m_segments[m_strgIndex].size); 

	finishProgress();

	return true;
}

bool PakArchive::rebuild(const std::string& destName, const std::vector<std::string>& inputDirs, const std::set<ResType>& types, const std::map<Hash,Hash>& mergeMap)
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

bool PakArchive::opened() const
{
	return (m_stream != NULL);
}

PakArchive::PakArchive()
	: m_lzoWorkMem(65536)
	, m_stream(NULL)
	, m_progressHandler(NULL)
{
}

int PakArchive::fileCount() const
{
	return static_cast<int>(m_files.size());
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