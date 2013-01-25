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

#ifndef __ISOFILE_H
#define __ISOFILE_H

#include "IsoFileDescriptor.h"
#include "SectorSource.h"
#include "Stream.h"

class IsoFile: public Consolgames::IFileStream
{
public:
	static const int sectorLength = 2048;

protected:
	SectorSource&		m_internalReader;
	IsoFileDescriptor	m_fileEntry;

	offset_t m_currentOffset;
	offset_t m_maxOffset;

	int m_currentSectorNumber;
	u8	m_currentSector[sectorLength];
	offset_t m_sectorOffset;

public:
	IsoFile(const IsoDirectory& dir, const std::string& filename);
	IsoFile(SectorSource& reader, const std::string& filename);
	IsoFile(SectorSource& reader, const IsoFileDescriptor& fileEntry);
	virtual ~IsoFile() throw();

	offset_t seek(offset_t offset);
	virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
	void reset();

	virtual offset_t skip(offset_t n);
	virtual offset_t tell() const override;
	virtual bool eof() const override;

	virtual largesize_t size() const override;

	const IsoFileDescriptor& entry() const;

	u8	 readByte();
	virtual largesize_t read(void* dest, largesize_t len) override;
	std::string readLine();

protected:
	void makeDataAvailable();
	size_t  internalRead(void* dest, offset_t off, largesize_t len);
	void init();
};

#endif /* __ISOFILE_H */

