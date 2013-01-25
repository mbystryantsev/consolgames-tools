#ifndef __NULLABLE_H
#define __NULLABLE_H

namespace Consolgames
{

class Null
{
};
const Null null;

template <typename T>
class Nullable
{
public:
	Nullable() : m_isNull(true)
	{
	}
	
	Nullable(const T& value) : m_value(value), m_isNull(false)
	{
	}

	T& value()
	{
		return m_value;
	}
	
	const T& value() const
	{
		return m_value;
	}
	
	bool isNull() const
	{
		return m_isNull;
	}
	
	operator Null()
	{
		return Nullable();
	}
	
	operator T&()
	{
		return m_value;
	}
	
	T* operator ->()
	{
		return &m_value;	
	}
	
	Nullable<T>& operator =(const T& v)
	{
		m_value = v;
		m_isNull = false;
		return *this;
	}

private:
	T m_value;
	bool m_isNull;
};


}

#endif // __NULLABLE_H
