#include "Compressor.h"
#include "CyclicBuffer.h"

using namespace Consolgames;

namespace ResidentEvil
{

enum
{
	s_referenceIncrement = 4,
	s_lenghtIncrement = 2,
	s_windowSize = 0x7FF + s_referenceIncrement,
	s_maxEncodingLength = 0xF + s_lenghtIncrement,
	s_effectiveForwardBufferSize = s_maxEncodingLength - s_referenceIncrement
};

bool Compressor::decode(Consolgames::Stream* input, Consolgames::Stream* output)
{
	CyclicBuffer cache(s_windowSize);
	uint8 buf[128];

	uint32 blockCount = input->read32();

	while (blockCount > 0 && !input->atEnd())
	{
		const uint8 command = input->read8();

		if (command >= 0x80)
		{
			// Just read
			const int length = command & 0x7F;
			VERIFY(input->read(buf, length) == length);
			cache.write(buf, length);
			output->write(buf, length);
		}
		else
		{
			// lz77, copy
			const uint8 second = input->read8();
			const int backReference = (((command << 8) | second) & 0x7FF) + s_referenceIncrement;
			const int length = (command >> 3) + s_lenghtIncrement;

			cache.reply(backReference, length);
			cache.readTail(output, length);

		}

		blockCount--;
	}

	return (blockCount == 0);
}

bool Compressor::encode(Consolgames::Stream* input, Consolgames::Stream* output)
{
	output->setByteOrder(Stream::orderBigEndian);

	const offset_t initialPosition = output->position();
	output->skip(4); // for block count

	// For encoding used cyclic buffer contains two partially
	// intersected logical parts: search window and forward buffer.
	// Intersection needed for encoding periodic sequences at
	// front of search buffer like "ab|ababab" or "a|aaaaaa".
	CyclicBuffer cache(s_windowSize + s_effectiveForwardBufferSize);

	int forwardBufferSize = std::min<int>(s_effectiveForwardBufferSize, static_cast<int>(input->size() - input->position()));
	int blockCount = 0;
	int cacheFilledSize = forwardBufferSize;
	int bytesToCopy = 0;
	cache.write(input, forwardBufferSize);

	while (forwardBufferSize > 0)
	{
		const int lookback = std::min<int>(s_windowSize, cacheFilledSize - forwardBufferSize);
		const MatchInfo matchInfo = findBestMatch(cache, lookback, forwardBufferSize);

		if (matchInfo.size < s_lenghtIncrement)
		{
			bytesToCopy++;
			if (!input->atEnd())
			{
				cache.write(input, 1);
				cacheFilledSize = std::min<int>(cacheFilledSize + 1, cache.size());
			}
			else
			{
				forwardBufferSize--;
			}

			if (bytesToCopy >= 0x7F)
			{
				blockCount += flushUncompressed(output, cache, bytesToCopy, forwardBufferSize);
			}
		}
		else
		{
			blockCount += flushUncompressed(output, cache, bytesToCopy, forwardBufferSize);

			ASSERT(matchInfo.size <= s_maxEncodingLength);
			ASSERT(matchInfo.size >= s_lenghtIncrement);
			ASSERT(matchInfo.reference <= s_windowSize);
			ASSERT(matchInfo.reference >= s_referenceIncrement);
			const uint16 packedReference = ((matchInfo.reference - s_referenceIncrement) | ((matchInfo.size - s_lenghtIncrement) << 11));
			output->write16(packedReference);

			const int availableInput = std::min<int>(static_cast<int>(input->size() - input->position()), matchInfo.size);

			if (availableInput != 0)
			{
				cache.write(input, availableInput);
				cacheFilledSize = std::min<int>(cacheFilledSize + availableInput, cache.size());
			}
			forwardBufferSize = forwardBufferSize - matchInfo.size + availableInput;

			blockCount++;
		}
	}

	blockCount += flushUncompressed(output, cache, bytesToCopy, forwardBufferSize);

	output->setByteOrder(Stream::orderLittleEndian);
	output->seek(initialPosition, Stream::seekSet);
	output->write32(blockCount);

	return true;
}

void Compressor::calcPrefix(const uint8* pattern, int patternSize, char* prefix)
{
	prefix[0] = 0;
	int k = 0;
	for(int i = 1; i < patternSize; i++)
	{
		while (k > 0 && pattern[k] != pattern[i])
		{
			k = prefix[k - 1];
		}
		if (pattern[k] == pattern[i])
		{
			k++;
		}
		prefix[i] = k;
	}
}

Compressor::MatchInfo Compressor::findBestMatch(const CyclicBuffer& window, int lookbackSize, int forwardBufferSize)
{
	// Search best match using Knuth–Morris–Pratt algorithm

	if (lookbackSize < s_referenceIncrement)
	{
		return MatchInfo();
	}

	const int patternSize = std::min<int>(s_maxEncodingLength, forwardBufferSize);

	char prefix[s_maxEncodingLength + 1] = {0};
	uint8 pattern[s_maxEncodingLength];
	window.readTail(pattern, patternSize);

	calcPrefix(pattern, patternSize, &prefix[1]);

	int bestLen = 0;
	int bestPos = 0;
	int j = 0;

	const int lastWindowStartIndex = window.size() - forwardBufferSize - s_referenceIncrement;
	const int lastWindowMatchIndex = lastWindowStartIndex + patternSize;
	const int lastPatternIndex = patternSize - 1;

	for (int i = window.size() - forwardBufferSize - lookbackSize; i <= lastWindowMatchIndex; i++)
	{
		if (pattern[j] != window[i])
		{
			if (j > bestLen)
			{
				bestLen = j;
				bestPos = i - j;
			}
			if (i >= lastWindowStartIndex)
			{
				break;
			}
			if (j != 0)
			{
				i--;
			}
			j = prefix[j];
		}
		else if (j == lastPatternIndex || i == lastWindowMatchIndex || j + 1 == s_maxEncodingLength)
		{
			if (j + 1 > bestLen)
			{
				bestLen = j + 1;
				bestPos = i - j;
			}
			break;
		}
		else
		{
			j++;
		}
	}

	return MatchInfo(window.size() - forwardBufferSize - bestPos, bestLen);
}

int Compressor::flushUncompressed(Consolgames::Stream* output, const CyclicBuffer& window, int& count, int patternSize)
{
	int blockCount = 0;

	while (count > 0)
	{
		const uint8 chunk = std::min<int>(count, 0x7F);
		output->write8(chunk | 0x80);
		window.readTail(output, chunk, patternSize);
		count -= chunk;
		blockCount++;
	}

	return blockCount;
}

}
