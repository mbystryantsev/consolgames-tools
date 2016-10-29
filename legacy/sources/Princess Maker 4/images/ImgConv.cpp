#include <iostream.h>    
//#include <windows.h>
#include <io.h>
#include "pnglite.h"
#include "image.h"

void PrintUsage(){
        printf(
                "Princess Maker 4 Image Converter by HoRRoR\n"
                "http://consolgames.ru/\n"
                "Usage:\n"
                "  ImgConv -<d|e>   <InFile> <OutFile>\n"
                "  ImgConv -<dd|ed> <InDir>  <OutDir>\n"
                "  -d  - decode image to PNG\n"
                "  -e  - encode image from PNG\n"
                "  -dd - decode all images to PNG files\n"
                "  -ed - encode all images from PNG files\n"
        );
}

int decodeFile(char* in_file, char* out_file, void* in_buf, void* img_buf){
    FILE* f = fopen(in_file, "rb");
    png_t png;
    int ret = 1;
    int width, height;
    if(f){
        width = height = 0;
        fread(&width,  2, 1, f);
        fread(&height, 2, 1, f);
        fseek(f, 0, SEEK_END);
        int size = ftell(f);
        if(size == width * height * 2 + width * height + 4 || size == width * height * 2 + 4){
            fseek(f, 0, SEEK_SET);
            fread(in_buf, size, 1, f);
            decodeImage(in_buf, img_buf, width, height, size == width * height * 2 + width * height + 4);
            if(png_open_file_write(&png, out_file) == PNG_NO_ERROR){
                png_set_data(&png, width, height, 8, PNG_TRUECOLOR_ALPHA, (char*)img_buf);
                png_close_file(&png);
            } else {
              ret = 0;
            }
        } else {
            ret = 0;
        }
        fclose(f);
        return ret;
    } else {
        return 0;
    }
}

int encodeFile(char* in_file, char* out_file, void* buf, void* img_buf){
    png_t png;
    int width, height, size;
    if(png_open_file_read(&png, in_file) == PNG_NO_ERROR){
        png_get_data(&png, (unsigned char*)img_buf);
        png_close_file(&png);
    } else {
        return 0;
    }
    size = encodeImage(img_buf, buf, png.width, png.height);
    FILE *f = fopen(out_file, "wb");
    if(f){
        fwrite(buf, size, 1, f);
        fclose(f);
        return 1;
    } else {
        return 0;
    }
}

int main(int argc, char* argv[])
{
    int size, width, height;

    if(argc != 4){
        PrintUsage();
        return 0;
    }
    
    void *buf = malloc(1024*1024);
    void *data = malloc(1024 * 1024 * 4);
    _finddata_t FindRec;
    int hFile, done;
    char filename[1024], outfile[1024];

    png_init(0, 0);

    if(strcmp(argv[1], "-dd") == 0){
        sprintf(filename, "%s\\*", argv[2]);
        hFile = _findfirst(filename, &FindRec);
        done = hFile == -1;
        while (!done)
        {
            if(!((FindRec.attrib & _A_SUBDIR) || FindRec.size < 6)){

                sprintf(filename, "%s\\%s", argv[2], FindRec.name);
                sprintf(outfile,  "%s\\%s", argv[3], FindRec.name);
                memcpy(outfile + strlen(outfile) - 3, "PNG", 3);
                if(decodeFile(filename, outfile, buf, data)){
                    printf("Decoded file: %s\n", FindRec.name);
                }

            }
            done = _findnext(hFile, &FindRec);
        }
        if(hFile != -1){
            _findclose(hFile);
        }
        printf("Done!\n");
    } else if (strcmp(argv[1], "-ed") == 0){  
        sprintf(filename, "%s\\*.PNG", argv[2]);
        hFile = _findfirst(filename, &FindRec);
        done = hFile == -1;
        while (!done)
        {
            if(!((FindRec.attrib & _A_SUBDIR) || FindRec.size < 6)){
                sprintf(filename, "%s\\%s", argv[2], FindRec.name);
                sprintf(outfile,  "%s\\%s", argv[3], FindRec.name);
                memcpy(outfile + strlen(outfile) - 3, "BIN", 3);
                if(encodeFile(filename, outfile, buf, data)){
                    printf("Encoded file: %s\n", FindRec.name);
                }

            }
            done = _findnext(hFile, &FindRec);
        }
        if(hFile != -1){
            _findclose(hFile);
        }
        printf("Done!\n");
    } else if (strcmp(argv[1], "-d") == 0){
        printf("Decoding file... ");
        if(decodeFile(argv[2], argv[3], buf, data)){
            printf("done!");
        } else {
            printf("failed!");
        }
    } else if (strcmp(argv[1], "-e") == 0){
        printf("Encoding file... ");
        if(encodeFile(argv[2], argv[3], buf, data)){
            printf("done!");
        } else {
            printf("failed!");
        }
    } else {
        PrintUsage();
    }


    free(data);
    free(buf);
    return 0;
}

