#include "LZ77.h"
#include <utility>
#include <string>
#include <assert.h>

void LZ77Encoder::calcPrefix(const SimpleStream& pattern, char* prefix)
{
	prefix[0] = 0;
	int k = 0;
	for(int i = 1; i < pattern.size(); i++)
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

std::pair<int, int> LZ77Encoder::findBestMatch(SimpleStream pattern, SimpleStream window, int additionalSize)
{
	char prefix[s_maxLength + 1] = {0};
	calcPrefix(pattern, &prefix[1]);

	int bestLen = 0;
	int bestPos = 0;
	int j = 0;
	
	if (window.size() == 0 || pattern.size() == 0)
	{
		return std::pair<int, int>(0, 0);
	}

	const int lastWindowStartIndex = window.size() - 1;
	const int lastPatternIndex = pattern.size() - 1;

	for (int i = 0; i <= lastWindowStartIndex + additionalSize; i++)
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
		else if (j == lastPatternIndex || i == lastWindowStartIndex + additionalSize)
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
	return std::pair<int, int>(bestPos, bestLen);
}

LZ77::CodingResult LZ77Encoder::encodeChunk(SimpleStream data, SimpleStream outData)
{
	int bitsLeft = 0;
	uint32* commandBits = NULL;
	while (!data.atEnd() && !outData.atEnd())
	{
		// TODO: Add zero padding detection and processing
		while (bitsLeft > 0 && !data.atEnd() && !outData.atEnd())
		{
			*commandBits >>= 1;
			bitsLeft--;

			// for periodic sequences encoding
			const int intersection = std::min<int>(s_maxLength - 1, data.size() - data.position() - 1);
			assert(intersection >= 0 && intersection < s_maxLength);
			
			const int windowStart = data.position() - std::min<int>(s_windowSize, data.position());
			assert(windowStart >= 0 && windowStart <= data.position());
			
			const int windowSize = std::min<int>(s_windowSize, data.position());
			assert(windowSize >= 0 && windowSize <= s_windowSize);

			const int patternSize = std::min<int>(s_maxLength, data.size() - data.position());
			assert(patternSize >= 0 && patternSize <= s_maxLength);

			const SimpleStream window(&data[windowStart], windowSize);
			const SimpleStream pattern(data.cursor(), patternSize);
			std::pair<int, int> match = findBestMatch(pattern, window, intersection);
			assert(match.second >= 0 && match.second <= s_maxLength);

			if (match.second >= 2)
			{
				PackedReference packedReference(data.position() - windowStart - match.first, match.second);
				assert(packedReference.reference <= s_windowSize);

				outData.writeWord(packedReference.value);
				data.seek(data.position() + match.second);
			}
			else
			{
				*commandBits |= 0x80000000;
				outData.writeWord(data.readWord());
			}
		}
		if (bitsLeft == 0)
		{
			commandBits = reinterpret_cast<uint32*>(outData.cursor());
			outData.writeUInt(0);
			bitsLeft = 32;
		}
		else
		{
			*commandBits >>= bitsLeft;
		}
	}

	return CodingResult(data.position() * 2, outData.position() * 2);
}
//////////////////////////////////////////////////////////////////////////

LZ77Decoder::LZ77Decoder()
: m_bitsLeft(0)
, m_copyWordsLeft(0)
, m_commandBits(0)
, m_bytesProcessed(0)
, m_bytesUnpacked(0)
{
}

LZ77::CodingResult LZ77Decoder::decodeChunk(const void* data, int size, void* out, int outSize)
{
	return decodeChunk(SimpleStream(data, size / 2), SimpleStream(out, outSize / 2));
}

LZ77::CodingResult LZ77Decoder::decodeChunk(const SimpleStream data, SimpleStream outData)
{
	while (!data.atEnd() && !outData.atEnd())
	{
 		while (m_bitsLeft != 0 && !data.atEnd() && !outData.atEnd())
		{
			const bool readWord = ((m_commandBits & 1) != 0);

			if (readWord)
			{
				outData.writeWord(data.readWord());
			}
			else
			{
				const PackedReference ref(data.readWord());
				const int zeroPadding = std::max(ref.actualReference() - outData.position(), 0);
				assert(zeroPadding <= ref.actualCount());				

				const int realReference = std::min(outData.position(), ref.actualReference());
				const int realCount = ref.actualCount() - zeroPadding;

				writeZeros(outData, zeroPadding);
				copy(SimpleStream(outData.cursor() - realReference, realCount), outData);
			}

			m_bitsLeft--;
			m_commandBits >>= 1;
		}

		if (m_bitsLeft == 0)
		{
			m_commandBits = data.readUInt();
			m_bitsLeft = 32;
		}
	}

	return CodingResult(data.position() * 2, outData.position() * 2);
}

void LZ77Decoder::writeZeros(SimpleStream& data, int count)
{
	while (count-- > 0)
	{
		data.writeWord(0);
	}
}

void LZ77Decoder::copy(const SimpleStream source, SimpleStream& dest)
{
	// TODO: Save copy state
	while (!source.atEnd())
	{
		dest.writeWord(source.readWord());
	}
}
