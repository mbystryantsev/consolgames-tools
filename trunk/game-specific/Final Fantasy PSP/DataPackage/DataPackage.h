#pragma once
#include <DataPackageTypes.h>
#include <vector>
#include <fstream>

typedef std::vector<FileRecord> FileList;

class DataPackage
{
public:
	enum OpenMode
	{
		ReadOnly,
		ReadWrite
	};

	bool open(const std::string& filename, OpenMode mode);
	const FileList& files() const;
	int fileCount() const;
	void seekTo(const FileRecord& fileRecord);
	void readRaw(void* data, int size);
protected:
	std::fstream m_packageFile;
	FileList m_files;
};
