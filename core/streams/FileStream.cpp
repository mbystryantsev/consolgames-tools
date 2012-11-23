#include "FileStream.h"
#ifdef __BORLANDC__

#else
#   include <fcntl.h>
#   include <sys/stat.h>
#endif

namespace Consolgames
{

FileStream::FileStream(const std::wstring& filename, OpenMode mode) : Stream()
{
	m_openMode = mode;
	m_handle = INVALID_HANDLE_VALUE;

#ifdef USE_WINDOWS_FILES
	DWORD desiredAccess = 0;
	DWORD creationDisposition = 0;
	if (mode == modeRead || mode == modeReadWrite)
	{
		desiredAccess |= GENERIC_READ;
		creationDisposition = OPEN_EXISTING;
	}
	if (mode == modeWrite)
	{
		creationDisposition = OPEN_ALWAYS;
	}
	if (mode == modeWrite || mode == modeReadWrite)
	{
		desiredAccess |= GENERIC_WRITE;
	}
	m_handle = CreateFileW(filename.c_str(), desiredAccess, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, creationDisposition, FILE_ATTRIBUTE_NORMAL, NULL);
    
	if (m_handle == INVALID_HANDLE_VALUE)
	{
		DLOG << "FileStream: Unable to open file! WinApi error code: " << GetLastError();
	}
#else
    m_descriptor = _open(filename.c_str(), static_cast<int>(mode) | _O_BINARY, _S_IREAD | _S_IWRITE);
#endif
}

FileStream::FileStream() : m_handle(INVALID_HANDLE_VALUE)
{
}

FileStream::~FileStream()
{
#ifdef USE_WINDOWS_FILES
    if(m_handle != INVALID_HANDLE_VALUE)
	{
		CloseHandle(m_handle);
	}
#else
    if(m_descriptor != -1)
	{
		_close(m_descriptor);
	}
#endif
}

offset_t FileStream::seek(offset_t offset, SeekOrigin origin)
{
#ifdef USE_WINDOWS_FILES
    _LARGE_INTEGER new_offset;
    SetFilePointerEx(m_handle, *reinterpret_cast<_LARGE_INTEGER*>(&offset), &new_offset, origin);
    return new_offset.QuadPart;
#else
    return _lseeki64(m_descriptor, offset, static_cast<int>(origin));
#endif
}

largesize_t FileStream::read(void *buf, largesize_t size)
{
#ifdef USE_WINDOWS_FILES
    unsigned long readed;
    if(!ReadFile(m_handle, buf, static_cast<DWORD>(size), &readed, NULL))
    {
        return - 1;
    }
    else
    {
        return readed;
    }
#else
    return _read(m_descriptor, buf, size);
#endif
}

offset_t FileStream::tell() const
{
#ifdef USE_WINDOWS_FILES
	_LARGE_INTEGER ret = {0, 0};
    _LARGE_INTEGER zero = {0, 0};
	zero.QuadPart = 0;

    VERIFY(SetFilePointerEx(m_handle, zero, &ret, FILE_CURRENT));
    return ret.QuadPart;
#else
    return _telli64(m_descriptor);
#endif
}

void FileStream::flush()
{
#ifdef USE_WINDOWS_FILES
    FlushFileBuffers(m_handle);
#else
    //_flush(fd);
#endif
}

largesize_t FileStream::write(const void* buf, largesize_t size)
{
#ifdef USE_WINDOWS_FILES
    unsigned long writed;
    if(!WriteFile(m_handle, buf, static_cast<DWORD>(size), &writed, NULL))
    {
        return - 1;
    }
	return writed;
#else
    return _write(m_descriptor, buf, size);
#endif
}

offset_t FileStream::size() const
{
#ifdef USE_WINDOWS_FILES
	_LARGE_INTEGER fileSize = {0, 0};
	VERIFY(GetFileSizeEx(m_handle, &fileSize));
	return fileSize.QuadPart;
#else
	struct _stat32i64 stat;
	int ret = _fstat32i64(m_descriptor, &stat);
	ASSERT(ret == 0);
    return stat.st_size;
#endif
}

bool FileStream::opened() const
{
#ifdef USE_WINDOWS_FILES
	return (m_handle != INVALID_HANDLE_VALUE);
#else
	return (m_descriptor != -1);
#endif
}


bool FileStream::fileExists(const char *path)
{
	return (_access(path, 0) == 0);
}

bool FileStream::fileExists(const std::string& path)
{
	return fileExists(path.c_str());
}

bool FileStream::eof() const 
{
#ifdef USE_WINDOWS_FILES
	return (tell() >= size());
#else
	return feof(m_descriptor);
#endif
}

Stream::OpenMode FileStream::openMode() const
{
	return m_openMode;
}

}
