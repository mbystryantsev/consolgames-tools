#pragma once

class FlagHolder
{
public:
	FlagHolder(bool& flag, bool value)
		: m_flag(flag)
		, m_flagValue(flag)
	{
		flag = value;
	}
	~FlagHolder()
	{
		m_flag = m_flagValue;
	}

private:
	bool& m_flag;
	bool m_flagValue;
};
