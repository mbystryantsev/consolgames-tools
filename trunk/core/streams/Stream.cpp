#include "Stream.h"

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
        const largesize_t count = min(left, S_BUF_SIZE);
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

void Stream::write8(u8 value)
{
	write<u8>(value);	
}

void Stream::write16(u16 value)
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		value = endian16(value);
	}
	write<u16>(value);
}

void Stream::write32(u32 value)
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		value = endian32(value);
	}
	return write<u32>(value);	
}

void Stream::write64(u64 value)
{
	if (m_byteOrder != s_nativeByteOrder)
	{
		value = endian64(value);
	}
	return write<u64>(value);	
}

bool Stream::opened() const
{
	return true;
}

bool Stream::atEnd() const
{
	return false;
}

int Stream::readInt()
{
	return read<int>();
}

u32 Stream::readUInt()
{
	return read<u32>();
}

}
