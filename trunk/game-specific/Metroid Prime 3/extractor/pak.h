#ifndef __PAK_H
#define __PAK_H

#include "Stream.h"

#pragma pack(push, 1)

typedef bool (*PProgrFunc)(int act, int val, char* str);
// if return true then abort

enum
{
        PROGR_SET_MAX,
        PROGR_SET_CUR
};

typedef char ResType[4];

typedef union
{
   unsigned __int64 i64;
   unsigned int i[2];
   unsigned char c[8];
} Hash;

struct PakHeader
{
    int tag02;
    int tag40;
    Hash hash1;
    Hash hash2;
};

struct SegmentRecord
{
    ResType res;
    unsigned int size;
};

struct FileRecord
{
    int packed;
    ResType res;
    Hash hash;
    unsigned int size;
    unsigned int offset;
};

struct CMPDHeader
{
    ResType sign;
    int type;
};

struct CMPD1
{
    unsigned unk : 8;
    unsigned lzo_size : 24;
    unsigned int file_size;
};

struct CMPD2
{
    unsigned int unk1, unk2, packed_size, data_size;
};

#pragma pack(pop)


struct NameRecord
{
        char* name;
        ResType res;
        Hash hash;
};

struct PakRec
{
    int seg_count;
    int strg;
    int rshd;
    int data;
    unsigned int strg_offset;
    unsigned int rshd_offset;
    unsigned int data_offset;
    unsigned int file_count;
    unsigned int name_count;

    SegmentRecord* segments;
    PakHeader header;
    FileRecord* files;
    NameRecord* names;
    char* names_buf;

};

bool PakExtract(CStream* pak, char* OutDir, ResType* types = 0, bool use_names = false);
bool PakExtract(char *InFile, char *OutDir, ResType* types = 0, bool use_names = false);
bool PakRebuild(CStream* in, CStream* out, char* dirs[], ResType* types = 0, PProgrFunc progress = 0);

#define ALIGN 0x40
#define CHUNK 0x4000


#endif /* __PAK_H */
