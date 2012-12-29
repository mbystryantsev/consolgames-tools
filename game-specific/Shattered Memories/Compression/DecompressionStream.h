#pragma once
#include <ZlibStream.h>

namespace ShatteredMemories
{

class DecompressionStream : public ZlibStream
{
public:
	DecompressionStream(Consolgames::Stream* zlibStream, largesize_t size = -1);

	virtual largesize_t read(void* buf, largesize_t size) override;
	virtual largesize_t write(const void* buf, largesize_t size) override;
	virtual offset_t size() const override;
	virtual bool opened() const override;
	virtual bool atEnd() const override;

private:
	largesize_t m_size;
};

}
