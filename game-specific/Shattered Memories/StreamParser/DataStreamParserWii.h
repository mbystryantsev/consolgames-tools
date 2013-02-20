#pragma once
#include "DataStreamParser.h"
#include <memory>

namespace ShatteredMemories
{

class DataStreamParserWii : public DataStreamParser
{
public:
	DataStreamParserWii();

	bool open(const std::wstring& filename);
	bool open(Consolgames::Stream* stream);

	bool initSegment();
	offset_t nextSegmentPosition() const;
	bool atSegmentEnd() const;

	virtual bool fetch() override;
	virtual bool atEnd() const override;
	virtual const MetaInfo& metaInfo() const override;

protected:
	MetaInfo readMetaInfo();
	std::string readString();

protected:
	MetaInfo m_currentMetaInfo;
	Consolgames::Stream* m_stream;
	std::auto_ptr<Consolgames::Stream> m_streamHolder;
	int m_segmentSize;
	int m_position;
	int m_nextItemPosition;
	int m_currSegmentPosition;
	int m_nextSegmentPosition;
	int m_currentItemSize;
	offset_t m_startStreamPosition;
};

}

