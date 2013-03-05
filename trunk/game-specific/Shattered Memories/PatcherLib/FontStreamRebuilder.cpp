#include "FontStreamRebuilder.h"
#include <QDataStream>

using namespace Consolgames;
using namespace std;
using namespace tr1;

namespace ShatteredMemories
{

const quint32 FontStreamRebuilder::s_fontStreamSignature = 0x100000;

FontStreamRebuilder::FontStreamRebuilder(shared_ptr<Stream> stream, shared_ptr<Stream> fontStream, Stream::ByteOrder byteOrder)
	: Stream()
	, m_stream(stream)
	, m_fontStream(fontStream)
	, m_byteOrder(byteOrder)
	, m_inFont(false)
	, m_finalized(false)
	, m_originalFontSize(0)
	, m_segmentSizeLeft(0)
	, m_parser(byteOrder)
	, m_position(0)
{
	ASSERT(m_stream.get() != NULL);
	ASSERT(m_fontStream.get() != NULL);
	m_parser.open(m_stream.get());
}

static quint32 alignedSize(quint32 size)
{
	const int alignment = 4;
	size += (alignment - 1);
	return size - (size % 4);
}

static quint32 alignedStringLength(const std::string& str)
{
	const size_t length = str.length() + sizeof('\0');
	return alignedSize(length);
}

static quint32 metaInfoSize(const DataStreamParser::MetaInfo& info)
{
	return alignedStringLength(info.sourcePath) + sizeof(quint32)
		+ alignedStringLength(info.targetPath) + sizeof(quint32)
		+ alignedStringLength(info.typeId) + sizeof(quint32)
		+ alignedStringLength(info.unknown) + sizeof(quint32)
		+ 20;
}

static void cacheString(QDataStream& stream, const std::string& string)
{
	const int length = alignedStringLength(string);
	stream << length;

	QByteArray stringData(length, '\xBF');
	std::copy(string.begin(), string.end(), stringData.begin());
	stringData[string.length()] = '\0';
	stream.writeRawData(stringData.constData(), stringData.size());
}

void FontStreamRebuilder::cacheMetaInfo(const DataStreamParser::SegmentInfo& segmentInfo, const DataStreamParser::MetaInfo& metaInfo)
{
	QByteArray data;
	QDataStream stream(&data, QIODevice::WriteOnly);
	
	stream.setByteOrder(QDataStream::LittleEndian);
	stream << segmentInfo.signature;
	stream << segmentInfo.size;
	stream << segmentInfo.unk1;
	stream << segmentInfo.unk2;
	
	stream.setByteOrder(m_byteOrder == Stream::orderBigEndian ? QDataStream::BigEndian : QDataStream::LittleEndian);
	
	stream << metaInfoSize(metaInfo);
	cacheString(stream, metaInfo.unknown);
	stream << metaInfo.unk1;
	stream << metaInfo.unk2;
	stream << metaInfo.unk3;
	cacheString(stream, metaInfo.typeId);
	cacheString(stream, metaInfo.targetPath);
	cacheString(stream, metaInfo.sourcePath);
	stream << metaInfo.unk4;

	m_bufferedData.append(data);
}

//////////////////////////////////////////////////////////////////////////

largesize_t FontStreamRebuilder::read(void* buf, largesize_t size)
{
	quint8* ptr = static_cast<quint8*>(buf);
	int readed = 0;

	while (size > 0)
	{
		if (!m_bufferedData.isEmpty())
		{
			const int readSize = min(m_bufferedData.size(), static_cast<int>(size));
			std::copy(m_bufferedData.begin(), m_bufferedData.begin() + readSize, ptr);
			m_bufferedData.remove(0, readSize);

			ptr += readSize;		
			size -= readSize;
			readed += readSize;
			m_position += readSize;
			continue;
		}

		if (m_finalized)
		{
			break;
		}

		if (m_segmentSizeLeft == 0)
		{
			if (!m_parser.initSegment())
			{
				const quint32 pos = position() + 12;
				quint32 size = 0x1000 - (pos % 0x1000);
				if (size == 0x1000)
				{
					size = 0;
				}

				m_bufferedData.fill(0, size + 12);

				QByteArray header;
				{
					QDataStream stream(&header, QIODevice::WriteOnly);
					stream.setByteOrder(QDataStream::LittleEndian);
					stream << 0;
					stream << size;
					stream << 0;
				}

				std::copy(header.begin(), header.end(), m_bufferedData.begin());


				m_finalized = true;
				continue;
			}
			DataStreamParser::SegmentInfo segmentInfo = m_parser.segmentInfo();
			const DataStreamParser::MetaInfo metaInfo = m_parser.metaInfo();
			
			if (metaInfo.typeId == "rwID_KFONT")
			{
				segmentInfo.size = metaInfoSize(metaInfo) + sizeof(quint32) + alignedSize(m_fontStream->size()) + sizeof(quint32) * 2;
				cacheMetaInfo(segmentInfo, metaInfo);
				{
					QByteArray data;
					QDataStream stream(&data, QIODevice::WriteOnly);

					const quint32 size = static_cast<quint32>(m_fontStream->size() + 8);
					stream.setByteOrder(QDataStream::BigEndian);
					stream << size;
					stream << s_fontStreamSignature;

					stream.setByteOrder(QDataStream::LittleEndian);
					stream << size;

					m_bufferedData.append(data);
				}
				m_inFont = true;
				m_segmentSizeLeft = m_fontStream->size();
			}
			else
			{
				m_segmentSizeLeft = segmentInfo.size - metaInfoSize(metaInfo) - sizeof(quint32);
				cacheMetaInfo(segmentInfo, metaInfo);
			}

			continue;
		}

		const quint32 readSize = min(m_segmentSizeLeft, static_cast<quint32>(size));
		if (m_inFont)
		{
			VERIFY(m_fontStream->read(ptr, readSize) == readSize);
			if (m_fontStream->atEnd())
			{
				m_inFont = false;
				m_bufferedData.fill('X', alignedSize(m_fontStream->size()) - m_fontStream->size());
			}
		}
		else
		{
			VERIFY(m_stream->read(ptr, readSize) == readSize);
		}

		ptr += readSize;
		size -= readSize;
		readed += readSize;
		m_segmentSizeLeft -= readSize;
		m_position += readSize;
	}

	return readed;
}

largesize_t FontStreamRebuilder::write(const void*, largesize_t)
{
	ASSERT("!Not supported!");
	return 0;
}

offset_t FontStreamRebuilder::seek(offset_t, SeekOrigin)
{
	ASSERT(!"Not supported");
	return position();
}

offset_t FontStreamRebuilder::position() const 
{
	return m_position;
}

void FontStreamRebuilder::flush()
{
}

offset_t FontStreamRebuilder::size() const 
{
	return -1;
}

bool FontStreamRebuilder::atEnd() const 
{
	return (m_finalized && m_bufferedData.isEmpty());
}

}
