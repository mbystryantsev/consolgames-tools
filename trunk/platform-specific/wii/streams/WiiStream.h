#if 0

#ifndef __WII_ISO_STREAM
#define __WII_ISO_STREAM

//#include "WIIDisc.h"
#include <ImageStream.h>

#include <memory>

#define WII_ISO_BUFSIZE 0x7C00

struct ImageFile;
struct PNode;
class WiiDisc;

namespace Consolgames
{

class WiiStream: public ImageStream
{
	offset_t m_position;
	unsigned char cBuffer[WII_ISO_BUFSIZE];
	std::auto_ptr<WiiDisc> m_disc;
	ImageFile* m_image;
	int m_partition;
	int m_dataPartitionIndex;
	int m_streamSize;
	//PNode m_node;
public:
	WiiStream(const char* filename);
	virtual ~WiiStream();
	
	virtual offset_t read(void* buf, largesize_t size);
	virtual offset_t write(const void* buf, largesize_t size);
	
	void setPartition(int partition);
	int partition() const;
	int dataPartition() const;
	bool setDataPartition();
	bool seekToFile(const char* path);
	virtual offset_t tell() const override;
	virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
	virtual void flush() override;
	WiiDisc disc();

	ImageFile *image();

	ImageFileStream* FindFile(const char* filename);
	
	virtual largesize_t size() const override;

	void reparse();
};

class WiiFileStream: public IFileStream
{
public:
	WiiFileStream(WiiStream *wii_stream, int partition, offset_t offset, largesize_t size);
	virtual ~WiiFileStream();

	virtual largesize_t read(void* buf, largesize_t size) override;
	virtual largesize_t write(const void* buf, largesize_t size) override;
	virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
	virtual offset_t tell() const override;
	virtual void flush() override;
	virtual largesize_t size() const override;
	virtual bool opened() const override;

	ImageFileStream* findFile(const char* filename);

private:
	WiiStream *m_stream;
	int m_partition;
	offset_t m_offset;
	offset_t m_postition;
	largesize_t m_fileSize;
};

}

#endif

#endif