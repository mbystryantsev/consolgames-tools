#ifndef __STREAM_H
#define __STREAM_H

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
	virtual ~Stream(){}
	
	template <typename T>
	T read()
	{
		T value;
		read(&value, sizeof(T));
		return value;
	}
	
    virtual largesize_t read(void* buf, largesize_t size) = 0;
    virtual largesize_t write(const void* buf, largesize_t size) = 0;
    virtual offset_t seek(offset_t offset, SeekOrigin origin) = 0;
    virtual offset_t tell() const = 0;
    virtual void flush() = 0;
    virtual offset_t size() const = 0;

    virtual largesize_t readStream(Stream *stream, largesize_t size);
    virtual largesize_t writeStream(Stream *stream, largesize_t size);
	virtual largesize_t skip(largesize_t size);

	void setByteOrder(ByteOrder order);
	ByteOrder byteOrder() const;

	virtual u8 read8();
	virtual u16 read16();
	virtual u32 read32();
	virtual u64 read64();

protected:
	ByteOrder m_byteOrder;
	static const ByteOrder s_nativeByteOrder;

};

class IFileStream: public Stream
{
public:
    virtual bool opened() const = 0;
	virtual bool eof() const = 0;
	virtual offset_t size() const = 0;
};

}

#endif /* __STREAM_H */


