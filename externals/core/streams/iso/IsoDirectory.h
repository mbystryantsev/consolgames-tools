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

#ifndef __ISODIRECTORY_H
#define __ISODIRECTORY_H

#include <vector>

enum IsoFSType
{
	fsISO9660	= 1,
	fsJoliet	= 2,
};

class IsoDirectory 
{
public:
	SectorSource&			m_internalReader;
	std::vector<IsoFileDescriptor>	m_files;
	IsoFSType			m_fstype;

public:
	IsoDirectory(SectorSource& r);
	IsoDirectory(SectorSource& r, IsoFileDescriptor directoryEntry);
	virtual ~IsoDirectory() throw();

	std::string fsTypeName() const;
	SectorSource& reader() const { return m_internalReader; }

	bool exists(const std::string& filePath) const;
	bool isFile(const std::string& filePath) const;
	bool isDir(const std::string& filePath) const;
	
	size_t fileSize(const std::string& filePath) const;

	IsoFileDescriptor findFile(const std::string& filePath) const;
    bool findFile(const std::string& filePath, IsoFileDescriptor& info) const;
	
protected:
	const IsoFileDescriptor& entry(const std::string& fileName) const;
	const IsoFileDescriptor& entry(int index) const;

	void init(const IsoFileDescriptor& directoryEntry);
	int indexOf(const std::string& fileName) const;
};

#endif /* __ISODIRECTORY_H */
