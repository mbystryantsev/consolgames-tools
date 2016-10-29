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


        char s1[] = "String string string...";
        char temp[1024];
        char s2[1024];

        encodeLZ(s1, strlen(s1) + 1, temp);

        return 0;







        void *data_in  = malloc(1024 * 1024 * 4),
             *data_out = malloc(1024 * 1024 * 4);
        int size, arc_size, i = 0;
        char out_file[4096];

        FILE *wf, *f;
        if(argc != 3){
            printf(
                "Princess Maker 4 data extractor by HoRRoR\n"
                "http://consolgames.ru/\n"
                "Usage: extract data.bin <OutFolder>\n"
            );
        }
        if(!(f = fopen(argv[1], "rb"))){
            printf("Unable to open input file!\n");
            return 1;
        }
        fseek(f, 0, SEEK_END);
        arc_size = ftell(f);
        fseek(f, 0, SEEK_SET);

        printf("Extracting...\n");
        while(ftell(f) < arc_size){
            fread(&size, 4, 1, f);
            fread(data_in, size, 1, f);
            size = decodeLZ(data_in, size, data_out);

            sprintf(out_file, "%s\\%8.8X.BIN", argv[2], i);
            printf("%8.8X.BIN\n", i);
            if(!(wf = fopen(out_file, "wb"))){
                printf("Unable to save file!\n");
                break;
            }
            fwrite(data_out, size, 1, wf);
            fclose(wf);

            fseek(f, (ftell(f) + 3) & -4, SEEK_SET);
            i++;
        }
        fclose(f);


        free(data_in);
        free(data_out);

        return 0;
}
//---------------------------------------------------------------------------
 