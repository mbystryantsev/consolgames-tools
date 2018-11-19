#pragma once
#include <FileSource.h>
#include <string>
#include <vector>
#include <map>

namespace ShatteredMemories
{

class DirectoriesFileSource : public FileSource
{
public:
	DirectoriesFileSource(const std::vector<std::wstring>& directories);

	virtual std::shared_ptr<Consolgames::Stream> file(uint32 hash, FileAccessor& accessor) override;
	virtual std::shared_ptr<Consolgames::Stream> fileByName(const std::string& name, FileAccessor& accessor) override;

private:
	static std::shared_ptr<Consolgames::Stream> openFile(const std::wstring& path);

private:
	std::vector<std::wstring> m_directories;
};

}
