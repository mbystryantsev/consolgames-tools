#pragma once
#include <IFileSource.h>
#include <string>
#include <vector>

namespace ShatteredMemories
{

class DirectoriesFileSource : public IFileSource
{
public:
	DirectoriesFileSource(const std::vector<std::wstring>& directories);

	virtual std::tr1::shared_ptr<Consolgames::Stream> file(u32 hash) override;

private:
	static std::wstring filename(const std::wstring& path, u32 hash, const std::wstring& ext = std::wstring());
	static std::tr1::shared_ptr<Consolgames::Stream> openFile(const std::wstring& path);

private:
	std::vector<std::wstring> m_directories;
};

}
