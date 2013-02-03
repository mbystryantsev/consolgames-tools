#include "Archive.h"
#include "DecompressionStream.h"
#include "CompressionStream.h"
#include <FileStream.h>

using namespace std;
using namespace Consolgames;

LOG_CATEGORY("ShatteredMemories.Archive");

namespace ShatteredMemories
{

static std::wstring strToWStr(const std::string& str)
{
	return std::wstring(str.begin(), str.end());
}

Archive::Archive(const std::string& filename)
	: m_opened(false)
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
		fileRecord->compressedSize = m_stream->readUInt();
		fileRecord->decompressedSize = m_stream->readUInt();
		m_fileRecordsMap[fileRecord->hash] = &(*fileRecord);
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

}