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

// TODO: Remove this class

#pragma once
#include "IsoFileDescriptor.h"
#include "SectorSource.h"
#include <Stream.h>

namespace Consolgames
{

class IsoFile
{
public:
	static const int sectorLength = 2048;

protected:
	SectorSource&		m_internalReader;
	IsoFileDescriptor	m_fileEntry;

	offset_t m_currentOffset;
	offset_t m_maxOffset;

	int m_currentSectorNumber;
	uint8	m_currentSector[sectorLength];
	offset_t m_sectorOffset;

public:
	IsoFile(const IsoDirectory& dir, const std::string& filename);
	IsoFile(SectorSource& reader, const std::string& filename);
	IsoFile(SectorSource& reader, const IsoFileDescriptor& fileEntry);
	virtual ~IsoFile();

	offset_t seek(offset_t absoffset);
	offset_t seek(offset_t offset, Stream::SeekOrigin origin);
	void reset();

	offset_t skip(largesize_t n);
	offset_t position() const;
	largesize_t size() const;
	bool eof() const;

	const IsoFileDescriptor& entry() const;

	uint8 readByte();
	largesize_t read(void* dest, largesize_t len);

protected:
	void makeDataAvailable();
	largesize_t internalRead(void* dest, offset_t off, largesize_t len);
	void init();
};

}
