#include "TextureDictionaryParser.h"
#include <Streams/FileStream.h>

namespace ShatteredMemories
{

using namespace Consolgames;

bool TextureDictionaryParser::open(const std::wstring& filename)
{
	m_streamHolder.reset(new FileStream(filename, Stream::modeRead));
	if (!m_streamHolder->isOpen())
	{
		return false;
	}
	return open(m_streamHolder.get());
}

}
