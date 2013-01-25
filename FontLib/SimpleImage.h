#pragma once
#include <QtGlobal>
#include <algorithm>

namespace Consolgames
{

class SimpleImage
{
public:
	SimpleImage()
		: m_width(0)
		, m_height(0)
		, m_data(NULL)
	{
	}
	SimpleImage(int width, int height)
		: m_width(width)
		, m_height(height)
		, m_data(new quint8[width * height])
	{
	}
	SimpleImage(const SimpleImage& other)
		: m_width(other.m_width)
		, m_height(other.m_height)
		, m_data(new quint8[other.m_width * other.m_height])
	{
		std::copy(other.m_data, other.m_data + m_width * m_height, m_data);
	}
	~SimpleImage()
	{
		delete[] m_data;
	}
	quint8* data()
	{
		return m_data;
	}
	const quint8* data() const
	{
		return m_data;
	}
	quint8* scanLine(int line)
	{
		return m_data + line * m_width;
	}
	int width() const
	{
		return m_width;
	}
	int height() const
	{
		return m_height;
	}
	void clear()
	{
		std::fill(m_data, m_data + m_width * m_height, 0);
	}
private:
	int m_width;
	int m_height;
	quint8* const m_data;		
};

}
