/*  PCSX2 - PS2 Emulator for PCs
 *  Copyright (C) 2002-2009  PCSX2 Dev Team
 *
 *  PCSX2 is free software: you can redistribute it and/or modify it under the terms
 *  of the GNU Lesser General Public License as published by the Free Software Found-
 *  ation, either version 3 of the License, or (at your option) any later version.
 *
 *  PCSX2 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 *  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 *  PURPOSE.  See the GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along with PCSX2.
 *  If not, see <http://www.gnu.org/licenses/>.
 */
#include "IsoDirectory.h"
#include "IsoFileDescriptor.h"
#include "IsoFile.h"
#include "limits.h"
#include <memory>
#include <algorithm>

namespace Consolgames
{
	
IsoFile::IsoFile(SectorSource& reader, const std::string& filename)
	: m_internalReader(reader)
	, m_fileEntry(IsoDirectory(reader).findFile(filename))
{
	init();
}

IsoFile::IsoFile(const IsoDirectory& dir, const std::string& filename)
	: m_internalReader(dir.reader())
	, m_fileEntry(dir.findFile(filename))
{
	init();
}

IsoFile::IsoFile(SectorSource& reader, const IsoFileDescriptor& fileEntry)
	: m_internalReader(reader)
	, m_fileEntry(fileEntry)
{
	init();
}

void IsoFile::init()
{
	//ASSERT(m_fileEntry.isFile() && "IsoFile Error: Filename points to a directory.");

	m_currentSectorNumber	= m_fileEntry.lba;
	m_currentOffset		= 0;
	m_sectorOffset		= 0;
	m_maxOffset			= std::max<uint32>( 0, m_fileEntry.size );

	if(m_maxOffset > 0)
		m_internalReader.readSector(m_currentSector, m_currentSectorNumber);
}

IsoFile::~IsoFile() throw()
{
}

offset_t IsoFile::seek(offset_t offset)
{
	offset_t endOffset = offset;

	int oldSectorNumber = m_currentSectorNumber;
	int newSectorNumber = m_fileEntry.lba + static_cast<int>(endOffset / sectorLength);

	if(oldSectorNumber != newSectorNumber)
	{
		m_internalReader.readSector(m_currentSector, newSectorNumber);
	}

	m_currentOffset = endOffset;
	m_currentSectorNumber = newSectorNumber;
	m_sectorOffset = (int)(m_currentOffset % sectorLength);

	return m_currentOffset;
}

// Returns the new offset in the file.  Out-of-bounds seeks are automatically truncated at 0
// and fileLength.

offset_t IsoFile::seek(offset_t offset, Stream::SeekOrigin origin)
{
	switch(origin)
	{
	case Stream::seekSet:
			ASSERT(offset >= 0 && offset <= ULONG_MAX && "Invalid seek position from start.");
			return seek(offset);

	case Stream::seekCur:
			// truncate negative values to zero, and positive values to 4gb
			return seek(std::min<>(std::max<offset_t>(0, static_cast<offset_t>(m_currentOffset) + offset), static_cast<offset_t>(ULONG_MAX)));

	case Stream::seekEnd:
			// truncate negative values to zero, and positive values to 4gb
			return seek(std::min<>(std::max<offset_t>(0, static_cast<offset_t>(m_fileEntry.size+offset)), static_cast<offset_t>(ULONG_MAX)));
	}

	return 0;
}

void IsoFile::reset()
{
	seek(0);
}

// Returns the number of bytes actually skipped.
offset_t IsoFile::skip(largesize_t n)
{
	offset_t oldOffset = m_currentOffset;

	if (n < 0) 
	{
		return 0;
	}

	seek(m_currentOffset + n);

	return m_currentOffset - oldOffset;
}

offset_t IsoFile::position() const
{
	return m_currentOffset;
}

bool IsoFile::eof() const
{
	return (m_currentOffset >= m_maxOffset);
}

// loads the current sector index into the CurrentSector buffer.
void IsoFile::makeDataAvailable()
{
	if (m_sectorOffset >= sectorLength)
	{
		m_currentSectorNumber++;
		m_internalReader.readSector(m_currentSector, m_currentSectorNumber);
		m_sectorOffset -= sectorLength;
	}
}

uint8 IsoFile::readByte()
{
	ASSERT(m_currentOffset < m_maxOffset);

	if(m_currentOffset >= m_maxOffset)
	{
		return 0;
	}

	makeDataAvailable();

	m_currentOffset++;

	return m_currentSector[m_sectorOffset++];
}

// Reads data from a single sector at a time.  Reads cannot cross sector boundaries.
largesize_t IsoFile::internalRead(void* dest, offset_t off, largesize_t len)
{
	if (len > 0)
	{
		largesize_t slen = len;
		if (slen > (m_maxOffset - m_currentOffset))
		{
			slen = static_cast<size_t>(m_maxOffset - m_currentOffset);
		}

		memcpy((uint8*)dest + off, m_currentSector + m_sectorOffset, slen);

		m_sectorOffset += slen;
		m_currentOffset += slen;
		return slen;
	}
	return 0;
}

// returns the number of bytes actually read.
largesize_t IsoFile::read(void* dest, largesize_t size)
{
	ASSERT(dest != NULL);
	ASSERT(size >= 0);

	if(size <= 0)
	{
		return 0;
	}

	int off = 0;

	int totalLength = 0;

	largesize_t firstSector = internalRead(dest, off, std::min<int>(size, sectorLength - m_sectorOffset));
	off += firstSector;
	size -= firstSector;
	totalLength += firstSector;

	// Read whole sectors
	while ((size >= sectorLength) && (m_currentOffset < m_maxOffset))
	{
		makeDataAvailable();
		int n = internalRead(dest, off, sectorLength);
		off += n;
		size -= n;
		totalLength += n;
	}

	// Read remaining, if any
	if (size > 0) 
	{
		makeDataAvailable();
		int lastSector = internalRead(dest, off, size);
		totalLength += lastSector;
	}

	return totalLength;
}

offset_t IsoFile::size() const
{
	return m_maxOffset;
}

const IsoFileDescriptor& IsoFile::entry() const
{
	return m_fileEntry;
}

}
	