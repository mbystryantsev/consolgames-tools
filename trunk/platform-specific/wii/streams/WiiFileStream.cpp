#include "WiiFileStream.h"
#include "MemoryStream.h"
#include <WiiImage.h>

namespace Consolgames
{
	
WiiFileStream::WiiFileStream(WiiImage& image, int partition, offset_t offset, largesize_t size)
	: m_image(image)
	, m_partition(partition)
	, m_offset(offset)
	, m_size(size)
	, m_position(0)
{
}

largesize_t WiiFileStream::read(void* buf, largesize_t size)
{
	size = min(size, m_size - m_position);
	largesize_t result = m_image.io_read_part(buf, size, m_partition, m_offset + m_position);
	m_position += result;
	return result;
}

largesize_t WiiFileStream::write(const void* buf, largesize_t size)
{
	size = min(m_size - m_position, size);
	return m_image.wii_write_data(m_partition, m_offset + m_position, &MemoryStream(buf, static_cast<ptrdiff_t>(size)), size) ? size : 0;
}

offset_t WiiFileStream::seek(offset_t offset, Stream::SeekOrigin origin)
{
	switch (origin)
	{
		case seekSet:
			if (offset >= 0 && offset <= m_size)
			{
				m_position = offset;
			}
			break;
		case seekCur:
			if (m_position + offset <= m_size)
			{
				m_position = m_position + offset;
			}
			break;
		case seekEnd:
			if (-offset <= m_size)
			{
				m_position = m_offset + m_size + offset;
			}
			break;
	}
	return m_position;
}

offset_t WiiFileStream::position() const 
{
	return m_position;
}

void WiiFileStream::flush()
{
}

offset_t WiiFileStream::size() const 
{
	return m_size;
}

largesize_t WiiFileStream::writeStream(Stream *stream, largesize_t size)
{
	return m_image.wii_write_data(m_partition, m_offset + m_position, stream, size) ? size : 0;
}

offset_t WiiFileStream::offset() const
{
	return m_offset;
}

bool WiiFileStream::atEnd() const 
{
	return (position() == size());
}

}
