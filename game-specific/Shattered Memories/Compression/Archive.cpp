#include "Archive.h"
#include "DecompressionStream.h"
#include "CompressionStream.h"
#include "DirectoriesFileSource.h"
#include <PartStream.h>
#include <FileStream.h>
#include <memory>

using namespace std;
using namespace tr1;
using namespace Consolgames;

LOG_CATEGORY("ShatteredMemories.Archive");

namespace ShatteredMemories
{

u32 Archive::FileRecord::originalSize() const
{
	return (decompressedSize == 0 ? storedSize : decompressedSize);
}

bool Archive::FileRecord::isPacked() const
{
	return (decompressedSize != 0);
}

static std::wstring strToWStr(const std::string& str)
{
	return std::wstring(str.begin(), str.end());
}

Archive::Archive(const std::string& filename)
	: m_opened(false)
	, m_alignment(0x800)
{
	m_fileStreamHolder.reset(new FileStream(strToWStr(filename), Stream::modeRead));
	m_stream = m_fileStreamHolder.get();
}

Archive::Archive(const wstring& filename)
	: m_opened(false)
{
	m_fileStreamHolder.reset(new FileStream(filename, Stream::modeRead));
	m_stream = m_fileStreamHolder.get();
}

Archive::Archive(Stream* stream)
	: m_stream(stream)
	, m_opened(false)
{
}

bool Archive::open()
{
	ASSERT(!m_opened);

	if (!m_stream->opened())
	{
		return false;
	}

	m_header.signature = m_stream->readInt();
	m_header.fileCount = m_stream->readInt();
	m_header.headerSize = m_stream->readInt();
	m_header.reserved = m_stream->readInt();
	
	ASSERT(m_header.fileCount > 0);
	m_fileRecords.resize(m_header.fileCount);
	m_fileRecordsMap.clear();

	for (vector<FileRecord>::iterator fileRecord = m_fileRecords.begin(); fileRecord != m_fileRecords.end(); fileRecord++)
	{
		fileRecord->hash = m_stream->readUInt();
		fileRecord->offset = m_stream->readUInt();
		fileRecord->storedSize = m_stream->readUInt();
		fileRecord->decompressedSize = m_stream->readUInt();
		m_fileRecordsMap[fileRecord->hash] = &(*fileRecord);

		if (fileRecord->offset % 0x800 != 0)
		{
			m_alignment = 0x20;
		}
	}

	m_opened = true;
	return true;
}

u32 Archive::calcHash(const char* str, u32 hash)
{
	const char* c = str;
	while (*c != '\0')
	{
		const u32 v = tolower(*c++);
		hash = ((hash << 5) + hash) ^ v;
	}
	return hash;
}

std::string Archive::hashToStr(u32 hash)
{
	char buf[32];
	_ultoa(hash, buf, 16);

	std::string result = buf;
	std::transform(result.begin(), result.end(), result.begin(), toupper);
	result.insert(0, 8 - result.length(), '0');
	return result;
}

bool Archive::extractFiles(const std::string& outDir, const std::set<u32>& fileList)
{
	return extractFiles(strToWStr(outDir), fileList);	
}

bool Archive::extractFiles(const std::wstring& outDir, const std::set<u32>& fileList)
{
	ASSERT(m_opened);
	if (!m_opened)
	{
		return false;
	}

	if (!FileStream::fileExists(outDir))
	{
		DLOG << "Directory does not exists: " << outDir;
		return false;
	}

	for (std::vector<FileRecord>::const_iterator record = m_fileRecords.begin(); record != m_fileRecords.end(); record++)
	{
		if (!fileList.empty() && (fileList.find(record->hash) == fileList.end()))
		{
			continue;
		}

		const std::string filename = (m_names.find(record->hash) == m_names.end() ? hashToStr(record->hash) : m_names[record->hash]);
		const std::wstring outFile = outDir + PATH_SEPARATOR_L + strToWStr(filename);
		if (!extractFile(*record, outFile))
		{
			return false;
		}
	}
	return true;
}

bool Archive::extractFile(const FileRecord& record, Consolgames::Stream* stream)
{
	VERIFY(m_stream->seek(record.offset, Stream::seekSet) == record.offset);

	DecompressionStream zlibStream(m_stream, record.decompressedSize);
	if (!zlibStream.opened())
	{
		DLOG << "Unable to open zlib stream!";
		return false;
	}

	const largesize_t unpacked = stream->writeStream(&zlibStream, record.decompressedSize);
	if (unpacked != record.decompressedSize)
	{
		DLOG << "Error occured during zlib stream unpacking!";
		return false;
	}

	return true;
}

bool Archive::extractFile(const FileRecord& record, const std::wstring& path)
{
	FileStream stream(path, Stream::modeWrite);
	if (!stream.opened())
	{
		DLOG << "Unable to open output file!";
		return false;
	}

	return extractFile(record, &stream);
}

void Archive::setNames(const std::list<std::string>& names)
{
	m_names.clear();
	for (std::list<std::string>::const_iterator name = names.begin(); name != names.end(); name++)
	{
		m_names[calcHash(name->c_str())] = *name;
	}
}

u32 Archive::alignSize(u32 size) const
{
	size += m_alignment - 1;
	return size - (size % m_alignment);
}

bool Archive::rebuild(const std::wstring& outFile, FileSource& fileSource)
{
	FileStream file(outFile, FileStream::modeWrite);
	if (!file.opened())
	{
		return false;
	}

	std::vector<FileRecord> entryList;
	entryList.reserve(m_fileRecords.size());

	const int recordSize = 16;
	const int headerSize = 16;
	const int magicMarkerSize = 16;
	u32 position = alignSize(m_fileRecords.size() * recordSize + headerSize + magicMarkerSize);
	for (std::vector<FileRecord>::const_iterator record = m_fileRecords.begin(); record != m_fileRecords.end(); record++)
	{
		FileRecord newRecord = *record;
		newRecord.offset = position;

		file.seek(position, Stream::seekSet);
		shared_ptr<Stream> stream = fileSource.file(record->hash, FileAccessor(m_stream, record->offset, record->originalSize(), record->isPacked()));
		if (stream.get() == NULL)
		{
			m_stream->seek(record->offset, Stream::seekSet);
			file.writeStream(m_stream, record->storedSize);
		}
		else
		{
			if (record->decompressedSize == 0)
			{
				newRecord.storedSize = static_cast<u32>(stream->size());
				newRecord.decompressedSize = 0;
				m_stream->seek(record->offset, Stream::seekSet);
				VERIFY(file.writeStream(stream.get(), record->decompressedSize) == record->decompressedSize);
			}
			else
			{
				CompressionStream zlibStream(&file);
				ASSERT(zlibStream.opened());
				VERIFY(zlibStream.writeStream(stream.get(), stream->size()) == stream->size());
				zlibStream.finish();
				newRecord.storedSize = static_cast<u32>(zlibStream.size());
				newRecord.decompressedSize = static_cast<u32>(stream->size());
			}
		}

		position = alignSize(position + newRecord.storedSize);
		entryList.push_back(newRecord);
	}

	if (file.size() != file.size() % m_alignment)
	{
		file.seek(alignSize(static_cast<u32>(file.size())) - 1, Stream::seekSet);
		file.write8(0);
	}

	file.seek(0, Stream::seekSet);
	file.write32(m_header.signature);
	file.write32(m_header.fileCount);
	file.write32(m_header.headerSize);
	file.write32(m_header.reserved);

	for (std::vector<FileRecord>::const_iterator record = entryList.begin(); record != entryList.end(); record++)
	{
		file.write32(record->hash);
		file.write32(record->offset);
		file.write32(record->storedSize);
		file.write32(record->decompressedSize);
	}

	const u32 magic = 0x340458;
	file.write32(magic);
	file.write32(magic);

	return true;
}

bool Archive::rebuild(const std::wstring& outFile, const std::vector<std::wstring>& dirList)
{
	return rebuild(outFile, DirectoriesFileSource(dirList));
}

shared_ptr<Stream> Archive::openFile(const std::string& filename)
{
	return openFile(calcHash(filename.c_str()));
}

shared_ptr<Stream> Archive::openFile(u32 fileHash)
{
	if (m_fileRecordsMap.find(fileHash) == m_fileRecordsMap.end())
	{
		return shared_ptr<Stream>();
	}

	const FileRecord& record = *m_fileRecordsMap[fileHash];
	return FileAccessor(m_stream, record.offset, record.originalSize(), record.isPacked()).open();
}

//////////////////////////////////////////////////////////////////////////

Archive::FileAccessor::FileAccessor(Stream* stream, u32 position, u32 size, bool packed)
	: m_stream(stream)
	, m_position(position)
	, m_size(size)
	, m_packed(packed)
{
}

shared_ptr<Stream> Archive::FileAccessor::open()
{
	if (m_fileStream.get() != NULL)
	{
		return m_fileStream;
	}

	auto_ptr<PartStream> pakStream(new PartStream(m_stream, m_position));
	ASSERT(pakStream->opened());

	VERIFY(pakStream->seek(0, Stream::seekSet) == 0);

	if (m_packed)
	{
		m_fileStream.reset(new DecompressionStream(pakStream.get(), m_size));
		pakStream.release();
		dynamic_cast<DecompressionStream*>(m_fileStream.get())->holdStream();
		return m_fileStream;
	}

	pakStream->setSize(m_size);
	m_fileStream.reset(pakStream.release());
	return m_fileStream;
}

}