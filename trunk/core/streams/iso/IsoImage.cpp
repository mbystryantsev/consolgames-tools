#include "IsoImage.h"
#include <FileStream.h>
#include <PartStream.h>

namespace Consolgames
{

enum
{
	c_sectorSize = 2048
};

IsoImage::IsoImage()
	: m_stream(NULL)
{
}

bool IsoImage::open(const std::wstring& filename, Stream::OpenMode mode)
{
	m_streamHolder.reset(new FileStream(filename, mode));
	m_stream = m_streamHolder.get();
	if (!m_stream->opened())
	{
		close();
		return false;
	}

	m_rootDirectory.reset(new IsoDirectory(*this));
	return true;
}

bool IsoImage::opened() const
{
	return (m_stream != NULL && m_stream->opened());
}

void IsoImage::close()
{
	m_stream = NULL;
	m_streamHolder.reset();
}

largesize_t IsoImage::size() const
{
	return m_stream->size();
}

int IsoImage::sectorCount() const
{
	return static_cast<int>(size() / c_sectorSize);
}

bool IsoImage::readSector(unsigned char* buffer, int lba)
{
	if (lba >= sectorCount())
	{
		return false;
	}

	if (m_stream->seek(lba * c_sectorSize, Stream::seekSet) != lba * c_sectorSize)
	{
		return false;
	}

	const largesize_t readed = m_stream->read(buffer, c_sectorSize);
	return (readed == c_sectorSize);
}

bool IsoImage::seekToFile(const char *filename)
{
	const IsoFileDescriptor info = m_rootDirectory->findFile(filename);

	if (info.isNull())
	{
		return false;
	}

	m_stream->seek(info.lba * c_sectorSize, Stream::seekSet);

	return true;
}

Consolgames::IsoFileDescriptor IsoImage::findFile(const char* filename) const
{
	return m_rootDirectory->findFile(filename);
}

Stream* IsoImage::openFile(const char* filename)
{
	const IsoFileDescriptor info = findFile(filename);

	if (info.isNull())
	{
		return NULL;
	}

	m_stream->seek(info.lba * 2048, Stream::seekSet);
	return new PartStream(m_stream, info.lba * 2048, info.size);
}

Stream* IsoImage::file()
{
	return m_stream;
}

}


