#pragma once
#include <Stream.h>

namespace ResidentEvil
{

class CyclicBuffer;

class Compressor
{
public:
	static bool decode(Consolgames::Stream* input, Consolgames::Stream* output);
	static bool encode(Consolgames::Stream* input, Consolgames::Stream* output);

private:
	struct MatchInfo
	{
		MatchInfo(uint32 reference = 0, uint32 size = 0)
			: reference(reference)
			, size(size)
		{
		}

		uint32 reference;
		uint32 size;
	};

private:
	static void calcPrefix(const uint8* pattern, int patternSize, char* prefix);
	static MatchInfo findBestMatch(const CyclicBuffer& window, int filledSize, int patternSize);
	static int flushUncompressed(Consolgames::Stream* output, const CyclicBuffer& window, int& count, int patternSize);
};


}
