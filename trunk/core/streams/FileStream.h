#pragma once

#include "Stream.h"
#include <io.h>

#if defined(_WIN32) || defined(__WIN32)
#define USE_WINDOWS_FILES
#include <windows.h>
#endif

#include <algorithm>

namespace Consolgames
{

class FileStream: public Stream
{
public:
	FileStream(const std::string& filename, OpenMode mode);
    virtual ~FileStream();

    virtual offset_t tell() const override;
    virtual void flush() override;
    virtual largesize_t read(void* buf, largesize_t size) override;
    virtual largesize_t write(const void* buf, largesize_t size) override;
	virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
    virtual offset_t size() const override;
	virtual bool opened() const override;
	virtual bool eof() const override;
	OpenMode openMode() const;
    static bool fileExists(const char *path);
	static bool fileExists(const std::string& path);

protected:
	FileStream();

#ifdef USE_WINDOWS_FILES
	HANDLE m_handle;
#else
	int m_descriptor;
#endif
	OpenMode m_openMode;
};


}
