#pragma once
#include <Stream.h>
#include <string>
#include <memory>

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

		uint32 signature;
		uint32 size;
		uint16 unk1;
		uint16 unk2;
	};

	struct MetaInfo
	{
		bool isNull();
		void clear();

		std::string unknown;
		uint64 unk1;
		uint32 unk2;
		uint32 unk3;
		std::string typeId;
		std::string targetPath;
		std::string sourcePath;
		uint32 unk4;
	};

public:
	DataStreamParser(Consolgames::Stream::ByteOrder byteOrder);

	bool open(const std::wstring& filename);
	bool open(Consolgames::Stream* stream);

	bool initSegment();
	offset_t nextSegmentPosition() const;
	bool atSegmentEnd() const;
	uint32 segmentSize() const;

	bool fetch();
	bool atEnd() const;
	const MetaInfo& metaInfo() const;
	const SegmentInfo& segmentInfo() const;

	uint32 itemSize() const;

private:
	MetaInfo readMetaInfo();
	std::string readString(bool& ok);
	uint32 totalSegmentSize() const;

private:
	const Consolgames::Stream::ByteOrder m_byteOrder;

	static const uint32 s_dataStreamId;
	static const uint32 s_segmentHeaderSize;

	MetaInfo m_currentMetaInfo;
	SegmentInfo m_currentSegmentInfo;
	Consolgames::Stream* m_stream;
	std::unique_ptr<Consolgames::Stream> m_streamHolder;
	uint32 m_segmentSize;
	uint32 m_position;
	uint32 m_nextItemPosition;
	uint32 m_currSegmentPosition;
	uint32 m_nextSegmentPosition;
	uint32 m_currentItemSize;
	offset_t m_startStreamPosition;
	bool m_isFirstSegment;
};

}