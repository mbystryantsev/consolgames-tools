#pragma once

#include "core.h"
#include <iostream>

namespace Consolgames
{

class Stream
{
public:
	enum SeekOrigin
	{
		seekSet = 0,
		seekCur = 1,
		seekEnd = 2
	};

	enum OpenMode
	{
		modeRead = 0,
		modeWrite = 1,
		modeReadWrite = 2
	};

	enum ByteOrder
	{
		orderLittleEndian,
		orderBigEndian
	};

public:
	Stream();
	virtual ~Stream(){}
	
	template <typename T>
	T read()
	{
		T value = T();
		read(&value, sizeof(T));
		return value;
	}

	template <typename T>
	void write(const T& value)
	{
		write(&value, sizeof(T));
	}
	
	virtual largesize_t read(void* buf, largesize_t size) = 0;
	virtual largesize_t write(const void* buf, largesize_t size) = 0;
	virtual offset_t seek(offset_t offset, SeekOrigin origin) = 0;
	virtual offset_t position() const = 0;
	virtual void flush() = 0;
	virtual largesize_t size() const = 0;
	virtual bool isOpen() const;
	virtual bool atEnd() const = 0;

	virtual largesize_t readStream(Stream *stream, largesize_t size);
	virtual largesize_t writeStream(Stream *stream, largesize_t size);
	virtual largesize_t skip(largesize_t size);

	void setByteOrder(ByteOrder order);
	ByteOrder byteOrder() const;

	uint8_t readUInt8();
	uint16_t readUInt16();
	uint32_t readUInt32();
	uint64_t readUInt64();
	int readInt();
	uint32_t readUInt();

	void writeUInt8(uint8_t value);
	void writeUInt16(uint16_t value);
	void writeUInt32(uint32_t value);
	void writeUInt64(uint64_t value);
	void writeInt(int value);

protected:
	ByteOrder m_byteOrder;
	static const ByteOrder s_nativeByteOrder;

};

}

