#include "DataStreamParserWii.h"
#include <Streams/FileStream.h>
#ifdef _DEBUG
#include <iostream>
#endif

namespace ShatteredMemories
{

using namespace Consolgames;

DataStreamParserWii::DataStreamParserWii()
	: DataStreamParser()
	, m_stream(NULL)
	, m_segmentSize(0) 
	, m_position(0) 
	, m_startStreamPosition(0)
	, m_nextItemPosition(0)
	, m_currSegmentPosition(0)
	, m_nextSegmentPosition(0)
	, m_currentItemSize(0)
{
}

bool DataStreamParserWii::fetch()
{
	//DLOG << "Item position " << m_stream->position();

	if (m_nextItemPosition == 0)
	{
		m_nextItemPosition = m_position;
	}

	m_position = m_nextItemPosition;
	if (m_position >= m_segmentSize)
	{
		return false;
	}

	m_stream->seek(m_startStreamPosition + m_currSegmentPosition + m_nextItemPosition, Stream::seekSet);
	m_stream->setByteOrder(Stream::orderBigEndian);

	m_currentItemSize = m_stream->read32();
	if (m_currentItemSize > m_segmentSize)
	{
		return false;
	}
	m_position += 4;

	const int alignedItemSize = (m_currentItemSize % 4 == 0) ? m_currentItemSize : m_currentItemSize + (4 - (m_currentItemSize % 4));
	m_nextItemPosition = m_position + alignedItemSize;

	return true;
}

bool DataStreamParserWii::atEnd() const 
{
	return m_stream->atEnd();
}

const DataStreamParser::MetaInfo& DataStreamParserWii::metaInfo() const 
{
	return m_currentMetaInfo;
}

bool DataStreamParserWii::open(const std::wstring& filename)
{
	m_streamHolder.reset(new FileStream(filename, Stream::modeRead));
	if (!m_streamHolder->opened())
	{
		return false;
	}
	return open(m_streamHolder.get());
}

bool DataStreamParserWii::open(Stream* stream)
{
	m_stream = stream;
	return true;
}

bool DataStreamParserWii::initSegment()
{
	m_currentMetaInfo.clear();

	m_stream->setByteOrder(Stream::orderLittleEndian);

	m_nextItemPosition = 0;
	if (m_position == 0)
	{
		m_startStreamPosition = m_stream->position();
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

	const int signature = m_stream->read32();
	if (signature & 0x0F00 != 0x0700)
	{
		DLOG << "Invalid signature: " << HEX << signature;
		return false;
	}
	
	m_segmentSize = m_stream->read32();
	const short unk1 = m_stream->read16();
	const short unk2 = m_stream->read16();
	m_nextSegmentPosition = m_nextSegmentPosition + 12 + m_segmentSize;

	if (signature != s_dataStreamId)
	{
		if (signature == 0)
		{
			m_stream->seek(m_nextSegmentPosition, Stream::seekSet);
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

	m_position = m_stream->position() - m_startStreamPosition - m_currSegmentPosition;

	if (!m_currentMetaInfo.isNull())
	{
		//std::cout << "Segment type: " << m_currentMetaInfo.typeId << std::endl;
	}

	return !m_currentMetaInfo.isNull();
}

DataStreamParserWii::MetaInfo DataStreamParserWii::readMetaInfo()
{
	m_stream->setByteOrder(Stream::orderBigEndian);

	const int size = m_stream->read32();

	MetaInfo info;

	info.unknown = readString();
	u64 unk1 = m_stream->read64();
	u64 unk2 = m_stream->read64();
	info.typeId = readString();
	info.targetPath = readString();
	info.sourcePath = readString();
	int unk3 = m_stream->read32();

#if 0//#ifdef _DEBUG
	std::cout << "Unknown:     \"" << info.unknown << "\"" << std::endl;
	std::cout << "typeId:      \"" << info.typeId << "\"" << std::endl;
	std::cout << "sourcePath:  \"" << info.sourcePath << "\"" << std::endl;
	std::cout << "targetPath:  \"" << info.targetPath << "\"" << std::endl;
	std::cout << "magic: (" << unk1 << ", " << unk2 << ", " << unk3 << ")" << std::endl;
#endif

	return info;
}

std::string DataStreamParserWii::readString()
{
	const int length = m_stream->read32();
	std::string result;
	result.reserve(length);

	for (int i = 0; i < length; i++)
	{
		const char c = m_stream->read8();
		if (c == '\0')
		{
			break;
		}
		result.push_back(c);
	}
	
	int delta = length - (result.size() + 1);
	while (delta > 0)
	{
		m_stream->read8();
		delta--;
	}

	return result;
}

offset_t DataStreamParserWii::nextSegmentPosition() const
{
	return m_startStreamPosition + m_nextSegmentPosition;
}

bool DataStreamParserWii::atSegmentEnd() const
{
	return (m_stream->position() == nextSegmentPosition());
}

}
