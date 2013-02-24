#pragma once
#include "FileSource.h"
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
	class FileAccessor: public FileSource::FileAccessor
	{
	friend class Archive;
	public:
		virtual std::tr1::shared_ptr<Consolgames::Stream> open() override;

	private:
		FileAccessor(Consolgames::Stream* stream, u32 position, u32 size, bool packed);

	private:
		Consolgames::Stream* m_stream;
		std::tr1::shared_ptr<Consolgames::Stream> m_fileStream;
		u32 m_position;
		u32 m_size;
		bool m_packed;
	};

public:
	Archive(const std::string& filename);
	Archive(const std::wstring& filename);
	Archive(Consolgames::Stream* stream);
	bool open();

	bool extractFiles(const std::string& outDir, const std::set<u32>& fileList = std::set<u32>());
	bool extractFiles(const std::wstring& outDir, const std::set<u32>& fileList = std::set<u32>());
	bool rebuild(const std::wstring& outFile, FileSource& fileSource);
	bool rebuild(const std::wstring& outFile, const std::vector<std::wstring>& dirList);
	std::tr1::shared_ptr<Consolgames::Stream> openFile(const std::string& filename);
	std::tr1::shared_ptr<Consolgames::Stream> openFile(u32 fileHash);

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
		u32 storedSize;
		u32 decompressedSize;

		u32 originalSize() const;
		bool isPacked() const;
	};

private:
	bool extractFile(const FileRecord& record, Consolgames::Stream* stream);
	bool extractFile(const FileRecord& record, const std::wstring& path);
	u32 alignSize(u32 size) const;

private:
	Consolgames::Stream* m_stream;
	std::auto_ptr<Consolgames::Stream> m_fileStreamHolder;
	std::vector<FileRecord> m_fileRecords;
	std::map<u32, const FileRecord*> m_fileRecordsMap;
	Header m_header;
	bool m_opened;
	std::map<u32, std::string> m_names;
	u32 m_alignment;
	static const u32 s_defaultAlignment;
};

}
