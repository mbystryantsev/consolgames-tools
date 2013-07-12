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
	static int flushUncompressed(Consolgames::Stream* output, const CyclicBuffer& window, int& count, int patternSize);
};


}
