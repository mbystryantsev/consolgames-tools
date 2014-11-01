#include "Silent.h"
#include "CDStream.h"
#include "ISO9660_FS.h"
#include "crc.h"
#include <cstring>
#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include <iomanip>
#ifdef _WIN32
#include <io.h>
#include <direct.h>
#else
#include <unistd.h>
#include <sys/io.h>
#include <sys/stat.h>
#endif

#ifdef _WIN32
#include <windows.h>
#else
#include <limits.h>
#define MAX_PATH PATH_MAX
#endif

#ifdef _MSC_VER
#define snprintf _snprintf
#define mkdir(path, mode) _mkdir(path)
#define access _access
#endif

using namespace std;

static const char* c_defaultExtensions[16] =
    {
        ".TIM", ".VAB", ".BIN", ".DMS",
        ".ANM", ".PLM", ".IPD", ".ILM",
        ".TMD", ".DAT", ".KDT", ".CMP",
        ".TXT", "",     "",     ""
    };
	
static const char* c_demoExtensions[16] =
    {
        ".TIM", ".VAB", ".BIN", ".ANM",
        ".DMS", ".PLM", ".IPD", ".ILM",
        ".TMD", ".DAT", ".KDT", ".CMP",
        ".TXT", "",     "",     ""
    };

static const char* c_opm16Extensions[16] =
    {
        ".TIM", ".VAB", ".BIN", ".ANM",
        ".DMS", ".PLM", ".IPD", ".ILM",
        ".TMD", ".KDT", ".CMP", "",
        "",     "",     "",     ""
    };

#ifdef _WIN32
#define SEP_S "\\"
#define SEP   '\\'
#else
#define SEP_S "/"
#define SEP   '/'
#endif
#define DIR(dir) (SEP_S dir SEP_S)
#define ROOT_DIR SEP_S

static const char* c_defaultDirectoryStruct[16] =
	{
        DIR("1ST"),   DIR("ANIM"),  DIR("BG"),    DIR("CHARA"),
        DIR("ITEM"),  DIR("MISC"),  DIR("SND"),   DIR("TEST"),
        DIR("TIM"),   DIR("VIN"),   DIR("XA"),    ROOT_DIR,
        ROOT_DIR,     ROOT_DIR,     ROOT_DIR,     ROOT_DIR
    };

static const char* c_demoDirectoryStruct[16] =
	{
        DIR("1ST"),   DIR("ANIM"),  DIR("BG"),     DIR("CHARA"),
        DIR("ITEM"),  DIR("MISC"),  DIR("SND"),    DIR("TIM"),
        DIR("VIN"),   DIR("XA"),    ROOT_DIR,      ROOT_DIR,
        ROOT_DIR,     ROOT_DIR,     ROOT_DIR,      ROOT_DIR
    };
	
static const char* c_opm16DirectoryStruct[16] =
	{
        DIR("1ST"),   DIR("ANIM"),  DIR("BG"),    DIR("CHARA"),
        DIR("ITEM"),  DIR("SND"),   DIR("TEST"),  DIR("TIM"),
        DIR("VIN"),   DIR("XA"),    ROOT_DIR,     ROOT_DIR,
        ROOT_DIR,     ROOT_DIR,     ROOT_DIR,     ROOT_DIR
    };

static const char* c_extendedDirectoryStruct[16] =
	{
        DIR("1ST"),   DIR("ANIM"),  DIR("BG"),    DIR("CHARA"),
        DIR("ITEM"),  DIR("MISC"),  DIR("SND"),   DIR("TEST"),
        DIR("TIM"),   DIR("VIN"),   DIR("VIN2"),  DIR("VIN3"),
        DIR("VIN4"),  DIR("VIN5"),  DIR("XA"),    ROOT_DIR
    };

namespace
{

struct VersionInfo
{
	const char* desc;
	const char* id;
	const char* executablePath;
	uint32_t headerHash;
	const char* const* directories;
	const char* const* extensions;
	uint32_t fileInfoOffset;
	int fileCount;
	bool altRecordFormat;
	uint32_t baseLba;
};

}

static const VersionInfo c_versionInfo[] =
	{
		{
			"EU, Full Game",
			"SLES-01514",
			"/SLES_015.14",
			0xA8ECA2C7,
			c_extendedDirectoryStruct,
			c_defaultExtensions,
			0xB8FC,
			2310,
			false,
			0
		},
		{
			"US, Full Game (v1.1)",
			"SLUS-00707",
			"/SLUS_007.07",
			0x6C5D2E16,
			c_defaultDirectoryStruct,
			c_defaultExtensions,
			0xB91C,
			2074,
			false,
			0
		},
		{
			"US, Full Game Beta (v1.0)",
			"SLUS-00707",
			"/SLUS_007.07",
			0x3FC9668A,
			c_defaultDirectoryStruct,
			c_defaultExtensions,
			0xB850,
			2072,
			false,
			0
		},
		{
			"JP, Full Game",
			"SLPM-86192",
			"/SLPM_861.92",
			0xBA003D30,
			c_defaultDirectoryStruct,
			c_defaultExtensions,
			0xB91C,
			2074,
			false,
			0
		},
		{
			"EU, Trial (Demo) Game",
			"SLED-01735",
			"/SLED_017.35",
			0x99C557EB,
			c_demoDirectoryStruct,
			c_demoExtensions,
			0xB648,
			850,
			false,
			0
		},
		{
			"US, Trial (Demo) Game",
			"SLUS-90050",
			"/SLUS_900.50",
			0x75D2AA7F,
			c_demoDirectoryStruct,
			c_demoExtensions,
			0xB648,
			849,
			false,
			0
		},
		{
			"JP, Trial (Demo) Game",
			"SLPM-80363",
			"/SLPM_803.63",
			0xCD9AF51E,
			c_demoDirectoryStruct,
			c_demoExtensions,
			0xB780,
			843,
			true,
			0
		},
		{
			"Official U.S. PlayStation Magazine Demo Disc #16",
			"SCUS-94278",
			"/SH/SH.EXE",
			0x435425B7,
			c_opm16DirectoryStruct,
			c_opm16Extensions,
			0xAA90,
			886,
			true,
			72656
		},
		{
			"Best Horror Games Ever Demo",
			"SCED-02420",
			"/SH/SH.EXE",
			0x47D6B153,
			c_extendedDirectoryStruct,
			c_defaultExtensions,
			0xC8FC,
			1015,
			false,
			31075
		}
	};

namespace
{

#pragma pack(push, 1)

struct FileRecordAlt
{
	// word 0
	uint32_t startSector     : 19;  // CD start sector number
	uint32_t chunkCount      : 12;  // Size in chunks of size 0x100
	uint32_t directoryIndex0 : 1;
	
	// word 1
	uint32_t directoryIndex1 : 3;
	uint32_t name0           : 29;

	// word 3
    unsigned int name1          : 19;
    unsigned int extensionIndex : 8;
    unsigned int dummy          : 5;

	int size() const
	{
		return chunkCount * 0x100;
	}
	
	const char* extension(const VersionInfo& versionInfo) const
	{
		return versionInfo.extensions[extensionIndex];
	}
	
	const char* directory(const VersionInfo& versionInfo) const
	{
		return versionInfo.directories[(directoryIndex1 << 1) | directoryIndex0];
	}
	
	std::string basename() const
	{
		uint64_t v = (name0 | (static_cast<uint64_t>(name1) << 29)) & 0xFFFFFFFFFFFFULL;
		std::string name;

		for (int i = 0; i < 8 && v != 0; i++)
		{
			const char c = (v & 0x3F) + 0x20;
			name.push_back(c);
			v >>= 6;
		}

		return name;
	}
};

struct FileRecord
{
	// word 0
	uint32_t startSector    : 19;  // CD start sector number
	uint32_t chunkCount     : 13;  // Size in chunks of size 0x100
	
	// word 1
	uint32_t directoryIndex : 4;
	uint32_t name0          : 24;
	uint32_t dummy          : 4;

	// word 3
    unsigned int name1          : 24;
    unsigned int extensionIndex : 8;

	int size(const VersionInfo& versionInfo) const
	{	
		if (versionInfo.altRecordFormat)
		{
			return reinterpret_cast<const FileRecordAlt*>(this)->size();
		}

		return chunkCount * 0x100;
	}
	
	const char* extension(const VersionInfo& versionInfo) const
	{		
		if (versionInfo.altRecordFormat)
		{
			return reinterpret_cast<const FileRecordAlt*>(this)->extension(versionInfo);
		}

		return versionInfo.extensions[extensionIndex];
	}
	
	const char* directory(const VersionInfo& versionInfo) const
	{
		if (versionInfo.altRecordFormat)
		{
			return reinterpret_cast<const FileRecordAlt*>(this)->directory(versionInfo);
		}

		return versionInfo.directories[directoryIndex];
	}
	
	std::string basename(const VersionInfo& versionInfo) const
	{
		if (versionInfo.altRecordFormat)
		{
			return reinterpret_cast<const FileRecordAlt*>(this)->basename();
		}

		std::string name;
		unsigned int values[] = {name0, name1};

		for (int j = 0; j < 2; j++)
		{
			int v = values[j];
			for (int i = 0; i < 4 && v != 0; i++)
			{
				const char c = (v & 0x3F) + 0x20;
				name.push_back(c);
				v >>= 6;
			}
		}
		
		return name;
	}
};

#pragma pack(pop)

}

struct RegionInfo
{
	const VersionInfo* versionInfo;
	uint32_t executableSector;
};

static RegionInfo detectRegion(CDStream& cd)
{
	ISO9660FS fs = ISO9660FS::fromImage(cd);

	if (fs.isNull())
	{
		return {NULL, 0};
	}

	const int versionCoint = sizeof(c_versionInfo) / sizeof(VersionInfo);
	for (int i = 0; i < versionCoint; i++)
	{
		const VersionInfo& info = c_versionInfo[i];
		const ISO9660FS::FileInfo fileInfo = fs.findFile(info.executablePath);
		if (fileInfo.name.empty())
		{
			continue;
		}

		char data[256];
		cd.seekToSector(fileInfo.lba);
		cd.read(data, sizeof(data));
		const uint32_t hash = crc32(data, 256);

		if (c_versionInfo[i].headerHash == hash)
		{
			return {&c_versionInfo[i], fileInfo.lba};
		}
	}
	
	return {NULL, 0};
}

static void forceDirectories(const char *dir)
{
    char tmp[MAX_PATH];
    snprintf(tmp, sizeof(tmp), "%s" ,dir);
    const size_t len = strlen(tmp);
    if (tmp[len - 1] == SEP)
	{
		tmp[len - 1] = 0;
	}

    for (char* p = tmp + 1; *p != '\0'; p++)
	{
		if (*p == SEP)
		{
			*p = 0;
			mkdir(tmp, 0755);
			*p = SEP;
		}
    }
    mkdir(tmp, 0755);
}

static bool directoryExists(const char *dir)
{
    return (access(dir, 0) == 0);
}

static bool extractFiles(const std::vector<FileRecord>& records, CDStream& cd, const char *out_dir, const VersionInfo& versionInfo)
{
    char path[MAX_PATH];

    strcpy(path, out_dir);
    if (!directoryExists(path))
    {
        forceDirectories(path);
    }
    strcat(path, SEP_S "list.txt");

    std::ofstream list(path, std::ios_base::out);
    if (!list.is_open())
	{
		std::cout << "Unable to open list file!" << std::endl;
		return false;
	}

	std::vector<char> buf;
	buf.resize(0x100000);

	list << "# sector size     filename" << std::endl;
	list << std::setfill('0') << std::uppercase << std::hex;
	list.width(10);

    for (std::vector<FileRecord>::const_iterator rec = records.begin(); rec != records.end(); rec++)
	{		
        strcpy(path, out_dir);
        strcat(path, rec->directory(versionInfo));
        if(!directoryExists(path))
        {
           forceDirectories(path);
        }
        
		const std::string name = rec->basename(versionInfo);
        
		std::cout << rec->directory(versionInfo) << name.c_str() << rec->extension(versionInfo) << std::endl;

        strcat(path, name.c_str());
        strcat(path, rec->extension(versionInfo));

        const uint32_t size = rec->size(versionInfo);
		cd.seekToSector(rec->startSector + versionInfo.baseLba);

		if (size > 0)
		{
			if (size > buf.size())
			{
				buf.resize(size);
			}
			cd.read(&buf[0], size);
		}

		std::ofstream outFile(path, std::ios_base::out | std::ios_base::binary);
        if (size > 0)
		{
			outFile.write(&buf[0], size);
		}
		list << std::setw(8) << rec->startSector << ' ' << std::setw(8) << size << ' ' << rec->directory(versionInfo) << name << rec->extension(versionInfo) << std::endl;
    }

    return true;
}

bool extractFiles(const char* isoPath, const char* outputDirectory)
{
	CDStream cd(isoPath);
	if (!cd.isOpen())
	{
        printf("Unable to open ISO file!\n");
        return false;
	}

    RegionInfo regionInfo = detectRegion(cd);

	if (regionInfo.versionInfo == NULL)
    {
		std::cout << "Unknown version of game!" << std::endl;
		return false;
	}

	const VersionInfo& info = *regionInfo.versionInfo;
	std::cout << "Executable detected: " << info.id << " - " << info.desc << std::endl;

	std::vector<FileRecord> fileRecords;
	fileRecords.resize(info.fileCount);
	cd.seekToSector(regionInfo.executableSector);
	cd.skip(info.fileInfoOffset);
    cd.read(reinterpret_cast<char*>(&fileRecords[0]), info.fileCount * sizeof(FileRecord));

	std::cout << "Extracting..." << std::endl;

    return extractFiles(fileRecords, cd, outputDirectory, info);
}

void printSupportedVersions()
{
	std::cout << "Supported versions:" << std::endl;
	for (int i = 0; i < sizeof(c_versionInfo) / sizeof(VersionInfo); i++)
	{
		std::cout << "    " << c_versionInfo[i].id << " - " << c_versionInfo[i].desc << std::endl;
	}
}

