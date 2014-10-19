#include "CDStream.h"
#include <algorithm>

static const int c_sectorSize = 0x930;
static const int c_sectorDataOffset = 0x18;
static const int c_sectorDataSize = 0x800;

CDStream::CDStream(const char* filename)
	: m_cd(filename, std::ios_base::in | std::ios_base::binary)
	, m_currentSector(0)
	, m_currentPos(0)
	, m_sectorCount(0)
{
	m_cd.seekg(0, std::ios::end);
	m_sectorCount = static_cast<int>(m_cd.tellg() / c_sectorSize);
	seekToSector(0);
}

bool CDStream::isOpen() const
{
	return m_cd.is_open();
}

bool CDStream::seekToSector(int sector, int positionInSector)
{
	if (positionInSector > c_sectorDataSize)
	{
		return false;
	}

	m_cd.seekg(sector * c_sectorSize + c_sectorDataOffset + positionInSector);
	if (!m_cd.fail())
	{
		m_currentPos = positionInSector;
		m_currentSector = sector;
		return true;
	}
	m_cd.clear();
	return false;
}

bool CDStream::seekInSector(int position)
{
	return seekToSector(m_currentSector, position);
}

bool CDStream::skip(uint32_t size)
{
	int sector = m_currentSector + size / c_sectorDataSize;
	int position = m_currentPos + size % c_sectorDataSize;
	if (position >= c_sectorDataSize)
	{
		sector++;
		position -= c_sectorDataSize;
	}

	return seekToSector(sector, position);
}

bool CDStream::read(void* data, uint32_t size)
{
	char* d = reinterpret_cast<char*>(data);
	while (size > 0)
	{
		if (m_currentPos == c_sectorDataSize && !seekToSector(m_currentSector + 1))
		{
			return false;
		}

		const int chunkSize = std::min<int>(size, c_sectorDataSize - m_currentPos);
		m_cd.read(d, chunkSize);
		
		if (m_cd.fail())
		{
			m_cd.clear();
			return false;
		}

		m_currentPos += chunkSize;
		size -= chunkSize;
		d += chunkSize;
	}
}

int CDStream::sectorCount() const
{
	return m_sectorCount;
}

int CDStream::sector() const
{
	return m_currentSector;
}

int CDStream::positionInSector() const
{
	return m_currentPos;
}
