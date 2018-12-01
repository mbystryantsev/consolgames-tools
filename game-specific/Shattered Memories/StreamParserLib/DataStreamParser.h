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

		uint32_t signature;
		uint32_t size;
		uint16_t unk1;
		uint16_t unk2;
	};

	struct MetaInfo
	{
		bool isNull();
		void clear();

		std::string unknown;
		uint64_t unk1;
		uint32_t unk2;
		uint32_t unk3;
		std::string typeId;
		std::string targetPath;
		std::string sourcePath;
		uint32_t unk4;
	};

public:
	DataStreamParser(Consolgames::Stream::ByteOrder byteOrder);

	bool open(const std::wstring& filename);
	bool open(Consolgames::Stream* stream);

	bool initSegment();
	offset_t nextSegmentPosition() const;
	bool atSegmentEnd() const;
	uint32_t segmentSize() const;

	bool fetch();
	bool atEnd() const;
	const MetaInfo& metaInfo() const;
	const SegmentInfo& segmentInfo() const;

	uint32_t itemSize() const;

private:
	MetaInfo readMetaInfo();
	std::string readString(bool& ok);
	uint32_t totalSegmentSize() const;

private:
	const Consolgames::Stream::ByteOrder m_byteOrder;

	static const uint32_t s_dataStreamId;
	static const uint32_t s_segmentHeaderSize;

	MetaInfo m_currentMetaInfo;
	SegmentInfo m_currentSegmentInfo;
	Consolgames::Stream* m_stream;
	std::unique_ptr<Consolgames::Stream> m_streamHolder;
	uint32_t m_segmentSize;
	uint32_t m_position;
	uint32_t m_nextItemPosition;
	uint32_t m_currSegmentPosition;
	uint32_t m_nextSegmentPosition;
	uint32_t m_currentItemSize;
	offset_t m_startStreamPosition;
	bool m_isFirstSegment;
};

}