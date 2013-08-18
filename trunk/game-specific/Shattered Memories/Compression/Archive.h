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
	friend class FileAccessor;

private:
	struct FileRecord
	{
		uint32 hash;
		uint32 offset;
		uint32 storedSize;
		uint32 decompressedSize;

		uint32 originalSize() const;
		bool isPacked() const;

		bool operator == (const FileRecord& other) const
		{
			return hash == other.hash
				&& offset == other.offset
				&& storedSize == other.storedSize
				&& decompressedSize == other.decompressedSize;
		}
	};

public:
	class FileAccessor: public FileSource::FileAccessor
	{
	friend class Archive;
	public:
		virtual std::tr1::shared_ptr<Consolgames::Stream> open() override;

	private:
		FileAccessor(Consolgames::Stream* stream, const Archive::FileRecord& record);

	private:
		Consolgames::Stream* m_stream;
		std::tr1::shared_ptr<Consolgames::Stream> m_fileStream;
		const Archive::FileRecord m_record;
	};

	class IProgressListener
	{
	public:
		virtual void startProgress(int maxValue) = 0;
		virtual void progress(int value, const std::string& name) = 0;
		virtual void finishProgress() = 0;
		virtual bool stopRequested() = 0;
	};

	typedef std::map<uint32, uint32> MergeMap;

	struct FileInfo
	{
		FileInfo()
			: index(0)
			, offset(0)
			, size(0)
			, packed(false)
		{
		}

		int index;
		uint32 offset;
		uint32 size;
		bool packed;
	};

public:
	Archive(const std::string& filename);
	Archive(const std::wstring& filename);
	Archive(Consolgames::Stream* stream);
	bool open();

	bool extractFiles(const std::string& outDir, const std::set<uint32>& fileList = std::set<uint32>());
	bool extractFiles(const std::wstring& outDir, const std::set<uint32>& fileList = std::set<uint32>());
	bool rebuild(const std::wstring& outFile, FileSource& fileSource, const MergeMap& mergeMap = MergeMap());
	bool rebuild(const std::wstring& outFile, const std::vector<std::wstring>& dirList, const MergeMap& mergeMap = MergeMap());
	std::tr1::shared_ptr<Consolgames::Stream> openFile(const std::string& filename);
	std::tr1::shared_ptr<Consolgames::Stream> openFile(uint32 fileHash);

	void setNames(const std::list<std::string>& names);

	void addProgressListener(IProgressListener* listener);

	uint32 alignment() const;
	FileInfo fileInfo(uint32 hash) const;
	FileInfo fileInfo(const std::string& filename) const;

private:
	struct Header
	{
		int signature;
		int fileCount;
		int headerSize;
		union
		{
			int reserved;
			int namesPosition;
		};
		int namesSize;
	};

	class ProgressGuard
	{
	public:
		ProgressGuard(Archive& archive, int size);
		~ProgressGuard();

	private:
		Archive& m_archive;
	};


private:
	bool extractFile(const FileRecord& record, Consolgames::Stream* stream);
	bool extractFile(const FileRecord& record, const std::wstring& path);
	uint32 alignSize(uint32 size) const;

	void notifyProgressStart(int size);
	void notifyProgress(int progress, const std::string& name);
	void notifyProgressEnd();
	bool stopRequested();

private:
	Consolgames::Stream* m_stream;
	std::auto_ptr<Consolgames::Stream> m_fileStreamHolder;
	std::vector<FileRecord> m_fileRecords;
	std::map<uint32, const FileRecord*> m_fileRecordsMap;
	Header m_header;
	uint32 m_magicMarker1;
	uint32 m_magicMarker2;
	bool m_opened;
	std::map<uint32, std::string> m_names;
	uint32 m_alignment;
	std::list<IProgressListener*> m_progressListeners;
	bool m_originsMode;

	static const uint32 s_defaultAlignment;
};

}
