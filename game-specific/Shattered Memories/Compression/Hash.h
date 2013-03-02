#pragma once
#include <string>

namespace ShatteredMemories
{

class Hash
{
public:
	static u32 calc(const char* str, u32 hash = 0);
	static std::string toString(u32 hash);
};

}
