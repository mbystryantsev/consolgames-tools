#include "PartStream.h"

namespace Consolgames
{

PartStream::PartStream(Stream* stream, offset_t position, largesize_t size)
	: m_stream(stream)
	, m_position(position)
	, m_size(size)
{
}

largesize_t PartStream::size() const
{
	if (m_size != -1)
	{
		return m_size;
	}
	return (m_stream->size() - m_position);
}

offset_t PartStream::seek(offset_t offset, SeekOrigin origin)
{
	if (origin == seekSet)
	{
		return m_stream->seek(offset + m_position, origin) - m_position;
	}
	if (origin == seekEnd)
	{
		return m_stream->seek(m_position + size() + offset, seekSet);
	}

	offset = min(offset, size() - position());
	return m_stream->seek(offset, origin);
}

void PartStream::setSize(largesize_t size)
{
	m_size = size;
}

largesize_t PartStream::read(void* buf, largesize_t size)
{
	size = min(m_size - position(), size);
	return m_stream->read(buf, size);
}

largesize_t PartStream::write(const void* buf, largesize_t size)
{
	size = min(m_size - position(), size);
	return m_stream->write(buf, size);
}

offset_t PartStream::position() const
{
	return m_stream->position() - m_position;
}

void PartStream::flush() 
{
	m_stream->flush();
}

bool PartStream::atEnd() const 
{
	return (m_stream->position() == m_position + m_size);
}

}
