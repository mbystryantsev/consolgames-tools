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

#include "IsoFS.h"
#include "IsoFile.h"

#include <memory>
#include <PathInfo.h>

//////////////////////////////////////////////////////////////////////////
// IsoDirectory
//////////////////////////////////////////////////////////////////////////

//u8		filesystemType;	// 0x01 = ISO9660, 0x02 = Joliet, 0xFF = NULL
//u8		volID[5];		// "CD001"


std::string IsoDirectory::fsTypeName() const
{
	switch(m_fstype)
	{
		case fsISO9660:
			return "ISO9660";
			break;
		case fsJoliet:	
			return "Joliet";
			break;
	}

	return "UNKNOWN"; // "Unrecognized Code (0x%x)", m_fstype
}

// Used to load the Root directory from an image
IsoDirectory::IsoDirectory(SectorSource& r)
	: m_internalReader(r)
{
	IsoFileDescriptor rootDirEntry;
	bool isValid = false;
	bool done = false;
	int i = 16;

	m_fstype = fsISO9660;

	while( !done )
	{
		u8 sector[2048];
		m_internalReader.readSector(sector,i);
		if( memcmp( &sector[1], "CD001", 5 ) == 0 )
		{
		    switch (sector[0])
		    {
		        case 0:
                    DLOG("(IsoFS) Block 0x%x: Boot partition info.", i);
                    break;

                case 1:
                    DLOG("(IsoFS) Block 0x%x: Primary partition info.", i); 
                    rootDirEntry.load( sector+156, 38 );
                    isValid = true;
                    break;

                case 2:
                    // Probably means Joliet (long filenames support), which PCSX2 doesn't care about.
                    DLOG("(IsoFS) Block 0x%x: Extended partition info.", i);
                    m_fstype = fsJoliet;
                    break;

				case 0xff:
					// Null terminator.  End of partition information.
					done = true;
				break;

				default:
					DLOG("(IsoFS) Unknown partition type ID=%d, encountered at block 0x%x", sector[0], i );
				break;
			}
		}
		else
		{
			sector[9] = 0;
			DLOG("(IsoFS) Invalid partition descriptor encountered at block 0x%x: '%s'", i, &sector[1]);
			break;		// if no valid root partition was found, an exception will be thrown below.
		}

		i++;
	}

	ASSERT(isValid);
	if(!isValid)
	{
		return;
		//throw Exception::BadStream( "IsoFS", "Root directory not found on ISO image." );
	}

	DLOG << "(IsoFS) Filesystem is " << fsTypeName();
	init(rootDirEntry);
}

// Used to load a specific directory from a file descriptor
IsoDirectory::IsoDirectory(SectorSource& r, IsoFileDescriptor directoryEntry)
	: m_internalReader(r)
{
	init(directoryEntry);
}

IsoDirectory::~IsoDirectory() throw()
{
}

void IsoDirectory::init(const IsoFileDescriptor& directoryEntry)
{
	// parse directory sector
	IsoFile dataStream (m_internalReader, directoryEntry);
	m_files.clear();
	u32 remainingSize = directoryEntry.size;
	u8 b[257];
	while(remainingSize>=4) // hm hack :P
	{
		b[0] = dataStream.read<u8>();
		if(b[0]==0)
		{
			break; // or continue?
		}
		remainingSize -= b[0];
		dataStream.read(b+1, b[0]-1);
		m_files.push_back(IsoFileDescriptor(b, b[0]));
	}
	b[0] = 0;
}

const IsoFileDescriptor& IsoDirectory::entry(int index) const
{
	return m_files[index];
}

int IsoDirectory::indexOf(const std::string& fileName) const
{
	for(unsigned int i=0;i<m_files.size();i++)
	{
		if(m_files[i].name == fileName) return i;
	}

	//throw Exception::FileNotFound( fileName );
        return -1;
}

const IsoFileDescriptor& IsoDirectory::entry(const std::string& fileName) const
{
	return entry(indexOf(fileName));
}

Nullable<IsoFileDescriptor> IsoDirectory::findFile(const std::string& filePath, IsoFileDescriptor& info) const
{
	ASSERT(!filePath.empty());

	PathInfo pathInfo(filePath);
	//IsoFileDescriptor info;
	std::auto_ptr<IsoDirectory*> directoryDeleter;
	const IsoDirectory* directory;
	//ScopedPtr<IsoDirectory> deleteme;

	// walk through path ("." and ".." entries are in the directories themselves, so even if the
	// path included . and/or .., it still works)

	int index;
	for(int i = 0; i < pathInfo.partCount(); i++)
	{
		index = indexOf(pathInfo.part(i));
		if(index == -1)
		{
			return false;
		}
		info = directory->entry(index);
		if(info.IsFile())
		{
			return false;
			//throw Exception::FileNotFound( filePath );

		directoryDeleter.reset(new IsoDirectory(m_internalReader, info));
		directory = directoryDeleter.get();
	}


	if(!pathInfo.path().empty())
	{
		index = directory->indexOf(pathInfo.path());
		if(index != -1)
		{
			info = directory->entry(index);
		}
		else
		{
			return false;
		}
	}
	
	return true;
}

IsoFileDescriptor IsoDirectory::findFile(const std::string& filePath) const
{
      IsoFileDescriptor info;
      findFile(filePath, info);
      return info;
}

bool IsoDirectory::isFile(const std::string& filePath) const
{
	if( !filePath.length() ) return false;
	return (findFile(filePath).flags&2) != 2;
}

bool IsoDirectory::isDir(const std::string& filePath) const
{
	if( !filePath.length() ) return false;
	return (findFile(filePath).flags&2) == 2;
}

size_t IsoDirectory::fileSize( const std::string& filePath ) const
{
	return findFile( filePath ).size;
}

IsoFileDescriptor::IsoFileDescriptor()
{
	lba = 0;
	size = 0;
	flags = 0;
}

IsoFileDescriptor::IsoFileDescriptor(const u8* data, int length)
{
	load( data, length );
}

void IsoFileDescriptor::load(const void* data, int length)
{
	lba		= static_cast<u32&>(data[2]);
	size	= static_cast<u32&>(data[10]);

	date.year      = data[18] + 1900;
	date.month     = data[19];
	date.day       = data[20];
	date.hour      = data[21];
	date.minute    = data[22];
	date.second    = data[23];
	date.gmtOffset = data[24];

	flags = data[25];

	int fileNameLength = data[32];

	if(fileNameLength == 1)
	{
		u8 c = data[33];

		switch(c)
		{
			case 0:	
				name = "."; 
				break;
			case 1: 
				name = ".."; 
				break;
			default: 
				name = c;
		}
	}
	else
	{
		// copy string and up-convert from ascii to wxChar
		const u8* fnsrc = data + 33;
		const u8* fnend = fnsrc + fileNameLength;

		while(fnsrc != fnend)
		{
			name += *fnsrc;
			fnsrc++;
		}
	}
}
