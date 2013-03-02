#include "Hash.h"
#include <algorithm>

namespace ShatteredMemories
{
	
u32 Hash::calc(const char* str, u32 hash)
{
	const char* c = str;
	while (*c != '\0')
	{
		const u32 v = tolower(*c++);
		hash = ((hash << 5) + hash) ^ v;
	}
	return hash;
}

std::string Hash::toString(u32 hash)
{
	char buf[32];
	_ultoa(hash, buf, 16);

	std::string result = buf;
	std::transform(result.begin(), result.end(), result.begin(), toupper);
	result.insert(0, 8 - result.length(), '0');
	return result;
}

}
