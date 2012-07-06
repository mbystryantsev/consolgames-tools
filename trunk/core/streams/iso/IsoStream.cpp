#include "IsoStream.h"
#include "FileStream.h"

#ifndef __BORLANDC__
#   include <fcntl.h>
#endif

namespace Consolgames
{

IsoStream::IsoStream(const char* filename, OpenMode mode)
{
    m_stream.reset(new FileStream(filename, mode));
    
	if (m_stream->opened())
    {
        m_imageSize = m_stream->size();
        m_lbaCount = static_cast<int>(m_imageSize / 2048);
        m_isoDirectory.reset(new IsoDirectory(*this));
    }
    else
    {
        m_imageSize = 0;
        m_lbaCount = 0;
    }
}

IsoStream::~IsoStream()
{
}

bool IsoStream::readSector(void* buffer, int lba)
{
    if(lba >= m_lbaCount)
	{
		return false;
	}
    largesize_t readed = m_stream->read(buffer, 2048);
    return (readed == 2048);
}

bool IsoStream::seekToFile(const char *filename)
{
    IsoFileDescriptor info;
    if(!m_isoDirectory->findFile(filename, info))
    {
        return false;
    }
    seek(info.lba * 2048, seekSet);
    return true;
}


int IsoStream::sectorCount() const
{
	return m_lbaCount;
}

ImageFileStream* IsoStream::findFile(const char* filename)
{
    IsoFileDescriptor info;
    if(!m_isoDirectory->findFile(filename, info))
    {
        return NULL;
    }
    return new ImageFileStream(this, static_cast<offset_t>(info.lba) * 2048ULL, info.size);
}

offset_t IsoStream::seek(offset_t offset, SeekOrigin origin)
{
    return m_stream->seek(offset, origin);
}

largesize_t IsoStream::read(void *buf, largesize_t size)
{
    return m_stream->read(buf, size);
}

offset_t IsoStream::tell() const
{
    return m_stream->tell();
}

void IsoStream::flush()
{
    m_stream->flush();
}

largesize_t IsoStream::write(const void* buf, largesize_t size)
{
    return m_stream->write(buf, size);
}

bool IsoStream::opened() const
{
	return m_stream.get() != NULL;
}

largesize_t IsoStream::size() const
{
	return m_imageSize;
}

}


