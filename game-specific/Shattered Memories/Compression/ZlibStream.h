#pragma once
#include <Stream.h>
#include <zlib.h>

namespace ShatteredMemories
{

class ZlibStream : public Consolgames::Stream
{
public:
	ZlibStream(Consolgames::Stream* zlibStream);

	virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
	virtual offset_t position() const override;
	virtual void flush() override;
	virtual largesize_t skip(largesize_t size) override;

protected:
	Consolgames::Stream* m_zlibStream;
	static const int s_chunkSize = 0x1000;
	z_stream m_zStream;
	bool m_opened;
	bool m_finished;
	uint8_t m_buf[s_chunkSize];
};

}
