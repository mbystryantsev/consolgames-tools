#include "Stream.h"
#include <algorithm>

#define S_BUF_SIZE 0x40000

namespace Consolgames
{

const Stream::ByteOrder Stream::s_nativeByteOrder = Stream::orderLittleEndian;

Stream::Stream() : m_byteOrder(Stream::s_nativeByteOrder)
{
}

largesize_t Stream::readStream(Stream* stream, largesize_t size)
{
    char buf[S_BUF_SIZE];
    largesize_t left = size;

    while (left > 0)
	{
        largesize_t count = left;
        if (count > S_BUF_SIZE)
		{
			count = S_BUF_SIZE;
		}
        largesize_t readed = read(buf, count);
		ASSERT(readed == count);

		largesize_t writed = stream->write(buf, readed);
		ASSERT(writed == count);

		left -= writed;

        if (writed != count)
		{
			return size - left;
		}
    }

    return size;
}

largesize_t Stream::writeStream(Stream *stream, largesize_t size)
{
    char buf[S_BUF_SIZE];
    largesize_t left = size;
    while (left > 0)
	{
        const largesize_t count = std::min<largesize_t>(left, S_BUF_SIZE);
        const largesize_t readed = stream->read(buf, count);
        const largesize_t writed = write(buf, readed);

		left -= writed;
		
		if (readed != count || writed != readed)
		{
			return size - left;
		}
    }
    return size;
}

largesize_t Stream::skip(largesize_t size)
{
	return seek(size, seekCur);
}

void Stream::setByteOrder(ByteOrder order)
{
	m_byteOrder = order;
}

Stream::ByteOrder Stream::byteOrder() const
{
	return m_byteOrder;
}

uint8_t Stream::readUInt8()
{
	return read<uint8_t>();
}

uint16_t Stream::readUInt16()
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		return endian16(read<uint16_t>());
	}
	return read<uint16_t>();
}

uint32_t Stream::readUInt32()
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		return endian32(read<uint32_t>());
	}
	return read<uint32_t>();
}

uint64_t Stream::readUInt64()
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		return endian64(read<uint64_t>());
	}
	return read<uint64_t>();
}

void Stream::writeUInt8(uint8_t value)
{
	write<uint8_t>(value);
}

void Stream::writeUInt16(uint16_t value)
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		value = endian16(value);
	}
	write<uint16_t>(value);
}

void Stream::writeUInt32(uint32_t value)
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		value = endian32(value);
	}
	return write<uint32_t>(value);
}

void Stream::writeUInt64(uint64_t value)
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		value = endian64(value);
	}
	return write<uint64_t>(value);
}

void Stream::writeInt(int value)
{
	writeUInt32(static_cast<uint32_t>(value));
}

bool Stream::isOpen() const
{
	return true;
}

int Stream::readInt()
{
	return static_cast<int>(readUInt());
}

uint32_t Stream::readUInt()
{
	return readUInt32();
}

}
