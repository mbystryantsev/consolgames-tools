#pragma once
#include <ZlibStream.h>
#include <zlib.h>

namespace ShatteredMemories
{

class CompressionStream : public ZlibStream
{
public:
	CompressionStream (Consolgames::Stream* dataStream, int compressionLevel = Z_BEST_COMPRESSION);
	~CompressionStream();

	virtual largesize_t read(void* buf, largesize_t size) override;
	virtual largesize_t write(const void* buf, largesize_t size) override;
	virtual offset_t size() const override;
	virtual bool opened() const override;
	virtual bool atEnd() const override;
	largesize_t processedSize() const;
	void finish();
};

}
