#include "CompressionStream.h"

namespace ShatteredMemories
{

static const u16 s_modifiedHeader = 0xDA78;

CompressionStream::CompressionStream(Consolgames::Stream* zlibStream, int compressionLevel)
	: ZlibStream(zlibStream)
{
	const int ret = deflateInit(&m_zStream, compressionLevel);
	m_opened = (ret == Z_OK);
	ASSERT(m_opened);
}

largesize_t CompressionStream::read(void*, largesize_t)
{
	ASSERT(!"Not supported!");
	return -1;
}

largesize_t CompressionStream::write(const void* buf, largesize_t size)
{
	ASSERT(opened());

	if (!opened() || m_finished)
	{
		return 0;
	}

	m_zStream.avail_in = static_cast<uInt>(size);
	m_zStream.next_in = static_cast<Bytef*>(const_cast<void*>(buf));
	while (m_zStream.avail_in > 0)
	{
		if (m_zStream.avail_out == 0)
		{
			m_zStream.avail_out = s_chunkSize;
			m_zStream.next_out = m_buf;
		}

		const bool firstPass = (m_zStream.total_out == 0);
		const uInt lastAvailOut = m_zStream.avail_out;
		const int ret = deflate(&m_zStream, Z_NO_FLUSH);
		ASSERT(ret == Z_OK);
		if (ret != Z_OK)
		{
			return 0;
		}

		if (firstPass)
		{
			// Fix header
			ASSERT(m_zStream.total_out >= sizeof(s_modifiedHeader));
			*reinterpret_cast<u16*>(&m_buf[0]) = s_modifiedHeader;
		}

		const uInt outSize = lastAvailOut - m_zStream.avail_out;
		const int bufPosition = s_chunkSize - lastAvailOut;
		m_zlibStream->write(&m_buf[bufPosition], outSize);
	}

	return size;
}

offset_t CompressionStream::size() const 
{
	return (m_opened || m_finished) ? m_zStream.total_out : -1;
}

bool CompressionStream::opened() const 
{
	return m_zlibStream->opened();
}

bool CompressionStream::atEnd() const 
{
	return m_zlibStream->atEnd();
}

void CompressionStream::finish()
{
	if (m_finished)
	{
		return;
	}

	m_zStream.avail_in = 0;
	m_zStream.next_in = Z_NULL;
	while (true)
	{
		if (m_zStream.avail_out == 0)
		{
			m_zStream.avail_out = s_chunkSize;
			m_zStream.next_out = m_buf;
		}

		const uInt lastAvailOut = m_zStream.avail_out;
		const int ret = deflate(&m_zStream, Z_FINISH);
		ASSERT(ret == Z_OK || ret == Z_STREAM_END);

		const uInt outSize = lastAvailOut - m_zStream.avail_out;
		const int bufPosition = s_chunkSize - lastAvailOut;
		m_zlibStream->write(&m_buf[bufPosition], outSize);

		if (ret == Z_STREAM_END)
		{
			break;
		}
	}
	deflateEnd(&m_zStream);
	m_finished = true;
}

CompressionStream::~CompressionStream()
{
	finish();
}

largesize_t CompressionStream::processedSize() const
{
	return m_zStream.total_in;
}

}
