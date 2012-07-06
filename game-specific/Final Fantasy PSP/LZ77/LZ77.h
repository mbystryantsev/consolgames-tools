#pragma once
#include "SimpleStream.h"
#include <CommonTypes.h>
#include <vector>

class LZ77
{
public:
	struct CodingResult
	{
		CodingResult()
			: processedSize(0)
			, resultSize(0)
		{
		}
		CodingResult(int processedSize, int resultSize)
			: processedSize(processedSize)
			, resultSize(resultSize)
		{
		}
		int processedWordCount() const
		{
			return (processedSize + 1) / 2;
		}
		int resultWordCount() const
		{
			return (resultSize + 1) / 2;
		}
		int processedSize;
		int resultSize;
	};

protected:
	enum
	{
		s_referenceBits = 11,
		s_repeatBits = 16 - s_referenceBits,
		s_windowSize = (1 << s_referenceBits),
		s_maxLength = (1 << s_repeatBits) + 1
	};

#pragma pack(push, 1)
	struct PackedReference
	{
		PackedReference(uint16 pair) : value(pair)
		{
		}
		PackedReference(uint16 reference, uint16 count)
			: reference(reference == s_windowSize ? 0 : reference)
			, count(count - 2)
		{
		}
		int actualReference() const
		{
			return (reference == 0) ? s_windowSize : reference;
		}
		int actualCount() const
		{
			return count + 2;
		}
		union
		{
			struct
			{
				uint16 count : s_repeatBits;
				uint16 reference : s_referenceBits;
			};
			uint16 value;
		};
	};
#pragma pack(pop)
};

class LZ77Decoder : public LZ77
{
public:
	LZ77Decoder();

	CodingResult decodeChunk(const void* data, int size, void* out, int outSize);

protected:

	CodingResult decodeChunk(SimpleStream data, SimpleStream outData);
	void writeZeros(SimpleStream& data, int count);
	void copy(const SimpleStream source, SimpleStream& dest);

	int m_bitsLeft;
	int m_copyWordsLeft;
	uint32 m_commandBits;
	uint32 m_bytesProcessed;
	uint32 m_bytesUnpacked;
};

class LZ77Encoder : public LZ77
{
protected:
	//! Calculate pattern prefix data for Knuth–Morris–Pratt algorithm
	static void calcPrefix(const SimpleStream& pattern, char* prefix);
	//! Find longest substring by Knuth–Morris–Pratt algorithm
	static std::pair<int, int> findBestMatch(SimpleStream pattern, SimpleStream window, int additionalSize = 0);

	CodingResult encodeChunk(SimpleStream data, SimpleStream outData);
};