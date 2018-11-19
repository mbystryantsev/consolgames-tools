#pragma once
#include <Stream.h>
#include <DataStreamParser.h>
#include <string>

namespace ShatteredMemories
{

class FontStreamRebuilder : public Consolgames::Stream
{
public:
	enum Version
	{
		versionOrigins,
		versionShatteredMemories
	};

public:
	FontStreamRebuilder(std::shared_ptr<Consolgames::Stream> stream, std::shared_ptr<Consolgames::Stream> fontStream, Consolgames::Stream::ByteOrder byteOrder, Version version);

	virtual largesize_t read(void* buf, largesize_t size) override;
	virtual largesize_t write(const void* buf, largesize_t size) override;
	virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
	virtual offset_t position() const override;
	virtual void flush() override;
	virtual offset_t size() const override;
	virtual bool atEnd() const override;

private:
	void cacheMetaInfo(const DataStreamParser::SegmentInfo& segmentInfo, const DataStreamParser::MetaInfo& metaInfo);

private:
	std::shared_ptr<Consolgames::Stream> m_stream;
	std::shared_ptr<Consolgames::Stream> m_fontStream;
	QByteArray m_bufferedData;
	bool m_inFont;
	bool m_finalized;
	quint32 m_originalFontSize;
	quint32 m_segmentSizeLeft;
	quint32 m_position;
	DataStreamParser m_parser;
	const Consolgames::Stream::ByteOrder m_byteOrder;
	static const quint32 s_fontStreamSignature;
	const Version m_version;
};

}
