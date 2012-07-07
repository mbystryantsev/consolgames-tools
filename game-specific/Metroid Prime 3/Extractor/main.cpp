#include <iostream>
#include "Stream.h"
#include "FileStream.h"
#include "pak.h"
#pragma hdrstop

//---------------------------------------------------------------------------

#pragma argsused

ResType types[256];// = {"TXTR", "FONT", 0};

int main(int argc, char* argv[])
{
/*
        char* dirs[] = {"F:\\_job\\Metroid Prime 3\\test\\", NULL};
        CFileStream* in = new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\FrontEnd.pak", false);
        CFileStream* out= new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\new\\FrontEnd.pak", true);
        PakRebuild(in, out, dirs, NULL);
        delete in;
        delete out;

        in = new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\GuiDVD.pak", false);
        out= new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\new\\GuiDVD.pak", true);
        PakRebuild(in, out, dirs, NULL);
        delete in;
        delete out;

        in = new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\GuiNAND.pak", false);
        out= new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\new\\GuiNAND.pak", true);
        PakRebuild(in, out, dirs, NULL);
        delete in;
        delete out;

        in = new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\NoARAM.pak", false);
        out= new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\new\\NoARAM.pak", true);
        PakRebuild(in, out, dirs, NULL);
        delete in;
        delete out;

        in = new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\InGameNAND.pak", false);
        out= new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\new\\InGameNAND.pak", true);
        PakRebuild(in, out, dirs, NULL);
        delete in;
        delete out;

        in = new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\RS5.pak", false);
        out= new CFileStream("F:\\_job\\Metroid Prime 3\\pak\\new\\RS5.pak", true);
        PakRebuild(in, out, dirs, NULL);
        delete in;
        delete out;

        return 0;
*/
        //NoARAM.pak NoARAM\ STRG
        if(strcmp(argv[1], "-e") == 0)
        {                                                             
                std::cout << "Extracting..." << std::endl;
                for(int i = 4; i < argc; i++) strncpy(types[i - 4], argv[i], 4);
                //PakExtract("F:\\_job\\Metroid Prime 3\\pak\\RS5.PAK", "F:\\_job\\Metroid Prime 3\\pak\\RS5\\", 0);
                if(PakExtract(argv[2], argv[3], argc > 4 ? types : NULL, true))
                        std::cout << "Done!" << std::endl;
                else
                        std::cout << "Error!" << std::endl;
        }
        return 0;
}
//---------------------------------------------------------------------------
 