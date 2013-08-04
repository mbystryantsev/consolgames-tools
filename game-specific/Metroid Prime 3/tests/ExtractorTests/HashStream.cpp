#include "HashStream.h"

HashStream::HashStream()
	: Stream()
	, m_hash(QCryptographicHash::Md5)
{
}

QByteArray HashStream::hash() const
{
	return m_hash.result();
}

void HashStream::reset()
{
	m_hash.reset();
}

largesize_t HashStream::write(const void* buf, largesize_t size)
{
	m_hash.addData(static_cast<const char*>(buf), static_cast<int>(size));
	return size;
}

offset_t HashStream::size() const
{
	return 16;
}
