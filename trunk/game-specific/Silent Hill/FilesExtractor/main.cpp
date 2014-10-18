////////////////////////////////////////////////////////////
//
//      Silent Hill Files Extractor by horror_x
//      Version 0.8, 10/18/2014
//      http://consolgames.ru/
//
////////////////////////////////////////////////////////////

#include "Silent.h"
#include <iostream>

int main(int argc, char *argv[])
{
    if (argc < 4)
    {
        printf(
			"Silent Hill Files Extractor by horror_x\n"
			"http://consolgames.ru/\n"
			"Usage:\n"
			"    SHExtract.exe <Executable> <SILENT> <OutDir>\n\n"
        );
		printSupportedVersions();
        return -2;
    }

    printf("Extracting...\n");
    const bool result = extractFiles(argv[1], argv[2], argv[3]);
    printf(result ? "Error!\n" : "Done!\n");
    return result ? 0 : -1;
}
