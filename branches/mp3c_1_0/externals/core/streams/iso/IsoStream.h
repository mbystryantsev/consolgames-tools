#ifndef __ISOSTREAM_H
#define __ISOSTREAM_H

#include "ImageStream.h"
#include "SectorSource.h"
#include "IsoFS.h"
#include "FileStream.h"

namespace Consolgames
{

class IsoStream: public ImageStream, public SectorSource
{
public:
    IsoStream(const char* filename, OpenMode mode = modeReadWrite);
    virtual ~IsoStream();


	// IFileStream
	virtual largesize_t read(void* buf, largesize_t size) override;
    virtual largesize_t write(const void* buf, largesize_t size) override;
    virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
	virtual offset_t tell() const override;
	virtual bool opened() const override;
    virtual void flush();
	virtual largesize_t size() const override;

	// SectorSource
	virtual int sectorCount() const override;
	virtual bool readSector(void* buffer, int lba) override;

	bool seekToFile(const char *filename);
	ImageFileStream* findFile(const char* filename);

protected:
	unsigned char m_cache[2048];
	offset_t m_imageSize;
	int m_cachedLba;
	int m_lbaCount;
	std::auto_ptr<FileStream> m_stream;
	std::auto_ptr<IsoDirectory> m_isoDirectory;
};

}

#endif /* __ISOSTREAM_H */


