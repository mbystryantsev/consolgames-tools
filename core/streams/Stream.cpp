#include "Stream.h"

#define S_BUF_SIZE 0x40000

namespace Consolgames
{

const Stream::ByteOrder Stream::s_nativeByteOrder = Stream::orderLittleEndian;

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
        largesize_t count = left;
        if (count > S_BUF_SIZE)
		{
			count = S_BUF_SIZE;
		}
        largesize_t readed = stream->read(buf, count);
		ASSERT(readed == count);

        largesize_t writed = write(buf, readed);
        ASSERT(writed == readed);

		left -= writed;
		
		if (writed != count)
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

u8 Stream::read8()
{
	return read<u8>();
}

u16 Stream::read16()
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		return endian16(read<u16>());
	}
	return read<u16>();
}

u32 Stream::read32()
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		return endian32(read<u32>());
	}
	return read<u32>();
}

u64 Stream::read64()
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		return endian64(read<u64>());
	}
	return read<u64>();
}

}
