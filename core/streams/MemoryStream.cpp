#include "MemoryStream.h"

namespace Consolgames
{

MemoryStream::MemoryStream()
	: m_buffer(BLOCK_SIZE)
	, m_externalPointer(false)
	, m_bufferSize(BLOCK_SIZE)
	, m_size(0)
	, m_position(0)
{
	m_memory = &m_buffer[0];
}

MemoryStream::MemoryStream(const void* data, size_t size)
	: m_bufferSize(size)
	, m_size(size)
	, m_mode(modeRead)
	, m_constMemory(reinterpret_cast<const u8*>(data))
	, m_externalPointer(true)
	, m_position(0)
{
	ASSERT(m_constMemory);
}

largesize_t MemoryStream::read(void* buf, largesize_t size)
{
    if (m_position >= m_size) 
	{
		return 0;
	}
    if (size > m_size - m_position)
	{
		size = m_size - m_position;
	}

    memcpy(buf, &m_constMemory[static_cast<size_t>(m_position)], static_cast<size_t>(size));
    
	m_position += size;

    return size;
}

largesize_t MemoryStream::write(const void* buf, largesize_t size)
{
	ASSERT(m_mode == modeWrite || m_mode == modeReadWrite);

    largesize_t preparedSize;

	if (m_externalPointer)
	{
        preparedSize = m_size - m_position;
        if (preparedSize > size) 
		{
			preparedSize = size;
		}
    }
	else
	{
        largesize_t pos = m_position + size;
        if (pos >= m_bufferSize)
		{
            m_bufferSize = ((pos + BLOCK_SIZE) / BLOCK_SIZE) * BLOCK_SIZE;
            m_buffer.reserve(static_cast<size_t>(m_bufferSize));
        }
        preparedSize = size;
    }

    memcpy(&m_memory[static_cast<size_t>(m_position)], buf, static_cast<size_t>(preparedSize));
    m_position += preparedSize;
    if (m_size < m_position)
	{
		m_size = m_position;
	}
    return preparedSize;
}

offset_t MemoryStream::seek(offset_t offset, SeekOrigin origin)
{
	switch(origin)
	{
	case seekSet:
		break;              
	case seekCur:
		offset += m_position;      
		break;
	case seekEnd:
		offset += m_size;
		break;
	default:
		ASSERT(!"Invalid seek origin");
	}
	ASSERT(offset > 0);
	m_position = offset;
	return offset;
}

offset_t MemoryStream::tell() const
{
	return m_position;
}

void MemoryStream::flush()
{
}

offset_t MemoryStream::size() const
{
	return m_size;
}

}
