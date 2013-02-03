#pragma once
#include <Stream.h>
#include <memory>
#include <string>
#include <map>
#include <vector>
#include <set>
#include <list>

namespace Consolgames
{
class Stream;
}

namespace ShatteredMemories
{


class Archive
{
public:
	Archive(const std::string& filename);
	Archive(const std::wstring& filename);
	Archive(Consolgames::Stream* stream);
	bool open();

	bool extractFiles(const std::string& outDir, const std::set<u32>& fileList = std::set<u32>());
	bool extractFiles(const std::wstring& outDir, const std::set<u32>& fileList = std::set<u32>());

	void setNames(const std::list<std::string>& names);

	static u32 calcHash(const char* str, u32 hash = 0);
	static std::string hashToStr(u32 hash);

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
	bool extractFile(const FileRecord& record, Consolgames::Stream* stream);
	bool extractFile(const FileRecord& record, const std::wstring& path);

private:
	Consolgames::Stream* m_stream;
	std::auto_ptr<Consolgames::Stream> m_fileStreamHolder;
	std::vector<FileRecord> m_fileRecords;
	std::map<u32, const FileRecord*> m_fileRecordsMap;
	Header m_header;
	bool m_opened;
	std::map<u32, std::string> m_names;
};

}
