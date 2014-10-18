#include "Silent.h"
#include "crc.h"
#include <string>
#include <iostream>
#include <vector>
#include <fstream>
#include <iomanip>
#include <io.h>
#include <direct.h>

#ifdef _WIN32
#include <windows.h>
#else
#include <limits.h>
#define MAX_PATH PATH_MAX
#endif

#ifdef _MSC_VER
#define snprintf _snprintf
#define mkdir _mkdir
#endif

using namespace std;

static const int c_versionCount = 4;

static const char* c_extensions[16] =
    {
        ".TIM", ".VAB", ".BIN", ".DMS",
        ".ANM", ".PLM", ".IPD", ".ILM",
        ".TMD", ".DAT", ".KDT", ".CMP",
        ".TXT", "",     "",     ""
    };
	
static const char* c_defaultDirectoryStruct[16] =
	{
        "\\1ST\\",   "\\ANIM\\",  "\\BG\\",    "\\CHARA\\",
        "\\ITEM\\",  "\\MISC\\",  "\\SND\\",   "\\TEST\\",
        "\\TIM\\",   "\\VIN\\",   "\\XA\\",    "\\",
        "\\",        "\\",        "\\",        "\\"
    };
	
static const char* c_extendedDirectoryStruct[16] =
	{
        "\\1ST\\",   "\\ANIM\\",  "\\BG\\",    "\\CHARA\\",
        "\\ITEM\\",  "\\MISC\\",  "\\SND\\",   "\\TEST\\",
        "\\TIM\\",   "\\VIN\\",   "\\VIN2\\",  "\\VIN3\\",
        "\\VIN4\\",  "\\VIN5\\",  "\\XA\\",    "\\"
    };

namespace
{

struct VersionInfo
{
	const char* id;
	unsigned int headerHash;
	const char* const* directories;
	unsigned int fileInfoOffset;
	int fileCount;
};

}

static const VersionInfo c_versionInfo[c_versionCount] =
	{
		{
			"SLES-01514",
			0xA8ECA2C7,
			c_extendedDirectoryStruct,
			0xB8FC,
			2310
		},
		{
			"SLUS-00707",
			0x6C5D2E16,
			c_defaultDirectoryStruct,
			0xB91C,
			2074
		},
		{
			"SLUS-00707 (beta)",
			0x3FC9668A,
			c_defaultDirectoryStruct,
			0xB850,
			2072
		},
		{
			"SLPM-86192",
			0xBA003D30,
			c_defaultDirectoryStruct,
			0xB91C,
			2074
		}
	};

namespace
{

#pragma pack(push, 1)
struct FileRecord
{
	// word 0
	unsigned int startSector    : 19;  // CD start sector number
	unsigned int chunkCount     : 13;  // Size in chunks of size 0x100
	
	// word 1
    unsigned int directoryIndex : 4;
	unsigned int name0          : 24;
	unsigned int dummy          : 4;

	// word 3
    unsigned int name1          : 24;
    unsigned int extensionIndex : 8;
	
	int size() const
	{
		return chunkCount * 0x100;
	}
	
	const char* extension() const
	{
		return c_extensions[extensionIndex];
	}
	
	const char* directory(int version) const
	{
		return c_versionInfo[version].directories[directoryIndex];
	}
	
	std::string basename() const
	{
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

static int detectRegion(const void* data)
{
	const uint32_t hash = crc32(data, 256);
	for (int i = 0; i < c_versionCount; i++)
	{
		if (c_versionInfo[i].headerHash == hash)
		{
			return i;
		}
	}
	
	return -1;
}

static void forceDirectories(const char *dir)
{
    char tmp[MAX_PATH];
    snprintf(tmp, sizeof(tmp), "%s" ,dir);
    const size_t len = strlen(tmp);
    if (tmp[len - 1] == '\\')
	{
		tmp[len - 1] = 0;
	}

    for (char* p = tmp + 1; *p != '\0'; p++)
	{
		if (*p == '\\')
		{
			*p = 0;
			mkdir(tmp);
			*p = '\\';
		}
    }
    mkdir(tmp);
}

static bool directoryExists(const char *dir)
{
    return (access(dir, 0) == 0);
}

static bool extractFiles(const std::vector<FileRecord>& records, const char* inputFile, const char *out_dir, int ver)
{
    char path[MAX_PATH];
    unsigned int offset = 0;

    strcpy(path, out_dir);
    if (!directoryExists(path))
    {
        forceDirectories(path);
    }
    strcat(path, "\\list.txt");

    std::ofstream list(path, std::ios_base::out);
    if (!list.is_open())
	{
		return false;
	}

	std::ifstream file(inputFile, std::ios_base::in | std::ios_base::binary);
	if (!file.is_open())
    {
        return false;
    }

	std::vector<char> buf;
	buf.resize(0x100000);

	list << "# offset size     sector   filename" << std::endl;
	list << std::setfill('0') << std::uppercase << std::hex;
	list.width(10);
	
    for (std::vector<FileRecord>::const_iterator rec = records.begin(); rec != records.end(); rec++)
	{		
        strcpy(path, out_dir);
        strcat(path, rec->directory(ver));
        if(!directoryExists(path))
        {
           forceDirectories(path);
        }
        
		const std::string name = rec->basename();
        
		std::cout << rec->directory(ver) << name.c_str() << rec->extension() << std::endl;

		
        strcat(path, name.c_str());
        strcat(path, rec->extension());

        const uint32_t size = rec->size();
        file.seekg(offset);
        
		if (size > 0)
		{
			if (size > buf.size())
			{
				buf.resize(size);
			}
			file.read(&buf[0], size);
		}

		std::ofstream outFile(path, std::ios_base::out | std::ios_base::binary);
        if (size > 0)
		{
			outFile.write(&buf[0], size);
		}
		list << std::setw(8) << offset << ' ' << std::setw(8) << size << ' ' << std::setw(8) << rec->startSector << ' ' << rec->directory(ver) << name << rec->extension() << std::endl;
        offset += ((size + 0x7FF) / 0x800) * 0x800;
    }
    return 0;
}

bool extractFiles(const char* executablePath, const char* silentPath, const char* outputDirectory)
{
	std::ifstream file(executablePath, ios_base::in | ios_base::binary);
    if(!file.is_open())
    {
        printf("Unable to open executable file!\n");
        return false;
    }

	char header[256];
	file.read(header, sizeof(header));
    const int ver = detectRegion(header);
	
	if (ver == -1)
    {
		std::cout << "Unknown version of game!" << std::endl;
		return false;
	}

	const VersionInfo& info = c_versionInfo[ver];
	std::cout << "Executable detected: " << info.id << std::endl;

	std::vector<FileRecord> fileRecords;
	fileRecords.resize(info.fileCount);
	file.seekg(info.fileInfoOffset);
    file.read(reinterpret_cast<char*>(&fileRecords[0]), info.fileCount * sizeof(FileRecord));

    return extractFiles(fileRecords, silentPath, outputDirectory, ver);
}
