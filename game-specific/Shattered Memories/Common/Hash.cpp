#include "Hash.h"
#include <algorithm>
#include <sstream>
#include <iomanip>

namespace ShatteredMemories
{
	
uint32_t Hash::calc(const char* str, uint32_t hash)
{
	const char* c = str;
	while (*c != '\0')
	{
		const uint32_t v = tolower(*c++);
		hash = ((hash << 5) + hash) ^ v;
	}
	return hash;
}

std::string Hash::toString(uint32_t hash)
{
	std::stringstream ss;
	ss << std::setw(8) << std::uppercase << std::hex << std::setfill('0') << hash;
	return ss.str();
}

}
