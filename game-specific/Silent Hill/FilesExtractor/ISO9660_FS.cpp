#include "ISO9660_FS.h"
#include "CDStream.h"
#include <cstring>
#include <vector>

#pragma pack(push, 1)
struct iso9660_dtime
{
	uint8_t dt_year; 
	uint8_t dt_month;   
	uint8_t dt_day;
	uint8_t dt_hour;
	uint8_t dt_minute;
	uint8_t dt_second;
	int8_t  dt_gmtoff;                        
};

struct iso9660_dir
{
	uint8_t       length;            
	uint8_t       xa_length;         
	uint32_t      extent_le;   
	uint32_t      extent_be;   
	uint32_t      size_le;        
	uint32_t      size_be;               
	iso9660_dtime recording_time;
	uint8_t       file_flags;
	uint8_t       file_unit_size;
	uint8_t       interleave_gap;
	uint16_t      volume_sequence_number_le;
	uint16_t      volume_sequence_number_be;
	uint8_t       len;
};
#pragma pack(pop)

enum iso_flags
{
	ISO_EXISTENCE   =   1,
	ISO_DIRECTORY   =   2,
	ISO_ASSOCIATED  =   4,
	ISO_RECORD      =   8,
	ISO_PROTECTION  =  16,
	ISO_DRESERVED1  =  32,
	ISO_DRESERVED2  =  64,
	ISO_MULTIEXTENT = 128
};

static void readDirectory(ISO9660FS::DirectoryInfo& dir, CDStream& cd, int extentLba)
{
	cd.seekToSector(extentLba);
	std::vector<iso9660_dir> isoDirs;
	std::vector<std::string> names;

	while (true)
	{
		iso9660_dir isoDir;
		cd.read(&isoDir, sizeof(isoDir));
		if (isoDir.length == 0)
		{
			break;
		}

		isoDirs.push_back(isoDir);

		std::string name;
		if (isoDir.len != 0)
		{
			name.resize(isoDir.len);
			cd.read(&name[0], name.size());
		}
		names.push_back(name);

		cd.skip(isoDir.length - sizeof(iso9660_dir) - isoDir.len);
	}

	for (size_t i = 0; i < isoDirs.size(); i++)
	{
		const iso9660_dir& isoDir = isoDirs[i];
		std::string& name = names[i];

		if (name.empty() || name[0] <= 0x01)
		{
			continue;
		}

		if ((isoDir.file_flags & ISO_DIRECTORY) != 0)
		{
			dir.subdirs[name] = {name};
			readDirectory(dir.subdirs[name], cd, isoDir.extent_le);
		}
		else
		{
			const size_t pos = name.find(';');
			if (pos != std::string::npos)
			{
				name.resize(pos);
			}

			dir.files[name] = {name, isoDir.extent_le, isoDir.size_le};
		}
	}
}

ISO9660FS ISO9660FS::fromImage(CDStream& stream)
{
	// Find primary volume descriptor
	for (int i = 16; i < stream.sectorCount(); i++)
	{	
		char cd001[7] = {};
		
		if (!stream.seekToSector(i) || !stream.read(cd001, sizeof(cd001)))
		{
			return ISO9660FS();
		}

		if (strncmp(&cd001[1], "CD001\x01", 6) != 0)
		{
			return ISO9660FS();
		}

		if (cd001[0] == 1)
		{
			// Found
			break;
		}
	}

	stream.seekInSector(0x9C);
	iso9660_dir rootDirectory;
	stream.read(&rootDirectory, sizeof(rootDirectory));

	ISO9660FS fs;
	readDirectory(fs.m_rootDir, stream, rootDirectory.extent_le);
	return fs;
}

bool ISO9660FS::isNull() const
{
	return m_rootDir.subdirs.empty();
}

const ISO9660FS::DirectoryInfo& ISO9660FS::rootDirectory() const
{
	return m_rootDir;
}

static ISO9660FS::FileInfo find(const ISO9660FS::DirectoryInfo* dir, const char* path)
{
	const char* c = path;
	while (*c != '\0')
	{
		while (*c == '/')
		{
			c++;
		}

		const char* res = strchr(c, '/');
		const bool isDir = res != NULL;
		const int len = res == NULL ? strlen(c) : res - c;

		if (isDir)
		{
			bool found = false;
			for (std::map<std::string, ISO9660FS::DirectoryInfo>::const_iterator subdir = dir->subdirs.begin(); subdir != dir->subdirs.end(); subdir++)
			{
				if (subdir->second.name.size() == len && strncmp(subdir->second.name.c_str(), c, len) == 0)
				{
					dir = &subdir->second;
					found = true;
					c += len;
					break;
				}
			}
			if (!found)
			{
				return ISO9660FS::FileInfo();
			}
		}
		else
		{
			for (std::map<std::string, ISO9660FS::FileInfo>::const_iterator file = dir->files.begin(); file != dir->files.end(); file++)
			{
				if (file->second.name.size() == len && strncmp(file->second.name.c_str(), c, len) == 0)
				{
					return file->second;
				}
			}
			return ISO9660FS::FileInfo();
		}
	}
}

const ISO9660FS::FileInfo ISO9660FS::findFile(const char* path) const
{
	return find(&m_rootDir, path);
}
