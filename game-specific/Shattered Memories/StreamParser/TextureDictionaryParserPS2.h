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

class TextureDictionaryParserPS2: public TextureDictionaryParser
{
public:
    TextureDictionaryParserPS2();

	virtual bool open(Consolgames::Stream* stream) override;
	virtual bool initSegment() override;
	virtual bool fetch() override;
	virtual bool atEnd() const override;

	const TextureMetaInfo& metaInfo() const;
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
