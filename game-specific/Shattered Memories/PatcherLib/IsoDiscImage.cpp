#include "IsoDiscImage.h"
#include <QTextStream>
#include <QStringList>
#include <QFileInfo>

using namespace Consolgames;

namespace ShatteredMemories
{

bool IsoDiscImage::open(const std::wstring& filename, Stream::OpenMode mode)
{
	m_discId.clear();
	const bool success = m_image.open(filename, mode);
	if (success)
	{
		loadDiscId();
	}
	return success;
}

bool IsoDiscImage::opened() const 
{
	return m_image.opened();
}

void IsoDiscImage::close()
{
	return m_image.close();
}

Consolgames::Stream* IsoDiscImage::openFile(const std::string& filename, Consolgames::Stream::OpenMode mode)
{
	Q_UNUSED(mode);
	return m_image.openFile(filename.c_str());
}

bool IsoDiscImage::writeData(offset_t offset, Consolgames::Stream* stream, largesize_t size)
{
	Stream* file = m_image.file();
	if (file->seek(offset, Stream::seekSet) != offset)
	{
		return false;
	}
	return (file->writeStream(stream, size) == size);
}

DiscImage::FileInfo IsoDiscImage::findFile(const std::string& filename)
{
	FileInfo result;
	const IsoFileDescriptor descriptor = m_image.findFile(filename.c_str());

	if (!descriptor.isNull() && descriptor.isFile())
	{
		result.offset = descriptor.lba * 2048;
		result.size = descriptor.size;
	}

	return result;
}

std::string IsoDiscImage::discId() const 
{
	return m_discId;
}

bool IsoDiscImage::checkImage()
{
	return true;
}

std::string IsoDiscImage::lastErrorData() const 
{
	return std::string();
}

void IsoDiscImage::loadDiscId()
{
	// Custom built or patched discs often do not save
	// game id in system sectors, so we should extract
	// the id from the SYSTEM.CNF file.

	IsoFileDescriptor d = m_image.findFile("SYSTEM.CNF");
	if (d.isNull() || !d.isFile())
	{
		return;
	}

	std::auto_ptr<Stream> file(m_image.openFile("SYSTEM.CNF"));
	if (file.get() == NULL || !file->opened() || file->size() > 1024)
	{
		return;
	}

	QByteArray content(file->size(), Qt::Uninitialized);
	file->read(content.data(), content.size());

	QTextStream stream(&content, QIODevice::ReadOnly);
	while (!stream.atEnd())
	{
		const QString line = stream.readLine().simplified();
		const QStringList parts = line.split('=', QString::SkipEmptyParts);
		if (parts.size() != 2)
		{
			continue;
		}

		if (parts.first().trimmed() == "BOOT2")
		{
			QString executableName = QFileInfo(parts.last().split(';').first().trimmed()).fileName();
			m_discId = executableName.remove('.').toStdString();
			break;
		}
	}
}

ProgressNotifier* IsoDiscImage::progressNotifier()
{
	return &m_notifier;
}

}
