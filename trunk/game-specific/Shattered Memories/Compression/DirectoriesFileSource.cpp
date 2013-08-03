#include "DirectoriesFileSource.h"
#include "FileStream.h"
#include "Hash.h"

using namespace Consolgames;
using namespace std;
using namespace tr1;

namespace ShatteredMemories
{

DirectoriesFileSource::DirectoriesFileSource(const vector<wstring>& directories)
	: m_directories(directories)
{
}

shared_ptr<Stream> DirectoriesFileSource::file(uint32 hash, FileAccessor&)
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

wstring DirectoriesFileSource::filename(const wstring& path, uint32 hash, const wstring& ext)
{
	const string hashStr = Hash::toString(hash);
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
