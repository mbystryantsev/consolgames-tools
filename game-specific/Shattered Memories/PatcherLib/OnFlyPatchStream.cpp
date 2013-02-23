#include "OnFlyPatchStream.h"

using namespace Consolgames;
using namespace std;
using namespace tr1;

namespace ShatteredMemories
{

OnFlyPatchStream::OnFlyPatchStream(shared_ptr<Stream> stream, shared_ptr<DataSource> dataSource)
	: m_stream(stream)
	, m_patchDataSource(dataSource)
	, m_currentPartIndex(0)
{
}

largesize_t OnFlyPatchStream::read(void* buf, largesize_t size)
{
	u8* data = static_cast<u8*>(buf);
	largesize_t totalReaded = 0;
	while (size > 0 && !m_stream->atEnd())
	{
		largesize_t readed = 0;
		if (m_currentPartIndex < m_patchDataSource->partCount() && m_currentPartInfo.isNull())
		{
			m_currentPartInfo = m_patchDataSource->partInfoAt(m_currentPartIndex);
		}
		if (m_currentPartInfo.isNull() || position() < m_currentPartInfo.offset)
		{
			const int availableSize = m_currentPartInfo.isNull() ? size : min(size, m_currentPartInfo.offset - position());
			readed = m_stream->read(data, availableSize);
		}
		else if (m_currentPartIndex < m_patchDataSource->partCount())
		{
			if (m_currentPartInfo.offset == position())
			{
				m_currentPartStream = m_patchDataSource->getAt(m_currentPartIndex);
			}
			if (position() >= m_currentPartInfo.offset && position() < m_currentPartInfo.offset + m_currentPartInfo.size)
			{
				const int availableSize = min(size, m_currentPartInfo.offset + m_currentPartInfo.size - position());		
				readed = m_currentPartStream->read(data, availableSize);
				m_stream->skip(availableSize);
			}
			if (position() == m_currentPartInfo.offset + m_currentPartInfo.size)
			{
				m_currentPartIndex++;
				m_currentPartInfo = (m_currentPartIndex >= m_patchDataSource->partCount() ? PartInfo() : m_patchDataSource->partInfoAt(m_currentPartIndex));
			}
		}
		data += readed;
		size -= readed;
		totalReaded += readed;
	}
	return totalReaded;
}

largesize_t OnFlyPatchStream::write(const void*, largesize_t)
{
	ASSERT("!Not supported!");
	return 0;
}

offset_t OnFlyPatchStream::seek(offset_t, SeekOrigin)
{
	ASSERT(!"Not supported");
	return position();
}

offset_t OnFlyPatchStream::position() const 
{
	return m_stream->position();
}

void OnFlyPatchStream::flush()
{
	// Not supported
}

offset_t OnFlyPatchStream::size() const 
{
	return m_stream->size();
}

}