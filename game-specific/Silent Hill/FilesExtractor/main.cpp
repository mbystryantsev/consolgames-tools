////////////////////////////////////////////////////////////
//
//      Silent Hill Files Extractor by HoRRoR
//      Version 0.1a, 07/10/2010
//      http://consolgames.ru/
//
////////////////////////////////////////////////////////////

#include <stdio.h>
#include <Silent.h>

int main(int argc, char *argv[])
{
    if(argc < 4)
    {
        printf(
        "Silent Hill Files Extractor by HoRRoR_X\n"
        "http://consolgames.ru/\n"
        "Usage:\n"
        "    SHExtract.exe <Executable> <SILENT> <OutDir>\n"
        );
        return 0;
    }

    printf("Extracting...\n");
    int ret = ExtractFiles(argv[1], argv[2], argv[3]);
    printf(ret ? "Error!\n" : "Done!\n");
    return ret;
}
