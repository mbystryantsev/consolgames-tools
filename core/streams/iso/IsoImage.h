#pragma once
#include "SectorSource.h"
#include "IsoFileDescriptor.h"
#include "IsoDirectory.h"
#include <Stream.h>
#include <core.h>
#include <memory>

namespace Consolgames
{

class Stream;
class IsoDirectory;

// Only DVD images are supported now
class IsoImage: public SectorSource
{
public:
	IsoImage();

	// SectorSource
	virtual int sectorCount() const override;
	virtual bool readSector(unsigned char* buffer, int lba) override;

	bool open(const std::wstring& filename, Stream::OpenMode mode);
	bool isOpen() const;
	void close();
	largesize_t size() const;
	bool seekToFile(const char *filename);
	Stream* openFile(const char* filename);
	IsoFileDescriptor findFile(const char* filename) const;

	Stream* file();

private:
	largesize_t m_size;
	Stream* m_stream;
	std::auto_ptr<Stream> m_streamHolder;
	std::auto_ptr<IsoDirectory> m_rootDirectory;
};

}



