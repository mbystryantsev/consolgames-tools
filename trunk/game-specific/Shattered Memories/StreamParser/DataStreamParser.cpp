#include <string.h>
#include "DataStreamParser.h"
#include "Streams/FileStream.h"

namespace ShatteredMemories
{

const int DataStreamParser::s_dataStreamId = 0x716;

bool DataStreamParser::MetaInfo::isNull()
{
	return typeId.empty();
}

void DataStreamParser::MetaInfo::clear()
{
	*this = MetaInfo();
}

}
