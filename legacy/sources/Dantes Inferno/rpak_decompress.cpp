//---------------------------------------------------------------------------


#define RPAK_DEBUG

#include <stdio.h>
#include "rpak.h"
#include <windows.h>
#pragma hdrstop

//---------------------------------------------------------------------------

unsigned char inbuf[1024*1024 * 16], outbuf[1024*1024 * 4];

void __stdcall progress(int i, int size){
    printf("%d/%d\r", i, size);
}

#pragma argsused

void PrintUsage(){
    printf(
        "RPAK archiver by HoRRoR\n"
        "http://consolgames.ru/\n"
        "Usage:\n"
        "rpak -d <RpakFile> <OutFile>\n"
        "rpak -c <OutFile> <RpakFile>\n"
    );
}

int main(int argc, char* argv[])
{
     
    if(argc != 4){
        PrintUsage();
        return 0;
    }


    FILE *f;
    int inlen, outlen;

    if(strcmp(argv[1], "-d") == 0){
        printf("Decompressing... ");
        f = fopen(argv[2], "rb");
        fseek(f, 0, SEEK_END);
        inlen = ftell(f);
        fseek(f, 0, SEEK_SET);
        fread(inbuf, inlen, 1, f);
        fclose(f);

        outlen = RDecompress(inbuf, outbuf);
        f = fopen(argv[3], "wb");
        fwrite(outbuf, outlen, 1, f);
        fclose(f);
        printf("done!\n");
    } else
    if(strcmp(argv[1], "-c") == 0){
        printf("Compressing...\n");
        f = fopen(argv[2], "rb");
        fseek(f, 0, SEEK_END);
        inlen = ftell(f);
        fseek(f, 0, SEEK_SET);
        fread(inbuf, inlen, 1, f);
        fclose(f);

        outlen = RCompress(inbuf, inlen, outbuf, &progress);
        f = fopen(argv[3], "wb");
        fwrite(outbuf, outlen, 1, f);
        fclose(f);
        printf("Done!\n");
    } else {
        PrintUsage();
    }



/************************/


/*

        int inlen, outlen;
        FILE* f = fopen("arc\\hash5", "rb");
        fseek(f, 0, SEEK_END);
        inlen = ftell(f);
        fseek(f, 0, 0);
        fread(inbuf, inlen, 1, f);
        fclose(f);

        outlen = RDecompress(inbuf, outbuf);

        f = fopen("arc\\hash5.bin", "wb");
        fwrite(outbuf, outlen, 1, f);
        fclose(f);

        printf("%2.2X\n", max_c);
        system("PAUSE");

        return 0;

*/



/*
        char src[] = "123 33333333333333333333333333333333333333333333333333333333";
        char dest[1024] = "";
        char temp[1024];
        //unsigned char *in = src + 3, *out = dest, *last = src;
        //int rem = store(&in, &out, &last);

         memset(temp, 0, 1024);
        //int back;
        //int count = FindChain(src + 3, src, src + 21, &back);
        printf("Data size: %d\n", strlen(src) + 1);
        int size = RCompress(src, strlen(src) + 1, temp, &progress);

        FILE* f = fopen("compress_test", "wb");
        fwrite(temp, size, 1, f);
        fclose(f);


        RDecompress(temp, dest);


        printf("%s\n", dest);
        printf("Compare = %d\n", strcmp(src, dest));
*/

        return 0;
}
//---------------------------------------------------------------------------

