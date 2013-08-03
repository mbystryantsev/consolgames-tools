#pragma once
#include <FileSource.h>
#include <string>
#include <vector>

namespace ShatteredMemories
{

class DirectoriesFileSource : public FileSource
{
public:
	DirectoriesFileSource(const std::vector<std::wstring>& directories);

	virtual std::tr1::shared_ptr<Consolgames::Stream> file(uint32 hash, FileAccessor& accessor) override;
	virtual std::tr1::shared_ptr<Consolgames::Stream> fileByName(const std::string& name, FileAccessor& accessor) override;

private:
	static std::wstring filename(const std::wstring& path, uint32 hash, const std::wstring& ext = std::wstring());
	static std::tr1::shared_ptr<Consolgames::Stream> openFile(const std::wstring& path);

private:
	std::vector<std::wstring> m_directories;
};

}
