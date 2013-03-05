#pragma once
#include <Stream.h>

namespace Consolgames
{

class WiiImage;

class WiiFileStream : public Consolgames::Stream
{
protected:
	friend class WiiImage;
	WiiFileStream(WiiImage& image, int partition, offset_t offset, largesize_t size);

public:
	virtual largesize_t read(void* buf, largesize_t size) override;
	virtual largesize_t write(const void* buf, largesize_t size) override;
	virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
	virtual offset_t position() const override;
	virtual void flush() override;
	virtual offset_t size() const override;
	virtual largesize_t writeStream(Stream *stream, largesize_t size) override;
	virtual bool atEnd() const override;

	offset_t offset() const;

protected:
	WiiImage& m_image;
	const int m_partition;
	const offset_t m_offset;
	const largesize_t m_size;
	offset_t m_position;
};

}
