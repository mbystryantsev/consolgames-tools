#pragma once
#include "TextureDictionaryParser.h"
#include <FileStream.h>
#include <core.h>
#include <memory>

namespace Consolgames
{
class Stream;
class FileStream;
}

namespace ShatteredMemories
{

class TextureDictionaryParserPSP: public TextureDictionaryParser
{
public:
    TextureDictionaryParserPSP();

	virtual bool open(Consolgames::Stream* stream) override;
	virtual bool initSegment() override;
	virtual bool fetch() override;
	virtual bool atEnd() const override;
	virtual const TextureMetaInfo& metaInfo() const override;

	virtual const char* textureFormatToString(int format) const override;
	virtual const char* paletteFormatToString(int format) const override;

private:
	bool readHeader();

protected:	
	TextureMetaInfo m_currentMetaInfo;
	Consolgames::Stream* m_stream;
	int m_streamSize;
	int m_position;
	int m_currentItemSize;
};

}
