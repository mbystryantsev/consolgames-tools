#include <cstdio>
#include <io.h>
#include <windows.h>
#include "TexDicParserWII.h"
#include "Streams/FileStream.h"
#include "../TextureDatabase/TextureDatabase.h"
#include <errno.h>

/*
    10000000 - DXT3
    10100010 - 8BPP, 256 colors
    11000001 - 4BPP, 16 colors
*/


size_t CalcImageDataSize(int width, int height, int mipmaps)
{
    size_t size = 0;
    while(mipmaps--)
    {
        if(width < 64) width = 64;
        if(height < 64) height = 64;
        size += width * height / 2;
        width /= 2;
        height /= 2;
    }
    return size;
}

int replaceTextures(const char *texdir, const char *infofile, const char *datafile)
{
    char name[0x40], path[MAX_PATH], filename[MAX_PATH];
    _finddata_t rec;
    int hf, done, errors = 0;
    const shsm::TextureInfo *p_info;

    strcpy(path, texdir);
    strcat(path, "\\*");

    cg::FileStream db_stream(datafile, CG_READ);
    if(!db_stream.opened())
    {
        puts("Database open error!\n");
        return -1;
    }
    shsm::TexDicParserWII parser;
    shsm::TextureDatabase db(&db_stream);
    if(!db.loadFromFile(infofile))
    {
        puts("Load database info error!\n");
        return -2;
    }


    void *tex_buf = malloc(1024 * 1024);

    hf = _findfirst(path, &rec);
    done = (hf == -1);
    while(!done)
    {
        if((rec.attrib & _A_SUBDIR) == 0)
        {
            strcpy(filename, texdir);
            strcat(filename, "\\");
            strcat(filename, rec.name);
            cg::FileStream file_stream(filename, CG_READ_WRITE);

            if(!file_stream.opened())
            {
                printf("File error: %s\n", rec.name);
                continue;
            }
            //puts(rec.name);

            if(parser.open(&file_stream))
            {
                while(parser.parse())
                {
                    parser.getImageName(name);
                    p_info = db.find(name);
                    if(p_info)
                    {
                        printf("Replacing %s in %s...", name, rec.name);
                        if((unsigned)db.readTexture(p_info, tex_buf) != p_info->size)
                        {
                            errors++;
                            puts(" FAILED!");
                        }
                        else if(parser.setImageData(tex_buf, p_info->size) <= 0)
                        {
                            errors++;
                            printf(" FAILED %d!\n", errno);
                        }
                        else
                        {
                            puts(" done!");
                        }
                    }
                }
            }
            else
            {
                // Skip...
            }
        }
        done = _findnext(hf, &rec);
    }
    if(hf != -1) _findclose(hf);
    free(tex_buf);
    return 0;
}


int main(int argc, char* argv[])
{

    replaceTextures("F:\\temp\\shsm\\data\\",
                    "D:\\_job\\Programming\\Shattered Memories\\TextureDatabase\\test.info",
                    "D:\\_job\\Programming\\Shattered Memories\\TextureDatabase\\test.data"
                   );
    return 0;


}
