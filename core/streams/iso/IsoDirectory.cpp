#include "IsoDirectory.h"
#include "IsoFileDescriptor.h"
#include "IsoFile.h"
#include "SectorSource.h"
#include <PathInfo.h>
#include <core.h>
#include <memory>

//uint8_t		filesystemType;	// 0x01 = ISO9660, 0x02 = Joliet, 0xFF = NULL
//uint8_t		volID[5];		// "CD001"

namespace Consolgames
{

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
		uint8_t sector[2048];
		m_internalReader.readSector(sector,i);
		if( memcmp( &sector[1], "CD001", 5 ) == 0 )
		{
			switch (sector[0])
			{
				case 0:
					//Console.WriteLn( Color_Green, "(IsoFS) Block 0x%x: Boot partition info.", i );
					break;

				case 1:
					DLOG << "(IsoFS) Block 0x" << HEX << i << ": Primary partition info.";
					rootDirEntry = IsoFileDescriptor::fromData(sector+156, 38);
					isValid = true;
					break;

				case 2:
					// Probably means Joliet (long filenames support), which PCSX2 doesn't care about.
					DLOG << "(IsoFS) Block 0x" << HEX << i << ": Extended partition info.";
					m_fstype = fsJoliet;
					break;

				case 0xff:
					// Null terminator.  End of partition information.
					done = true;
				break;

				default:
					DLOG << "(IsoFS) Unknown partition type ID=" << sector[0] << " encountered at block 0x" << HEX << i;
				break;
			}
		}
		else
		{
			sector[9] = 0;
			DLOG << "(IsoFS) Invalid partition descriptor encountered at block 0x" << HEX << i << ": '" <<  reinterpret_cast<const char*>(&sector[1]) << "'";
			break;		// if no valid root partition was found, an exception will be thrown below.
		}

		i++;
	}

	ASSERT(isValid);
	if(!isValid)
	{
		DLOG << "Root directory not found on ISO image.";
		return;
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
	uint32_t remainingSize = directoryEntry.size;
	uint8_t b[257];
	while(remainingSize>=4) // hm hack :P
	{
		dataStream.read(b, 1);
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
	for (size_t i = 0; i < m_files.size(); i++)
	{
		if (_stricmp(m_files[i].name.c_str(), fileName.c_str()) == 0)
		{
			return i;
		}
	}

	return -1;
}

const IsoFileDescriptor& IsoDirectory::entry(const std::string& fileName) const
{
	return entry(indexOf(fileName));
}

IsoFileDescriptor IsoDirectory::findFile(const std::string& filePath) const
{
	ASSERT(!filePath.empty());
	IsoFileDescriptor result;
	const IsoDirectory* directory = this;
	std::auto_ptr<IsoDirectory> directoryDeleter;

	// walk through path ("." and ".." entries are in the directories themselves, so even if the
	// path included . and/or .., it still works)

	const PathInfo pathInfo(filePath);

	for (int i = 0; i < pathInfo.partCount() - 1; i++)
	{
		const int index = directory->indexOf(pathInfo.part(i));
		if (index == -1)
		{
			return IsoFileDescriptor();
		}

		const IsoFileDescriptor info = directory->entry(index);
		if (info.isFile())
		{
			return IsoFileDescriptor();
		}

		directoryDeleter.reset(new IsoDirectory(m_internalReader, info));
		directory = directoryDeleter.get();
	}

	if (!pathInfo.path().empty())
	{
		int index = directory->indexOf(pathInfo.basename() + ";1");
		if (index == -1)
		{
			index = directory->indexOf(pathInfo.basename());
		}
		
		if (index != -1)
		{
			return directory->entry(index);
		}
	}

	return IsoFileDescriptor();
}

bool IsoDirectory::isFile(const std::string& filePath) const
{
	if (filePath.empty())
	{
		return false;
	}

	const IsoFileDescriptor descriptor = findFile(filePath);
	return (descriptor.isNull() || (findFile(filePath).flags & 2) != 2);
}

bool IsoDirectory::isDir(const std::string& filePath) const
{
	if (filePath.empty())
	{
		return false;
	}

	const IsoFileDescriptor descriptor = findFile(filePath);
	return (descriptor.isNull() || (findFile(filePath).flags & 2) == 2);
}

uint32_t IsoDirectory::fileSize( const std::string& filePath ) const
{
	return findFile( filePath ).size;
}

}
