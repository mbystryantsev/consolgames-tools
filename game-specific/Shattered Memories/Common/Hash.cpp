#include "Hash.h"
#include <algorithm>

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
	char buf[32];
	_ultoa(hash, buf, 16);

	std::string result = buf;
	std::transform(result.begin(), result.end(), result.begin(), toupper);
	result.insert(0, 8 - result.length(), '0');
	return result;
}

}
