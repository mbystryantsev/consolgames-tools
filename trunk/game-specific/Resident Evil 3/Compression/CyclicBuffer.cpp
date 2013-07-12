#include "CyclicBuffer.h"
#include <Stream.h>
#include <algorithm>

namespace ResidentEvil
{

CyclicBuffer::CyclicBuffer(int size)
	: m_data(size)
	, m_position(0)
{
}

void CyclicBuffer::write(const uint8* data, int size)
{
	if (this->size() == 0)
	{
		return;
	}

	while (size > 0)
	{
		const int chunk = min(this->size() - pos(), size);
		memcpy(&m_data[pos()], data, chunk);
		data += chunk;
		m_position += chunk;
		size -= chunk;
	}
}

void CyclicBuffer::write(Consolgames::Stream* data, int size)
{
	if (this->size() == 0)
	{
		return;
	}

	while (size > 0)
	{
		const int chunk = min(this->size() - pos(), size);
		data->read(&m_data[pos()], chunk);
		m_position += chunk;
		size -= chunk;
	}
}

void CyclicBuffer::write(const uint8 c)
{
	m_data[m_position] = c;
	m_position = (m_position + 1) % size();
}

void CyclicBuffer::readTail(Consolgames::Stream* data, int size, int backTo) const
{
	int position = (m_position + this->size() * 2 - size - backTo) % this->size();

	while (size > 0)
	{
		const int chunk = min(this->size() - position, size);
		data->write(&m_data[position], chunk);
		position = (position + chunk) % this->size();
		size -= chunk;
	}
}

void CyclicBuffer::readTail(uint8* data, int size, int backTo) const
{
	int position = (m_position + this->size() * 2 - size - backTo) % this->size();
	int writePosition = 0;

	while (size > 0)
	{
		const int chunk = min(this->size() - position, size);
		std::copy(&m_data[position], &m_data[position] + chunk, data + writePosition);
		writePosition += chunk;
		position = (position + chunk) % this->size();
		size -= chunk;
	}
}

int CyclicBuffer::size() const
{
	return static_cast<int>(m_data.size());
}

void CyclicBuffer::reply(int backReference, int size)
{
	int position = (m_position + this->size() - backReference) % this->size();

	while (size > 0)
	{
		m_data[pos()] = m_data[position];
		m_position++;
		position = (position + 1) % this->size();
		size--;
	}
}

uint8 CyclicBuffer::at(int index) const
{
	return m_data[index % size()];
}

uint8 CyclicBuffer::operator[](int index) const
{
	return at(index);
}

int CyclicBuffer::pos() const
{
	return m_position % size();
}

const uint8* CyclicBuffer::data() const
{
	return &m_data[0];
}

int CyclicBuffer::position() const
{
	return m_position;
}

}
