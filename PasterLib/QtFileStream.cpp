#include "QtFileStream.h"

QtFileStream::QtFileStream(const QString& filename, QIODevice::OpenMode mode) : m_file(filename)
{
	m_file.open(mode);
}

largesize_t QtFileStream::read(void* buf, largesize_t size)
{
	return m_file.read(reinterpret_cast<char*>(buf), size);
}

largesize_t QtFileStream::write(const void* buf, largesize_t size)
{
	return m_file.write(reinterpret_cast<const char*>(buf), size);
}

offset_t QtFileStream::seek(offset_t offset, SeekOrigin origin)
{
	if (origin == seekCur)
	{
		offset += m_file.pos();
	}
	else if (origin == seekEnd)
	{
		offset += m_file.size();
	}
	m_file.seek(offset);
	return offset;
}

offset_t QtFileStream::position() const 
{
	return m_file.pos();
}

void QtFileStream::flush()
{
	m_file.flush();
}

offset_t QtFileStream::size() const 
{
	return m_file.size();
}

bool QtFileStream::opened() const 
{
	return m_file.isOpen();
}

bool QtFileStream::atEnd() const 
{
	return m_file.atEnd();
}

void QtFileStream::close()
{
	m_file.close();
}