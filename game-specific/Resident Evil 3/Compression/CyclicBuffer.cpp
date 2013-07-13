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
		const int chunk = min(this->size() - m_position, size);
		memcpy(&m_data[m_position], data, chunk);
		//std::copy(data, data + chunk, &m_data[pos()]);
		data += chunk;
		m_position = (m_position + chunk) % this->size();
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
		const int chunk = min(this->size() - m_position, size);
		data->read(&m_data[m_position], chunk);
		m_position = (m_position + chunk) % this->size();
		size -= chunk;
	}
}

void CyclicBuffer::fill(uint8 value, int size)
{
	while (size > 0)
	{
		const int chunk = min(this->size() - m_position, size);
		memset(&m_data[m_position], value, chunk);
		m_position = (m_position + chunk) % this->size();
		size -= chunk;
	}
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
		m_data[m_position] = m_data[position];
		m_position = (m_position + 1) % this->size();
		position = (position + 1) % this->size();
		size--;
	}
}

uint8 CyclicBuffer::at(int index) const
{
	return m_data[(m_position + index) % m_data.size()];
}

uint8 CyclicBuffer::operator[](int index) const
{
	return at(index);
}

}
