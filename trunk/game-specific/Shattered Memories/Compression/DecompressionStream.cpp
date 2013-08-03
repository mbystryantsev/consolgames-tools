#include "DecompressionStream.h"

namespace ShatteredMemories
{

static const uint16 s_modifiedHeader = 0x9C78;

DecompressionStream::DecompressionStream(Consolgames::Stream* zlibStream, largesize_t size)
	: ZlibStream(zlibStream)
	, m_size(size)
{
	const int ret = inflateInit(&m_zStream);
	m_opened = (ret == Z_OK);
	ASSERT(m_opened);
}

largesize_t DecompressionStream::read(void* buf, largesize_t size)
{
	ASSERT(opened());

	if (!opened() || m_finished)
	{
		return 0;
	}

	m_zStream.avail_out = static_cast<uInt>(size);
	m_zStream.next_out = static_cast<Bytef*>(buf);
	while (m_zStream.avail_out > 0)
	{
		if (m_zStream.avail_in == 0)
		{
			m_zStream.avail_in = static_cast<uInt>(m_zlibStream->read(m_buf, s_chunkSize));
			if (m_zStream.total_in == 0)
			{
				// Fix header
				*reinterpret_cast<uint16*>(&m_buf[0]) = s_modifiedHeader;
			}
			if (m_zStream.avail_in == 0)
			{
				break;
			}
			m_zStream.next_in = m_buf;
		}

		const int ret = inflate(&m_zStream, Z_NO_FLUSH);
		if (ret == Z_STREAM_END)
		{
			inflateEnd(&m_zStream);
			m_finished = true;
			break;
		}
		ASSERT(ret == Z_OK);
	}

	return (size - m_zStream.avail_out);
}

largesize_t DecompressionStream::write(const void*, largesize_t)
{
	ASSERT(!"Not supported!");
	return -1;
}


offset_t DecompressionStream::size() const 
{
	return m_size;
}

bool DecompressionStream::opened() const 
{
	return m_zlibStream->opened();
}

bool DecompressionStream::atEnd() const 
{
	return m_finished;
}

void DecompressionStream::holdStream()
{
	ASSERT(m_streamHolder.get() == NULL);
	if (m_streamHolder.get() == NULL)
	{
		m_streamHolder.reset(m_zlibStream);
	}
}

}
