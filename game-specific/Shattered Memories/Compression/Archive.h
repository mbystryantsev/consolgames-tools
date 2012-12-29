#pragma once
#include <memory>
#include <string>
#include <map>
#include <vector>

namespace Consolgames
{
class Stream;
}

namespace ShatteredMemories
{


class Archive
{
public:
	Archive(const std::wstring& filename);
	Archive(Consolgames::Stream* stream);
	bool open();

private:
	struct Header
	{
		int signature;
		int fileCount;
		int headerSize;
		int reserved;
	};

	struct FileRecord
	{
		u32 hash;
		u32 offset;
		u32 compressedSize;
		u32 decompressedSize;
	};

private:
	Consolgames::Stream* m_stream;
	std::auto_ptr<Consolgames::Stream> m_fileStreamHolder;
	std::vector<FileRecord> m_fileRecords;
	std::map<u32, const FileRecord*> m_fileRecordsMap;
	Header m_header;
	bool m_opened;
};

}
