#include "Archive.h"
#include <FileStream.h>

using namespace std;
using namespace Consolgames;

namespace ShatteredMemories
{

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

}