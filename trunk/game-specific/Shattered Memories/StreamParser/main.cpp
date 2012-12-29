#include "DataStreamParserWii.h"
#include "TextureDictionaryParserWii.h"
#include <FileStream.h>

using namespace Consolgames;
using namespace ShatteredMemories;

/*
    10000000 - DXT3
    10100010 - 8BPP, 256 colors
    11000001 - 4BPP, 16 colors
*/

static size_t CalcImageDataSize(int width, int height, int mipmaps)
{
    size_t size = 0;
    while (mipmaps--)
    {
        width = max(width, 64);
        height = max(height, 64);
        size += width * height / 2;
        width /= 2;
        height /= 2;
    }
    return size;
}

/*
int replaceTextures(const char *texdir, const char *infofile, const char *datafile)
{
    char name[0x40], path[MAX_PATH], filename[MAX_PATH];
    _finddata_t rec;
    int hf, done, errors = 0;
    const ShatteredMemories::TextureInfo *p_info;

    strcpy(path, texdir);
    strcat(path, "\\*");

    cg::FileStream db_stream(datafile, CG_READ);
    if(!db_stream.opened())
    {
        puts("Database open error!\n");
        return -1;
    }
    ShatteredMemories::TexDicParserWII parser;
    ShatteredMemories::TextureDatabase db(&db_stream);
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
*/

int main(int argc, char* argv[])
{

//     replaceTextures("F:\\temp\\shsm\\data\\",
//                     "D:\\_job\\Programming\\Shattered Memories\\TextureDatabase\\test.info",
//                     "D:\\_job\\Programming\\Shattered Memories\\TextureDatabase\\test.data"
//                    );

	DataStreamParserWii parser;
	FileStream stream(L"e:\\_job\\SHSM\\wii\\test\\00000F7C.BIN", Stream::modeRead);
	ASSERT(stream.opened());
	parser.open(&stream);
	
	while (parser.initSegment())
	{
		while (parser.fetch())
		{
			if (parser.metaInfo().typeId == "rwID_TEXDICTIONARY")
			{
				FileStream dictStream(stream.filename(), Stream::modeRead);
				ASSERT(dictStream.opened());
				dictStream.seek(stream.tell(), Stream::seekSet);

				TextureDictionaryParserWii dictParser;
				dictParser.open(&stream);
				while (dictParser.initSegment())
				{
					while (dictParser.fetch())
					{
						std::cout << dictParser.metaInfo().name << std::endl;
					}
				}
			}
		}
	}

	if (!parser.atEnd())
	{
		std::cout << "WARNING: End is not reached!" << std::endl;
	}

    return 0;


}
