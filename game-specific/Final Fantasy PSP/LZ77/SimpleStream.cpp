#include "SimpleStream.h"

SimpleStream::SimpleStream(void* data, int size, int position)
	: m_data(reinterpret_cast<uint16*>(data))
	, m_size(size)
	, m_position(position)
{
}

SimpleStream::SimpleStream(const void* data, int size, int position)
	: m_data(reinterpret_cast<uint16*>(const_cast<void*>(data)))
	, m_size(size)
	, m_position(position)
{
}