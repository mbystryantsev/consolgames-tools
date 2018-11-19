#include "ZlibStream.h"
#include <algorithm>

namespace ShatteredMemories
{

ZlibStream::ZlibStream(Consolgames::Stream* zlibStream)
	: m_zlibStream(zlibStream)
	, m_opened(false)
	, m_finished(false)
{
	m_zStream.zalloc = Z_NULL;
	m_zStream.zfree = Z_NULL;
	m_zStream.opaque = Z_NULL;
	m_zStream.avail_in = 0;
	m_zStream.next_in = Z_NULL;
	m_zStream.avail_out = 0;
	m_zStream.next_out = Z_NULL;
}

offset_t ZlibStream::seek(offset_t offset, SeekOrigin origin)
{
	if (origin == seekCur)
	{
		offset += position();
	}
	else if (origin == seekEnd)
	{
		ASSERT(size() >= 0);
		if (size() < 0)
		{
			return -1;
		}
		offset += size();
	}

	ASSERT(offset >= position());
	if (offset < position())
	{
		return -1;
	}
	if (offset == position())
	{
		return offset;
	}

	return skip(offset - position()) + position();
}

offset_t ZlibStream::position() const 
{
	ASSERT(isOpen());
	
	return m_zStream.total_out;
}

void ZlibStream::flush()
{
}

largesize_t ZlibStream::skip(largesize_t size)
{
	uint8 buf[s_chunkSize];
	largesize_t skipped = 0;
	while (size > 0)
	{
		const int chunk = std::min<int>(s_chunkSize, static_cast<int>(size));
		size -= chunk;
		skipped += read(buf, chunk);
	}

	return skipped;
}

}
