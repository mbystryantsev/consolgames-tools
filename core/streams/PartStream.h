#pragma once
#include <Stream.h>

namespace Consolgames
{
	
class PartStream : public Consolgames::Stream
{
public:
	PartStream(Consolgames::Stream* stream, offset_t position, largesize_t size);

	void setSize(largesize_t size);

	virtual largesize_t size() const override;
	virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
	virtual largesize_t read(void* buf, largesize_t size) override;
	virtual largesize_t write(const void* buf, largesize_t size) override;
	virtual offset_t position() const;
	virtual void flush();
	virtual bool atEnd() const override;

private:
	Consolgames::Stream* m_stream;
	largesize_t m_size;
	offset_t m_position;
};

}