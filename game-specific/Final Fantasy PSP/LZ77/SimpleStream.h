#pragma once
#include <CommonTypes.h>

class SimpleStream
{
public:
	SimpleStream(void* data, int size, int position = 0);
	SimpleStream(const void* data, int size, int position = 0);

	void* data()
	{
		return m_data;
	}

	uint16& at(int position)
	{
		return m_data[position];
	}

	const uint16& at(int position) const
	{
		return m_data[position];
	}

	const uint16& operator [](int position) const
	{
		return at(position);
	}

	uint16& operator [](int position)
	{
		return at(position);
	}

	const void* data() const
	{
		return m_data;
	}

	int size() const
	{
		return m_size;
	}

	void seek(int position)
	{
		m_position = position;
	}

	const void* cursor() const
	{
		return &m_data[m_position];
	}

	uint16* cursor()
	{
		return &m_data[m_position];
	}

	int position() const
	{
		return m_position;
	}

	void* dataAt(int position)
	{
		return &m_data[position];
	}

	const void* dataAt(int position) const
	{
		return &m_data[position];
	}

	inline uint16 readWord() const
	{
		return m_data[m_position++];
	}

	inline uint32 readUInt() const
	{
		uint32 value = *reinterpret_cast<uint32*>(&m_data[m_position]);
		m_position += 2;
		return value;
	}

	inline void writeWord(uint16 value)
	{
		m_data[m_position++] = value;
	}

	inline void writeUInt(uint32 value)
	{
		*reinterpret_cast<uint32*>(&m_data[m_position]) = value;
		m_position += 2;
	}

	bool atEnd() const
	{
		return !(m_position < m_size);
	}

private:
	uint16* m_data;
	uint32 m_size;
	mutable uint32 m_position;
};