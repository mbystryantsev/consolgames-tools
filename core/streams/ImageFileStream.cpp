#include "ImageFileStream.h"

#include <algorithm>

namespace Consolgames
{

ImageFileStream::ImageFileStream(Stream* stream, offset_t size, OpenMode mode)
	: m_stream(stream)
	, m_position(0)
	, m_fileSize(size)
	, m_mode(mode)
{
	m_imagePosition = m_stream->position();
}

ImageFileStream::ImageFileStream(Stream* stream, offset_t offset, offset_t size, OpenMode mode)
	: m_stream(stream)
	, m_position(0)
	, m_imagePosition(offset)
	, m_fileSize(size)
	, m_mode(mode)
{
}

largesize_t ImageFileStream::read(void* buf, largesize_t size)
{
	ASSERT(m_mode == modeRead || m_mode == modeReadWrite);

	offset_t position = m_stream->position();
	m_stream->seek(m_imagePosition + m_position, seekSet);
	offset_t count = m_stream->read(buf, std::min(size, m_fileSize - m_position));
	m_position += count;
	m_stream->seek(position, seekSet);
	return count;
}

largesize_t ImageFileStream::write(const void* buf, largesize_t size)
{
	ASSERT(m_mode == modeWrite || m_mode == modeReadWrite);

	largesize_t position = m_stream->position();
	m_stream->seek(m_imagePosition + m_position, seekSet);
	largesize_t count = m_stream->write(buf, size);
	m_position += count;
	m_stream->seek(position, seekSet);
	return count;
}

void ImageFileStream::flush()
{
	m_stream->flush();
}

bool ImageFileStream::isOpen() const
{
	return m_stream != NULL;
}

offset_t ImageFileStream::seek(offset_t offset, SeekOrigin origin)
{
	switch(origin)
	{
	case seekSet:
		m_position = offset;
		break;
	case seekCur:
		m_position += offset;
		break;
	case seekEnd:
		m_position = m_fileSize + offset;
		break;
	}
	return m_position;
}

offset_t ImageFileStream::position() const
{
	return m_position;
}

offset_t ImageFileStream::size() const
{
	return m_fileSize;
}

bool ImageFileStream::atEnd() const
{
	return isOpen() && m_position == m_fileSize;
}

}
