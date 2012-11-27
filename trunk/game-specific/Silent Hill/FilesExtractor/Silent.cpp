#include <cstdio>
#include <windows.h>
#include <WinBase.h>
#include <io.h>

#include "Silent.h"

using namespace std;

char* decodeName(unsigned int v1, unsigned int v2, char* name)
{
    v1 >>= 4;
    int i;
    for(i = 0; i < 4 && v1 != 0; i++)
    {
        name[i] = (v1 & 0x3F) + 0x20;
        v1 >>= 6;
    }
    v2 &= 0xFFFFFF;
    int l = i + 4;
    for(; i < l && v2 != 0; i++)
    {
        name[i] = (v2 & 0x3F) + 0x20;
        v2 >>= 6;
    }
    name[i] = 0;
    return name;
}




const char* exts[16] =
    {
        ".TIM", ".VAB", ".BIN", ".DMS",
        ".ANM", ".PLM", ".IPD", ".ILM",
        ".TMD", ".DAT", ".KDT", ".CMP",
        ".TXT", "",     "",     ""
    };

const char* dirs[2][16] = {
    {   // SLES_015.14
        "\\1ST\\",   "\\ANIM\\",  "\\BG\\",    "\\CHARA\\",
        "\\ITEM\\",  "\\MISC\\",  "\\SND\\",   "\\TEST\\",
        "\\TIM\\",   "\\VIN\\",   "\\VIN2\\",  "\\VIN3\\",
        "\\VIN4\\",  "\\VIN5\\",  "\\XA\\",    "\\"
    },
    {   // SLUS_007.07
        "\\1ST\\",   "\\ANIM\\",  "\\BG\\",    "\\CHARA\\",
        "\\ITEM\\",  "\\MISC\\",  "\\SND\\",   "\\TEST\\",
        "\\TIM\\",   "\\VIN\\",   "\\XA\\",    "\\",
        "\\",        "\\",        "\\",        "\\"
    }
};

const int FileCount[2] = {2310, 2072};
const int TableOffset[2] = {0xB8FC, 0xB850};

const unsigned char ExeBegin[2][128] =
{
    {   // SLES_015.14
        0x50, 0x53, 0x2D, 0x58, 0x20, 0x45, 0x58, 0x45, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x5C, 0x2F, 0x01, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x80, 0x00, 0x40, 0x01, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0xF0, 0xFF, 0x1F, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x53, 0x6F, 0x6E, 0x79,
        0x20, 0x43, 0x6F, 0x6D, 0x70, 0x75, 0x74, 0x65, 0x72, 0x20, 0x45, 0x6E, 0x74, 0x65, 0x72, 0x74,
        0x61, 0x69, 0x6E, 0x6D, 0x65, 0x6E, 0x74, 0x20, 0x49, 0x6E, 0x63, 0x2E, 0x20, 0x66, 0x6F, 0x72,
        0x20, 0x45, 0x75, 0x72, 0x6F, 0x70, 0x65, 0x20, 0x61, 0x72, 0x65, 0x61, 0x00, 0x00, 0x00, 0x00
    },
    {   // SLUS_007.07
        0x50, 0x53, 0x2D, 0x58, 0x20, 0x45, 0x58, 0x45, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0xB0, 0x2E, 0x01, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x80, 0x00, 0x38, 0x01, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0xF0, 0xFF, 0x1F, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x53, 0x6F, 0x6E, 0x79,
        0x20, 0x43, 0x6F, 0x6D, 0x70, 0x75, 0x74, 0x65, 0x72, 0x20, 0x45, 0x6E, 0x74, 0x65, 0x72, 0x74,
        0x61, 0x69, 0x6E, 0x6D, 0x65, 0x6E, 0x74, 0x20, 0x49, 0x6E, 0x63, 0x2E, 0x20, 0x66, 0x6F, 0x72,
        0x20, 0x4E, 0x6F, 0x72, 0x74, 0x68, 0x20, 0x41, 0x6D, 0x65, 0x72, 0x69, 0x63, 0x61, 0x20, 0x61
    }
};

int DetectRegion(void* data)
{
    if(memcmp(data, &ExeBegin[0][0], 128) == 0)
        return 0;
    else if(memcmp(data, &ExeBegin[1][0], 128) == 0)
        return 1;
    else
        return -1;
}

void ForceDirectories(const char *dir)
{
    char tmp[MAX_PATH];
    char *p = NULL;
    size_t len;

    snprintf(tmp, sizeof(tmp), "%s",dir);
    len = strlen(tmp);
    if(tmp[len - 1] == '\\')
    tmp[len - 1] = 0;
    for(p = tmp + 1; *p; p++)
    if(*p == '\\') {
        *p = 0;
        CreateDirectory(tmp, NULL);
        *p = '\\';
    }
    CreateDirectory(tmp, NULL);
}

bool DirectoryExists(const char *dir)
{
    return (access(dir, 0) == 0);
}

int ExtractFiles(FileRec* rec, int count, const char *in_file, const char *out_dir, int ver)
{
    char path[MAX_PATH];
    char name[16];
    unsigned int offset = 0, size;

    strcpy(path, out_dir);
    if(!DirectoryExists(path))
    {
        ForceDirectories(path);
    }
    strcat(path, "\\list.txt");
    FILE* list = fopen(path, "w");
    if(!list) return 1;

    FILE *f = fopen(in_file, "rb"), *wf;
    if(!f)
    {
        fclose(list);
        return 2;
    }

    void* buf = malloc(1024*1024*2); // PSX RAM size xD
    while(count > 0)
    {
        strcpy(path, out_dir);
        strcat(path, dirs[ver][rec->b & 0x0F]);
        if(!DirectoryExists(path))
        {
           ForceDirectories(path);
        }
        decodeName(rec->b, rec->c, name);
        printf("%s%s%s\n", dirs[ver][rec->b & 0x0F], name, exts[rec->c >> 24]);
        strcat(path, name);
        strcat(path, exts[rec->c >> 24]);

        size = decodeSize(rec->a);
        fseek(f, offset, SEEK_SET);
        if(size > 0) fread(buf, size, 1, f);

        wf = fopen(path, "wb");
        if(size > 0) fwrite(buf, size, 1, wf);
        fclose(wf);

        fprintf(list, "%8.8X %8.8X %s%s%s\n", offset, size, dirs[ver][rec->b & 0x0F], name, exts[rec->c >> 24]);

        count--;
        rec++;
        offset += ((size + 0x7FF) / 0x800) * 0x800;
    }
    fclose(f);
    fclose(list);
    free(buf);
    return 0;
}

int ExtractFiles(const char* exe_file, const char *in_file, const char *out_dir)
{
    unsigned char buf[0x8000];
    FILE *f = fopen(exe_file, "rb");
    if(!f)
    {
        printf("Unable to open executable file!\n");
        return 1;
    }
    fread(buf, 128, 1, f);
    int ver = DetectRegion(buf);
    switch(ver)
    {
        case 0:
            printf("Executable detected: SLES_015.14\n");
            break;
        case 1:
            printf("Executable detected: SLUS_007.07\n");
            break;
        default:
            printf("Unknown version of game!\n");
            fclose(f);
            return 2;
    }

    fseek(f, TableOffset[ver], SEEK_SET);
    fread(buf, FileCount[ver], sizeof(FileRec), f);
    int ret = ExtractFiles((FileRec*)buf, FileCount[ver], in_file, out_dir, ver);
    return ret ? ret + 2 : 0;
}



