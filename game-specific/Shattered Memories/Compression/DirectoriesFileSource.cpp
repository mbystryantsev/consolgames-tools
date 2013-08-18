#include "DirectoriesFileSource.h"
#include "FileStream.h"
#include "Hash.h"

using namespace Consolgames;
using namespace std;
using namespace tr1;

namespace ShatteredMemories
{

static std::wstring filename(const std::wstring& path, const std::string& name)
{
	return path + PATH_SEPARATOR_L + wstring(name.begin(), name.end());
}

static wstring filename(const wstring& path, uint32 hash, const std::string& ext = std::string())
{
	return filename(path, Hash::toString(hash) + ext);
}

DirectoriesFileSource::DirectoriesFileSource(const vector<wstring>& directories)
	: m_directories(directories)
{
}

shared_ptr<Stream> DirectoriesFileSource::file(uint32 hash, FileAccessor&)
{
	for (vector<wstring>::const_iterator dir = m_directories.begin(); dir != m_directories.end(); dir++)
	{
		{
			shared_ptr<Stream> stream = openFile(filename(*dir, hash, ".BIN"));
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

shared_ptr<Stream> DirectoriesFileSource::fileByName(const string& name, FileAccessor& accessor)
{
	const wstring wname(name.begin(), name.end());
	for (vector<wstring>::const_iterator dir = m_directories.begin(); dir != m_directories.end(); dir++)
	{
		{
			shared_ptr<Stream> stream = openFile(*dir + PATH_SEPARATOR_L + wname);
			if (stream.get() != NULL)
			{
				return stream;
			}
		}
	}
	return file(Hash::calc(name.c_str()), accessor);
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
