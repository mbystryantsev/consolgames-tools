#pragma once
#include <core.h>
#include <string>

namespace ShatteredMemories
{

class Hash
{
public:
	static uint32_t calc(const char* str, uint32_t hash = 0);
	static std::string toString(uint32_t hash);
};

}
