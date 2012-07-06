#ifndef __MEMORY_STREAM_H
#define __MEMORY_STREAM_H

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
    MemoryStream(const void* data, size_t size); 
    virtual ~MemoryStream(){}

    virtual largesize_t read(void* buf, largesize_t size) override;
    virtual largesize_t write(const void* buf, largesize_t size) override;
    virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
    virtual offset_t tell() const override;
    virtual void flush() override;
	virtual offset_t size() const override;

private:
	largesize_t m_size;
	largesize_t m_bufferSize;
	OpenMode m_mode;
	largesize_t m_position;
	u8* m_memory;
	const u8* m_constMemory;
	std::vector<u8> m_buffer;
	bool m_externalPointer;
};

}

#endif /* __MEMORY_STREAM_H */
 