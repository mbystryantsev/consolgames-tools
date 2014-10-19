#pragma once
#include <string>
#include <map>
#include "Common.h"

class CDStream;

class ISO9660FS
{
public:
	struct FileInfo
	{
		std::string name;
		uint32_t lba;
		uint32_t size;
	};

	struct DirectoryInfo
	{
		std::string name;
		std::map<std::string, DirectoryInfo> subdirs;
		std::map<std::string, FileInfo> files;
	};

public:
	static ISO9660FS fromImage(CDStream& stream);
	bool isNull() const;
	const DirectoryInfo& rootDirectory() const;
	const FileInfo findFile(const char* path) const;

private:
	DirectoryInfo m_rootDir;
};