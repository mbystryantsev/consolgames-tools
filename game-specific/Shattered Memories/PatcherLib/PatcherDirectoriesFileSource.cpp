#include "PatcherDirectoriesFileSource.h"
#include <QtFileStream.h>
#include <Hash.h>
#include <QFileInfo>

using namespace Consolgames;
using namespace std;

namespace ShatteredMemories
{

PatcherDirectoriesFileSource::PatcherDirectoriesFileSource(const QStringList& directories)
{
	m_directories.reserve(directories.size());
	foreach (const QString& path, directories)
	{
		m_directories.append(QDir(path));
	}
}

shared_ptr<Stream> PatcherDirectoriesFileSource::file(uint32 hash, FileAccessor& accessor)
{
	return fileByName(Hash::toString(hash), accessor);
}

shared_ptr<Stream> PatcherDirectoriesFileSource::fileByName(const string& name, FileAccessor&)
{
	const QString filename = QString::fromStdString(name);

	foreach (const QDir& dir, m_directories)
	{
		if (!dir.exists(filename))
		{
			continue;
		}

		shared_ptr<Stream> stream(new QtFileStream(dir.absoluteFilePath(filename), QIODevice::ReadOnly));
		if (stream.get() != NULL)
		{
			DLOG << "Found file for replacing: " << name;
			return stream;
		}
	}
	return shared_ptr<Stream>();
}

}
