#pragma once
#include "ProgressNotifier.h"

namespace ShatteredMemories
{

class CheckingProgressNotifier : public ProgressNotifier
{
public:
	CheckingProgressNotifier(int size);
	~CheckingProgressNotifier();

	void progress(int value);

private:
	bool m_isFirst;
	int m_size;
};

}