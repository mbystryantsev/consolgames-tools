#ifndef __IMAGEFILESTREAM_H
#define __IMAGEFILESTREAM_H

#include "Stream.h"
//#include "FileStream.h"


namespace Consolgames
{

class ImageFileStream: public Stream
{
public:
    ImageFileStream(Stream* stream, offset_t size, OpenMode mode = modeReadWrite);
    ImageFileStream(Stream* stream, offset_t offset, offset_t size, OpenMode mode = modeReadWrite);

    virtual largesize_t read(void* buf, largesize_t size) override;
    virtual largesize_t write(const void* buf, largesize_t size) override;
	virtual void flush() override;
	virtual bool isOpen() const override;
	virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
	virtual offset_t position() const override;
	virtual offset_t size() const override;
	virtual bool atEnd() const override;

private:
	Stream* m_stream;
	offset_t m_position;
	offset_t m_imagePosition;
	offset_t m_fileSize;
	OpenMode m_mode;
};

}

#endif /* __IMAGEFILESTREAM_H */
