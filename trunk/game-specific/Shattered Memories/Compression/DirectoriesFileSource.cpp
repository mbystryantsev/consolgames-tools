#include "DirectoriesFileSource.h"
#include "FileStream.h"
#include "Archive.h"

using namespace Consolgames;
using namespace std;
using namespace tr1;

namespace ShatteredMemories
{

DirectoriesFileSource::DirectoriesFileSource(const std::vector<std::wstring>& directories)
	: m_directories(directories)
{
}

shared_ptr<Stream> DirectoriesFileSource::file(u32 hash)
{
	for (vector<wstring>::const_iterator dir = m_directories.begin(); dir != m_directories.end(); dir++)
	{
		{
			shared_ptr<Stream> stream = openFile(filename(*dir, hash, L".BIN"));
			if (stream.get() != NULL)
			{
				return stream;
			}
		}
		{
			shared_ptr<Stream> stream = openFile(filename(*dir, hash));
			if (stream.get() != NULL)
			{
				return stream;
			}
		}
	}
	return shared_ptr<Stream>();
}

wstring DirectoriesFileSource::filename(const wstring& path, u32 hash, const wstring& ext)
{
	const string hashStr = Archive::hashToStr(hash);
	return path + PATH_SEPARATOR_L + wstring(hashStr.begin(), hashStr.end()) + ext;
}

shared_ptr<Consolgames::Stream> DirectoriesFileSource::openFile(const std::wstring& path)
{
	if (FileStream::fileExists(path))
	{
		shared_ptr<Stream> streamPtr(new FileStream(path, Stream::modeRead));
		if (streamPtr->opened())
		{
			return streamPtr;
		}
	}
	return shared_ptr<Stream>();
}

}
