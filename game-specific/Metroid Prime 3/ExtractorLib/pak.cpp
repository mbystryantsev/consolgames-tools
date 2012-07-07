#include "pak.h"
#include "miniLZO/minilzo.h"
#include <FileStream.h>
#include <stdio.h>
#include <io.h>
#include <algorithm>

using namespace Consolgames;

#define endian(v) (((unsigned int)v >> 24) | (((unsigned int)v >> 8) & 0xFF00) | (((unsigned int)v << 8) & 0xFF0000) | ((unsigned int)v << 24))
#define endianw(v) ((v >> 8) | (v << 8))

int FindSegment(SegmentRecord* segments, int count, ResType type)
{
    for(int i = 0; i < count; i++)
    {
        if(strncmp(segments[i].res, type, 4) == 0) return i;
    }
    return -1;
}

int GetSegmentOffset(SegmentRecord* segments, int index)
{
    int result = 0;
    for(int i = 0; i < index; i++)
    {
        result += segments[i].size;
    }
    return result;
}

bool InTypes(ResType res, ResType *types)
{
    while(*(int*)*types)
    {
        if(*(int*)(&res[0]) == *(int*)&types[0][0]) return true;
        types++;
    }
    return false;
}

void HashToStr(Hash hash, char* str)
{
    for(int i = 0; i < 8; i++)
    {
        sprintf(&str[i * 2], "%2.2X", hash.c[i]);
    }
}

void ExtractFile(Stream* stream, int size, bool packed, Stream* out, unsigned char *wrk_mem)
{
    unsigned char *buf = wrk_mem;
    unsigned char *u_buf = &wrk_mem[65536];
    __int64 pos = stream->tell();

    //packed = false;

    if(packed)
    {
        CMPDHeader header;
        CMPD1 cmpd1;
        //CMPD2 cmpd2;
        stream->read(&header, sizeof(header));
        header.type = endian(header.type);
        int lzo_size;
        unsigned long size;
        unsigned short chunk;
        //int ololo;
        switch(header.type)
        {
            case 1:
                stream->read(&cmpd1, sizeof(cmpd1));
                //cmpd1.lzo_size = endianw(cmpd1.lzo_size);
                cmpd1.file_size = endian(cmpd1.file_size);
                lzo_size = endian((unsigned int)cmpd1.lzo_size << 8) & 0xFFFFFF;
                while(lzo_size > 0)
                {
                    stream->read(&chunk, 2);
                    lzo_size -= 2;
                    chunk = endianw(chunk);
                    stream->read(buf, chunk);
                    lzo_size -= chunk;
                    lzo1x_decompress(buf, chunk, u_buf, &size, NULL);
                    out->write(u_buf, size);

                }
                break;
            case 2:
                stream->read16();
                stream->read16();
                unsigned int lzo_size, data_size;
                lzo_size = stream->read16();
                lzo_size = endian(lzo_size);
                data_size = stream->read16();
                data_size = endian(data_size);
                bool packed = ((lzo_size & 0x80000000) != 0);
                out->writeStream(stream, 12);
                if(!packed)
                {
                        out->writeStream(stream, data_size);
                }
                else
                {
                        unsigned char *lzo_buf = (unsigned char *)malloc(lzo_size);
                        unsigned char *data_buf = (unsigned char *)malloc(data_size);
                        size = data_size;
	                lzo1x_decompress(lzo_buf, lzo_size, data_buf, &size, wrk_mem);
                        out->write(data_buf, data_size);
                        free(lzo_buf);
                        free(data_buf);
                }
                //stream->seek(pos, 0);
                //goto e;

                //stream->read(&cmpd2, sizeof(cmpd2));
                //break;
        }
    }
    else
    {
        out->writeStream(stream, size);
    }

}

unsigned int compress_lzo(Stream* in, int size, Stream *out, unsigned char* wrk_mem)
{
    unsigned int lzo_size = 0;  
    unsigned char *buf = &wrk_mem[0x10000], *dst = &wrk_mem[0x18000];
    while (size > 0)
    {
        int chunk = min(CHUNK, size);
        unsigned long lzo_chunk;
        unsigned short lzo_chunk_e;
        size -= chunk;
        in->read(buf, chunk);
        lzo1x_1_compress(buf, chunk, dst, &lzo_chunk, wrk_mem);
        lzo_size += lzo_chunk + 2;
        lzo_chunk_e = endianw(lzo_chunk);
        out->write(&lzo_chunk_e, 2);
        out->write(dst, lzo_chunk);
    }
    return lzo_size;
        
}

unsigned int StoreFile(Stream* file, Stream* stream, bool packed, bool tex, unsigned char *wrk_mem)
{
    int size = file->size();
    if(packed)
    {
        CMPDHeader header;
        CMPD1 cmpd1;
        CMPD2 cmpd2;
        strncpy(&header.sign[0], "CMPD", 4);
        header.type = tex ? 0x2000000 : 0x1000000;  
        __int64 offset = stream->tell();
        unsigned int lzo_size = 0;    
        unsigned char *buf = &wrk_mem[0x10000], *dst = &wrk_mem[0x18000];
        if(!tex)
        {              
            cmpd1.unk = 0xA0;
            cmpd1.file_size = endian(size);    
            stream->seek(offset + sizeof(CMPDHeader) + sizeof(CMPD1), Stream::seekSet); 
            //unsigned int lzo_size = 0;
            while(size > 0)
            {
                int chunk = min(CHUNK, size);
                unsigned long lzo_chunk;
                unsigned short lzo_chunk_e;
                size -= chunk;
                file->read(buf, chunk);
                lzo1x_1_compress(buf, chunk, dst, &lzo_chunk, wrk_mem);
                lzo_size += lzo_chunk + 2;
                lzo_chunk_e = endianw(lzo_chunk);
                stream->write(&lzo_chunk_e, 2);
                stream->write(dst, lzo_chunk);
            }
            cmpd1.lzo_size = endian((lzo_size << 8));    
            stream->seek(offset, Stream::seekSet);
            stream->write(&header, sizeof(header));
            stream->write(&cmpd1, sizeof(cmpd1));  
            lzo_size += sizeof(CMPDHeader) + sizeof(CMPD1);
        } else
        {
            size -= 12;
            cmpd2.data_size = endian(size);
            cmpd2.unk1 = cmpd2.unk2 = 0x0C000000;
            //unsigned char *data_buf = (unsigned char*)malloc(size);
            //unsigned char *lzo_buf = (unsigned char*)malloc(size + size / 8);

            int s[3];
            file->read(s, 12);
            //file->read(data_buf, size);
            //file->seek(0, 0);


            stream->seek(offset + sizeof(CMPDHeader) + sizeof(CMPD2) + 12, Stream::seekSet);
            //lzo1x_1_compress(data_buf, size, lzo_buf, (unsigned long*)&lzo_size, wrk_mem);
            lzo_size = compress_lzo(file, size, stream, wrk_mem);

            cmpd2.packed_size = endian(lzo_size) | 0xC0;
            
            stream->seek(offset, Stream::seekSet);
            stream->write(&header, sizeof(header));
            stream->write(&cmpd2, sizeof(cmpd2));
            stream->write(s, 12);
            //stream->write(lzo_buf, lzo_size);

            //free(data_buf);
            //free(lzo_buf);

            lzo_size += sizeof(CMPDHeader) + sizeof(CMPD2) + 12;
        }
        stream->seek(offset + lzo_size, Stream::seekSet);
        size = ((lzo_size + (ALIGN - 1)) / ALIGN) * ALIGN;
        size -= lzo_size;
        lzo_size += size;
        if(size > 0)
        {
            memset(buf, 0xFF, size);
            stream->write(buf, size);
        }
        return lzo_size;
    }
    else
    {
        unsigned char buf[ALIGN];
        stream->writeStream(file, size);
        int free_size = ((size + (ALIGN - 1)) / ALIGN) * ALIGN;
        free_size -= size;
        if(free_size > 0)
        {
            memset(buf, 0xFF, free_size);
            stream->write(buf, free_size);
        }
        return size;
    }
}

unsigned int StoreFile(char* filename, Stream* stream, bool packed, bool tex, unsigned char *wrk_mem)
{
    FileStream file(filename, Stream::modeRead);
    return StoreFile(&file, stream, packed, tex, wrk_mem);
}

void EndianFiles(FileRecord* files, int file_count)
{
    for(int i = 0; i < file_count; i++)
    {
        files[i].packed = endian(files[i].packed);
        files[i].size = endian(files[i].size);
        files[i].offset = endian(files[i].offset);
    }
}

bool OpenPak(Stream* pak, PakRec* p)
{
    //char temp[1024];


    p->names = 0;
    p->files = 0;    
    p->segments = 0;
    p->names_buf = 0;
    
    pak->seek(0, Stream::seekSet);
    pak->read(&p->header, sizeof(PakHeader));
    pak->seek(ALIGN, Stream::seekSet);
    p->seg_count = pak->read16();
    p->seg_count = endian(p->seg_count);
    p->segments = new SegmentRecord[p->seg_count];

    //sprintf(temp, "Segments: %d", p->seg_count);
    //MessageBox(NULL, temp, "", 0);

    pak->read(p->segments, p->seg_count * sizeof(SegmentRecord));
    for(int i = 0; i < p->seg_count; i++) p->segments[i].size = endian(p->segments[i].size);

    p->strg = -1;
    p->rshd = -1;
    p->data = -1;
    p->strg_offset = 0;
    p->rshd_offset = 0;
    p->data_offset = 0;

    if((p->strg = FindSegment(p->segments, p->seg_count, "STRG")) >= 0)
    {
        p->strg_offset = GetSegmentOffset(p->segments, p->strg);
    }
    else
    {
        return false;
    }
    if((p->rshd = FindSegment(p->segments, p->seg_count, "RSHD")) < 0)
    {
        return false;
    }
    if((p->data = FindSegment(p->segments, p->seg_count, "DATA")) < 0)
    {
        return false;
    }
    p->strg_offset = GetSegmentOffset(p->segments, p->strg) + ALIGN * 2;
    p->rshd_offset = GetSegmentOffset(p->segments, p->rshd) + ALIGN * 2;
    p->data_offset = GetSegmentOffset(p->segments, p->data) + ALIGN * 2;

	pak->seek(p->rshd_offset, Stream::seekSet);
    p->file_count = pak->read16();
    p->file_count = endian(p->file_count);


    //sprintf(temp, "Files: %d", p->file_count);
    //MessageBox(NULL, temp, "", 0);

    p->files = new FileRecord[p->file_count];
    pak->read(p->files, sizeof(FileRecord) * p->file_count);
    EndianFiles(p->files, p->file_count);

    pak->seek(p->strg_offset, Stream::seekSet);
    p->name_count = pak->read16();
    p->name_count = endian(p->name_count);
    if(p->name_count > 0)
    {
        p->names = new NameRecord[p->name_count];
        p->names_buf = (char*)malloc(p->segments[p->strg].size);
        pak->read(p->names_buf, p->segments[p->strg].size - 4);
        char* c = p->names_buf;
        for(int i = 0; i < p->name_count; i++)
        {
                p->names[i].name = c;
                c += strlen(c) + 1;
                *(int*)(&p->names[i].res[0]) = *(int*)c;
                c += 4;
                memcpy(&p->names[i].hash, c, 8);
                c += 8;
        }
    }

    return true;
}

void FreePak(PakRec* p)
{
        if(p->segments) delete []p->segments;
        if(p->files)    delete []p->files;
        if(p->names)    delete []p->names;
        if(p->names_buf) free(p->names_buf);
}

char* FindName(Hash hash, PakRec* p)
{
        for(int i = 0; i < p->name_count; i++)
        {
                if(strncmp((char*)&hash, (char*)&p->names[i].hash, 8) == 0)
                {
                        return p->names[i].name;
                }
        }

        return NULL;
}

bool PakExtract(Stream* pak, char* OutDir, ResType* types, bool use_names)
{
    unsigned char *wrk_mem = (unsigned char*)malloc(1024 * 1024 + 65536);
    char path[MAX_PATH];

    PakRec p;
    OpenPak(pak, &p);

    for(int i = 0; i < p.file_count; i++)
    {
        //files[i].packed = endian(files[i].packed);
        //files[i].size = endian(files[i].size);
        //files[i].offset = endian(files[i].offset);
        if(types == NULL || InTypes(p.files[i].res, types))
        {
            char hash_str[17];
            char res_str[5];
            for(int j = 0; j < 8; j++)
            {
                sprintf(&hash_str[j * 2], "%2.2X", p.files[i].hash.c[j]);
            }
            strncpy(res_str, p.files[i].res, 4);
            res_str[4] = hash_str[16] = 0;
            printf("[%d/%d] %s.%s\n", i + 1, p.file_count, hash_str, res_str);

            pak->seek(p.data_offset + p.files[i].offset, Stream::seekSet);
            char *name;
            if(use_names && (name = FindName(p.files[i].hash, &p)))
                sprintf(path, "%s%s.%s", OutDir, name, res_str);
            else
                sprintf(path, "%s%s.%s", OutDir, hash_str, res_str);
          
			FileStream stream(path, Stream::modeWrite);
            ExtractFile(pak, p.files[i].size, p.files[i].packed, &stream, wrk_mem);
          }
    }

    free(wrk_mem);
    //delete []files;
    //delete []segments;
    FreePak(&p);
    return true;
}

bool FindFile(char* dirs[], Hash hash, ResType res, char* filename)
{
    char path[MAX_PATH];
    int i = 0;
    while(dirs[i])
    {
        strcpy(path, dirs[i]);
        HashToStr(hash, &path[strlen(path)]);
        strncat(path, ".", 1);
        strncat(path, &res[0], 4);
        if(access(path, 0) == 0)
        {
            strcpy(filename, path);
            return true;
        }
        i++;
    }
    return false;
}

bool PakRebuild(Stream* in, Stream* out, char* dirs[], ResType* types, PProgrFunc progress)
{
    PakRec p;
    if(!OpenPak(in, &p))
    {
        FreePak(&p);
        return false;
    }

    //MessageBox(NULL, "Pak opened", "", 0);

    if(progress) progress(PROGR_SET_MAX, p.file_count, NULL);
    unsigned char *wrk_mem = (unsigned char*)malloc(0x20000);

    unsigned int offset = p.data_offset;

    FileRecord *files = new FileRecord[p.file_count];
    char filename[MAX_PATH];


    for(int i = 0; i < p.file_count; i++)
    {     
        if(progress) progress(PROGR_SET_CUR, i, NULL);
        files[i] = p.files[i];
        files[i].offset = offset - p.data_offset;
        out->seek(offset, Stream::seekSet);
        if((types == NULL || InTypes(files[i].res, types)) && FindFile(dirs, files[i].hash, files[i].res, filename))
        {
            files[i].size = StoreFile(filename, out, files[i].packed, strncmp(&files[i].res[0], "TXTR", 4) == 0, wrk_mem);
        }
        else
        {
            in->seek(p.files[i].offset + p.data_offset, Stream::seekSet);
            out->writeStream(in, files[i].size);
        }
        offset += files[i].size;
        offset = ((offset + (ALIGN - 1)) / ALIGN) * ALIGN;
    }
    free(wrk_mem);

    out->seek(0, Stream::seekSet);
    out->write(&p.header, sizeof(p.header));
    out->seek(ALIGN, Stream::seekSet);
    int seg_count = endian(p.seg_count);
    out->write(&seg_count, 4);
    SegmentRecord* segments = new SegmentRecord[p.seg_count];
    for(int i = 0; i < p.seg_count; i++)
    {
        *(int*)&segments[i].res = *(int*)&p.segments[i].res;
        segments[i].size = endian(p.segments[i].size);
    }
    segments[p.data].size = endian(offset - p.data_offset);
    out->write(segments, p.seg_count * sizeof(SegmentRecord)); 
    delete []segments; 

                                     
    out->seek(p.rshd_offset, Stream::seekSet);
    int file_count = endian(p.file_count);
    out->write(&file_count, 4);
    EndianFiles(files, p.file_count);
    out->write(files, p.file_count * sizeof(FileRecord));
    delete []files;

    in->seek(p.strg_offset, Stream::seekSet);
    out->seek(p.strg_offset, Stream::seekSet);
    out->writeStream(in, p.segments[p.strg].size); 

    FreePak(&p);

    if(progress) progress(PROGR_SET_CUR, p.file_count, NULL);

    return true;
}

bool PakExtract(char *InFile, char *OutDir, ResType* types, bool use_names)
{
    FileStream stream(InFile, Stream::modeRead);
    return PakExtract(&stream, OutDir, types, use_names);
}
