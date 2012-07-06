#include <iostream>
#include <cstdlib>
#include <stdio.h>
#include "nvimage/image.h"
#include "dxt1.h"
#include "pnglite/pnglite.h"
#include <string.h>
//#include "miniLZO/minilzo.h"
//#include "nvimage/BlockDXT.h"
//#include "nvimage/ColorBlock.h"


/*
inline void endian_swap_s(unsigned short& x)
{
    x = (x>>8) |
        (x<<8);
}
*/

inline void endian_swap_s(short& x)
{
    x = (( (unsigned)x >> 8) & 0xFF) |
        (( (unsigned)x << 8) & 0xFF00);
}

/*
inline void endian_swap(unsigned int& x)
{
    x = (x>>24) |
        ((x<<8) & 0x00FF0000) |
        ((x>>8) & 0x0000FF00) |
        (x<<24);
}
*/

inline void endian_swap(int& x)
{
    x = ((unsigned)x>>24) |
        (((unsigned)x<<8) & 0x00FF0000) |
        (((unsigned)x>>8) & 0x0000FF00) |
        ((unsigned)x<<24);
}

#pragma pack(push, 1)

struct TexHeader
{
    int tex_type;
    short width, height;
    int mipmap_count;
};

#pragma pack(pop)

using namespace std;


void PrintUsage()
{
    cout << "Metroid Prime 3 Texture Converter by HoRRoR\n"
            "http://consolgames.ru/\n"
            "Usage:\n"
            "  -d <InTexture> <OutImage> - decode texture to image\n"
            "  -e <InImage> <OutTexture> [MipmapCount] - encode image into texture\n";
}

bool SavePNG(void* image, int w, int h, char* filename)
{
    png_t png;
    if(png_open_file_write(&png, filename) != PNG_NO_ERROR) return false;
    png_set_data(&png, w, h, 8, PNG_TRUECOLOR_ALPHA, (unsigned char*)image);
    png_close_file(&png);
    return true;
}

int getEncodedSize(int w, int h, int m)
{
    int s;
    while(m > 0)
    {
        s += w * h / 2;
        m--;
        w /= 2;
        h /= 2;
        if(w < 32) w = 32;
        if(h < 32) h = 32;
    }
    return s;
}

int main(int argc, char *argv[])
{
    if(argc < 4)
        PrintUsage();
    else
    if(strcmp(argv[1], "-d") == 0)
    {
        int ret = 0;
        TexHeader header;
        FILE * f = fopen(argv[2], "rb");
        if(!f)
        {
            cout << "Error opening file!\n";
            return -1;
        }
        fread(&header, sizeof(header), 1, f);
        endian_swap(header.tex_type);
        if(header.tex_type != 10)
        {
            cout << "Unsupported texture type (" << header.tex_type << "), supported only dxt1 (10)" << endl;
            fclose(f);
            return -1;
        }
        endian_swap_s(header.width);
        endian_swap_s(header.height);

        int size = header.width * header.height / 2;
        if(size <= 0)
        {
            cout << "Invalid image size!" << endl;
            fclose(f);
        }

        void *buf = malloc(size), *image = malloc(header.width * header.height * 4);
        fread(buf, size, 1, f);
        fclose(f);

        DecodeDXT1(buf, image, header.width, header.height);

        png_init(0, 0);
        if(!SavePNG(image, header.width, header.height, argv[3]))
        {
            cout << "Error saving image!" << endl;
            ret = -1;
        }


        free(buf);
        free(image);

        if(ret == 0)
            cout << "Done!" << endl;
        return ret;
    }
    else
    if(strcmp(argv[1], "-e") == 0)
    {
        nv::Image image;
        int mipmaps = 1;

        if(argc > 4)
            mipmaps = atoi(argv[4]);

        if(!image.load(argv[2]))
        {
            cout << "Error loading image!" << endl;
            return -1;
        }

        TexHeader header;
        header.width = image.width();
        header.height = image.height();
        header.tex_type = 10;
        header.mipmap_count = mipmaps;

        endian_swap_s(header.width);
        endian_swap_s(header.height);
        endian_swap(header.tex_type);
        endian_swap(header.mipmap_count);


        void *buf = malloc(getEncodedSize(image.width(), image.height(), mipmaps));
        int size = EncodeDXT1(image.pixels(), buf, image.width(), image.height(), mipmaps);

        FILE* f = fopen(argv[3], "wb");
        if(!f)
        {
            cout << "Error saving file!" << endl;
            free(buf);
            return -1;
        }
        fwrite(&header, sizeof(header), 1, f);
        fwrite(buf, size, 1, f);
        fclose(f);
        free(buf);

        cout << "Done!" << endl;
    }
    else
        PrintUsage();

    return 0;
}

