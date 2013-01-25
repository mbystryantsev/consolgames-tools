#pragma once

template <typename T>
class ValueHolder
{
public:
	ValueHolder(T& holdedValue, const T& value)
		: m_value(holdedValue)
		, m_restoreValue(holdedValue)
	{
		m_value = value;
	}
	ValueHolder(T& holdedValue)
		: m_value(holdedValue)
		, m_restoreValue(holdedValue)
	{
	}
	~ValueHolder()
	{
		m_value = m_restoreValue;
	}

private:
	T& m_value;
	T m_restoreValue;
};

typedef ValueHolder<bool> FlagHolder;
