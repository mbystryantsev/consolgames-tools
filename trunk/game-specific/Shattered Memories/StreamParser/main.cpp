#include "DataStreamParserWii.h"
#include "TextureDictionaryParserWii.h"
#include <FileStream.h>
#include <QtFileStream.h>
#include <iomanip>
#include <QDir>
#include <QTextStream>

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

QString hashToStr(quint32 hash)
{
	return QString::number(hash, 16).toUpper().rightJustified(8, '0');
}

bool parseDictionary(Stream& stream, quint32 fileHash, QTextStream& csv)
{
	ASSERT(stream.opened());
	TextureDictionaryParserWii dictParser;
	dictParser.open(&stream);

	bool atLeastOneParsed = false;
	if (dictParser.initSegment())
	{
		atLeastOneParsed = true;
		while (dictParser.fetch())
		{
			const TextureDictionaryParser::TextureMetaInfo& info = dictParser.metaInfo();
			//std::cout << info.name << ';' << std::dec << info.width << ';' << info.height << ';' << info.mipmapCount << ';' << std::hex << info.rasterPosition << ';' << info.rasterSize << std::endl;
			csv << hashToStr(fileHash) << ';' << QString::fromStdString(info.name) << ';' << info.width << ';' << info.height << ';' << info.mipmapCount << ';' << QString::number(info.rasterPosition, 16) << ';' << QString::number(info.rasterSize, 16) << '\n';
		}
	}

	return atLeastOneParsed;
}

bool parseStream(Stream& stream, quint32 fileHash, QTextStream& csv)
{
	DataStreamParserWii parser;

	ASSERT(stream.opened());
	parser.open(&stream);

	bool atLeastOneParsed = false;
	while (parser.initSegment())
	{
		if (parser.metaInfo().typeId == "rwID_TEXDICTIONARY")
		{
			while (parser.fetch())
			{
				atLeastOneParsed = true;
				parseDictionary(stream, fileHash, csv);
			}

			if (atLeastOneParsed && !parser.atSegmentEnd())
			{
				std::cout << "WARNING: Segment end is not reached! " << std::hex << stream.position() << " != " << parser.nextSegmentPosition() << std::endl;
			}
		}
	}

	if (atLeastOneParsed && !parser.atEnd())
	{
		std::cout << "WARNING: End is not reached! " << std::hex << stream.position() << " != " << stream.size() << std::endl;
	}

	return atLeastOneParsed;
}

int main(int argc, char* argv[])
{
	QFile csv("test.csv");
	VERIFY(csv.open(QIODevice::WriteOnly | QIODevice::Text));
	QTextStream csvStream(&csv);
	csvStream << "fileHash;textureName;width;height;mipmapCount;rasterPosition;rasterSize\n";

	QDir dir("E:/_job/SHSM/wii/test");
	const QStringList files = dir.entryList(QDir::Files);
	foreach (const QString& file, files)
	{
		if (file == "B1A96880.BIN")
		{
			continue;
		}
		if (file.right(4).toLower() != ".bin")
		{
			continue;
		}

		bool ok = false;
		const quint32 hash = file.left(8).toUInt(&ok, 16);
		if (!ok)
		{
			continue;
		}

		//std::cout << "Trying to parse file: " << file.toLatin1().constData() << std::endl;

		QtFileStream stream(dir.absoluteFilePath(file), QIODevice::ReadOnly);
		//QtFileStream stream(dir.absoluteFilePath("CB3596FE.BIN"), QIODevice::ReadOnly);
		ASSERT(stream.opened());

		if (stream.read32() == 0xE0FFD8FF)
		{
			stream.file().close();
			dir.rename(file, file.left(file.length() - 4) + ".jpg");
			DLOG << "Renamed " << file;
			continue;
		}
		stream.seek(0, Stream::seekSet);

		bool parsed = parseDictionary(stream, hash, csvStream);
		if (!parsed)
		{
			stream.seek(0, Stream::seekSet);
			parsed = parseStream(stream, hash, csvStream);
		}
		if (!parsed)
		{
			DLOG << "FILE NOT PARSED: " << file;
		}
	}
    return 0;
}
