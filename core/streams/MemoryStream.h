#pragma once

//#include "ImageStream.h"
#include "FileStream.h"
#include <cstdlib>
#include <cstring>
#include <vector>

namespace Consolgames
{

class MemoryStream : public Stream
{
public:
	MemoryStream();
    MemoryStream(const void* data, largesize_t size);
#ifdef CPP_SUPPORTS_MOVE_SEMANTICS
	MemoryStream(std::vector<uint8_t>&& data);
#endif
    virtual ~MemoryStream(){}

    virtual largesize_t read(void* buf, largesize_t size) override;
    virtual largesize_t write(const void* buf, largesize_t size) override;
    virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
    virtual offset_t position() const override;
    virtual void flush() override;
	virtual offset_t size() const override;
	virtual bool atEnd() const override;

	const void* memory() const;

private:
	bool isReadOnly() const;

private:
	largesize_t m_size;
	largesize_t m_bufferSize;
	OpenMode m_mode;
	largesize_t m_position;
	uint8_t* m_memory;
	const uint8_t* m_constMemory;
	std::vector<uint8_t> m_buffer;
	bool m_externalPointer;
};

}
