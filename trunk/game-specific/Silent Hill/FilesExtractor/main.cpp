////////////////////////////////////////////////////////////
//
//      Silent Hill Files Extractor by horror_x
//      Version 1.1, 01.11.2014
//      http://consolgames.ru/
//
////////////////////////////////////////////////////////////

#include "Silent.h"
#include <iostream>

int main(int argc, char *argv[])
{
    if (argc < 3)
    {
        std::cout <<
			"Silent Hill Files Extractor by horror_x\n"
			"http://consolgames.ru/\n"
			"Usage:\n"
			"    SHExtract.exe <ISOImage> <OutDir>\n\n";
		printSupportedVersions();
        return -2;
    }

    const bool result = extractFiles(argv[1], argv[2]);
    std::cout << (result ? "Done!" : "Error!") << std::endl;
    return result ? 0 : -1;
}
