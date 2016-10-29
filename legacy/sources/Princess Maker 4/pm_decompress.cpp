//---------------------------------------------------------------------------

#include "lz.h"
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#pragma hdrstop

//---------------------------------------------------------------------------

#pragma argsused

int main(int argc, char* argv[])
{
        if(argc != 3){
            printf(
                "Princess Maker 4 data unpacker by HoRRoR\n"
                "http://consolgames.ru/\n"
                "Usage: <SrcFile> <DestFile>\n"
            );
            return 0;
        }

        FILE *f, *wf;
        int size;

        void *data_in  = malloc(1024 * 1024 * 4),
             *data_out = malloc(1024 * 1024 * 4);
        if(!(f = fopen(argv[1], "rb"))){
            printf("Unable to open input file!\n");
            return 1;
        }
        fseek(f, 0, SEEK_END);
        size = ftell(f);
        fseek(f, 0, SEEK_SET);

        printf("Decompressing... ");
        fread(data_in, size, 1, f);
        size = decodeLZ(data_in, size, data_out);
        if(!(wf = fopen(argv[2], "wb"))){
            printf("Unable to save file!\n");
        } else {
            fopen(argv[2], "wb");
            fwrite(data_out, size, 1, wf);
            fclose(wf);
            printf("Done!\n");
        }
        free(data_in);
        free(data_out);

        return 0;
}
//---------------------------------------------------------------------------
 