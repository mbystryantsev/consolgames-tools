#pragma once
#include <DataPackage.h>

typedef std::vector<FileRecord> FileList;

class PackageArchiver
{
public:
	bool open(const std::string& filename);
	const FileList& files() const;
	int fileCount() const;
	
protected:

	FileList m_files;
};
