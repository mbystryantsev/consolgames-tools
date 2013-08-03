#pragma once
#include <string>

namespace ShatteredMemories
{

class Hash
{
public:
	static uint32 calc(const char* str, uint32 hash = 0);
	static std::string toString(uint32 hash);
};

}
