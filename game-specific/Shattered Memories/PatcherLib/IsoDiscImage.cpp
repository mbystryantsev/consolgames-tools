#include "IsoDiscImage.h"

using namespace Consolgames;

namespace ShatteredMemories
{

bool IsoDiscImage::open(const std::wstring& filename, Stream::OpenMode mode)
{
	m_discId.clear();
	if (!m_image.open(filename, mode))
	{
		return false;
	}
	
	const std::string id = loadDiscId();
	if (id.empty())
	{
		return false;
	}

	m_discId = id;
	return true;
}

bool IsoDiscImage::isOpen() const 
{
	return m_image.isOpen();
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

ProgressNotifier* IsoDiscImage::progressNotifier()
{
	return &m_notifier;
}

}
