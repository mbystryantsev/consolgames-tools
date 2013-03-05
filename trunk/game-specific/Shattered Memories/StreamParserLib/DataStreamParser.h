#pragma once
#include <Stream.h>
#include <string>

namespace ShatteredMemories
{

class DataStreamParser
{
public:
	struct SegmentInfo
	{
		SegmentInfo()
			: signature(0)
			, size(0)
			, unk1(0)
			, unk2(0)
		{
		}

		u32 signature;
		u32 size;
		u16 unk1;
		u16 unk2;
	};

	struct MetaInfo
	{
		bool isNull();
		void clear();

		std::string unknown;
		u64 unk1;
		u32 unk2;
		u32 unk3;
		std::string typeId;
		std::string targetPath;
		std::string sourcePath;
		u32 unk4;
	};

public:
	DataStreamParser(Consolgames::Stream::ByteOrder byteOrder);

	bool open(const std::wstring& filename);
	bool open(Consolgames::Stream* stream);

	bool initSegment();
	offset_t nextSegmentPosition() const;
	bool atSegmentEnd() const;
	u32 segmentSize() const;

	bool fetch();
	bool atEnd() const;
	const MetaInfo& metaInfo() const;
	const SegmentInfo& segmentInfo() const;

	u32 itemSize() const;

private:
	MetaInfo readMetaInfo();
	std::string readString();
	u32 totalSegmentSize() const;

private:
	const Consolgames::Stream::ByteOrder m_byteOrder;

	static const quint32 s_dataStreamId;
	static const quint32 s_segmentHeaderSize;

	MetaInfo m_currentMetaInfo;
	SegmentInfo m_currentSegmentInfo;
	Consolgames::Stream* m_stream;
	std::auto_ptr<Consolgames::Stream> m_streamHolder;
	quint32 m_segmentSize;
	quint32 m_position;
	quint32 m_nextItemPosition;
	quint32 m_currSegmentPosition;
	quint32 m_nextSegmentPosition;
	quint32 m_currentItemSize;
	offset_t m_startStreamPosition;
};

}