#pragma once

//#include "ImageStream.h"
#include "FileStream.h"
#include <cstdlib>
#include <cstring>
#include <vector>

#define BLOCK_SIZE 0x10000

namespace Consolgames
{

class MemoryStream: public Stream
{
public:
	MemoryStream();
    MemoryStream(const void* data, ptrdiff_t size); 
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
	OpenMode m_mode;
	largesize_t m_position;
	u8* m_memory;
	const u8* m_constMemory;
	std::vector<u8> m_buffer;
	bool m_externalPointer;
};

}
