#include <FileStream.h>
#include "DataStreamParser.h"

LOG_CATEGORY("StreamParserLib.DataStreamParser");

using namespace Consolgames;

namespace ShatteredMemories
{

const uint32 DataStreamParser::s_dataStreamId = 0x716;
const uint32 DataStreamParser::s_segmentHeaderSize = 12;

bool DataStreamParser::MetaInfo::isNull()
{
	return typeId.empty();
}

void DataStreamParser::MetaInfo::clear()
{
	*this = MetaInfo();
}

DataStreamParser::DataStreamParser(Stream::ByteOrder byteOrder)
	: m_stream(NULL)
	, m_segmentSize(0) 
	, m_position(0) 
	, m_startStreamPosition(0)
	, m_nextItemPosition(0)
	, m_currSegmentPosition(0)
	, m_nextSegmentPosition(0)
	, m_currentItemSize(0)
	, m_byteOrder(byteOrder)
	, m_isFirstSegment(true)
{
}

bool DataStreamParser::fetch()
{
	if (m_nextItemPosition == 0)
	{
		m_nextItemPosition = m_position;
	}

	m_position = m_nextItemPosition;
	m_stream->seek(m_startStreamPosition + m_currSegmentPosition + m_nextItemPosition, Stream::seekSet);

	if (m_position >= totalSegmentSize())
	{
		if (m_position > totalSegmentSize())
		{
			DLOG << "WARNING: Segment overread!";
		}

		return false;
	}

	//DLOG << "Item position " << HEX << m_stream->position();

	m_stream->setByteOrder(m_byteOrder);

	m_currentItemSize = m_stream->readUInt32();
	m_position += 4;

	const int alignedItemSize = (m_currentItemSize % 4 == 0) ? m_currentItemSize : m_currentItemSize + (4 - (m_currentItemSize % 4));
	m_nextItemPosition = m_position + alignedItemSize;

	return true;
}

bool DataStreamParser::atEnd() const 
{
	return m_stream->atEnd();
}

const DataStreamParser::MetaInfo& DataStreamParser::metaInfo() const 
{
	return m_currentMetaInfo;
}

const DataStreamParser::SegmentInfo& DataStreamParser::segmentInfo() const
{
	return m_currentSegmentInfo;
}

bool DataStreamParser::open(const std::wstring& filename)
{
	m_streamHolder.reset(new FileStream(filename, Stream::modeRead));
	if (!m_streamHolder->isOpen())
	{
		return false;
	}
	return open(m_streamHolder.get());
}

bool DataStreamParser::open(Stream* stream)
{
	m_stream = stream;
	return true;
}

bool DataStreamParser::initSegment()
{
	m_currentMetaInfo.clear();

	m_stream->setByteOrder(Stream::orderLittleEndian);

	m_nextItemPosition = 0;
	if (m_isFirstSegment)
	{
		m_startStreamPosition = m_stream->position();
		m_isFirstSegment = false;
	}
	else
	{
		m_position = 0;
		m_currSegmentPosition = m_nextSegmentPosition;
		const offset_t segmentPos = m_startStreamPosition + m_nextSegmentPosition;
		if (m_stream->seek(segmentPos, Stream::seekSet) != segmentPos)
		{
			return false;
		}
	}

	//DLOG << "New segment at " << HEX << m_stream->position();

	const int signature = m_stream->readUInt32();
	if (signature != 0 && (signature & 0x0F00) != 0x0700)
	{
		//DLOG << "Invalid signature: " << HEX << signature;
		return false;
	}
	
	m_segmentSize = m_stream->readUInt32();

	m_currentSegmentInfo.signature = signature;
	m_currentSegmentInfo.size = m_segmentSize;
	m_currentSegmentInfo.unk1 = m_stream->readUInt16();
	m_currentSegmentInfo.unk2 = m_stream->readUInt16();

	m_nextSegmentPosition = m_nextSegmentPosition + 12 + m_segmentSize;

	if (signature != s_dataStreamId)
	{
		m_stream->seek(m_nextSegmentPosition, Stream::seekSet);
		if (signature == 0)
		{
			return false;
		}
		else
		{
			//DLOG << "Unknown segment type 0x" << HEX << signature << ", skipping";
			return true;
		}
	}

	if (m_segmentSize > m_stream->size())
	{
		return false;
	}
	m_currentItemSize = 0;


#ifdef _DEBUG
	//std::cout << "magic: (" << unk1 << ", " << unk2 << ")" << std::endl;
#endif

	m_currentMetaInfo = readMetaInfo();

	m_position = static_cast<uint32>(m_stream->position() - m_startStreamPosition - m_currSegmentPosition);

	if (!m_currentMetaInfo.isNull())
	{
		//std::cout << "Segment type: " << m_currentMetaInfo.typeId << std::endl;
	}

	return !m_currentMetaInfo.isNull();
}

DataStreamParser::MetaInfo DataStreamParser::readMetaInfo()
{
	m_stream->setByteOrder(m_byteOrder);

	const int size = m_stream->readUInt32();
	size;

	bool ok = true;

	MetaInfo info;
	info.unknown = readString(ok);
	info.unk1 = m_stream->readUInt64();
	info.unk2 = m_stream->readUInt32();
	info.unk3 = m_stream->readUInt32();
	info.typeId = readString(ok);
	info.targetPath = readString(ok);
	info.sourcePath = readString(ok);
	info.unk4 = m_stream->readUInt32();

	if (!ok)
	{
		return MetaInfo();
	}

	return info;
}

std::string DataStreamParser::readString(bool& ok)
{
	const int length = m_stream->readUInt32();

	if (length < 0 || length > 256)
	{
		ok = false;
		return std::string();
	}

	std::string result;
	result.reserve(length);

	for (int i = 0; i < length; i++)
	{
		const char c = m_stream->readUInt8();
		if (c == '\0')
		{
			break;
		}
		result.push_back(c);
	}
	
	int delta = length - (result.size() + 1);
	while (delta > 0)
	{
		m_stream->readUInt8();
		delta--;
	}

	return result;
}

offset_t DataStreamParser::nextSegmentPosition() const
{
	return m_startStreamPosition + m_nextSegmentPosition;
}

bool DataStreamParser::atSegmentEnd() const
{
	return (m_stream->position() == nextSegmentPosition());
}

uint32 DataStreamParser::totalSegmentSize() const
{
	return m_segmentSize + s_segmentHeaderSize;
}

uint32 DataStreamParser::itemSize() const
{
	return m_currentItemSize;
}

uint32 DataStreamParser::segmentSize() const
{
	return m_segmentSize;
}

}
