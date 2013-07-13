#include "Compressor.h"
#include "SearchBuffer.h"

using namespace Consolgames;
using namespace Compression;

namespace ResidentEvil
{

enum
{
	s_referenceIncrement = 4,
	s_lenghtIncrement = 2,
	s_windowSize = 0x7FF + s_referenceIncrement,
	s_maxEncodingLength = 0xF + s_lenghtIncrement
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
	// For search used AVL tree (self-balancing binary search tree).
	SearchBuffer searchBuffer(s_windowSize, s_maxEncodingLength, s_referenceIncrement);

	int forwardBufferSize = std::min<int>(s_maxEncodingLength, static_cast<int>(input->size() - input->position()));
	int blockCount = 0;
	int bytesToCopy = 0;
	searchBuffer.write(input, forwardBufferSize);

	while (forwardBufferSize > 0)
	{
		if (forwardBufferSize < s_maxEncodingLength && !searchBuffer.finishingMode())
		{
			// Finish indexing left positions
			searchBuffer.setFinishingMode(forwardBufferSize);
		}

		const int patternPosition = searchBuffer.position() - forwardBufferSize;
		const SearchTree::SearchResult searchResult = patternPosition >= s_referenceIncrement
			? searchBuffer.tree().find(patternPosition, forwardBufferSize)
			: SearchTree::SearchResult();

		if (searchResult.length < s_lenghtIncrement)
		{
			bytesToCopy++;
			if (!input->atEnd())
			{
				searchBuffer.write(input->read8());
			}
			else
			{
				searchBuffer.processLastBytes(1);
				forwardBufferSize--;
			}

			// In any case periodic flush needed for prevent cyclic buffer overflow
			if (bytesToCopy >= 0x7F)
			{
				blockCount += flushUncompressed(output, searchBuffer.window(), bytesToCopy, forwardBufferSize);
			}
		}
		else
		{
			blockCount += flushUncompressed(output, searchBuffer.window(), bytesToCopy, forwardBufferSize);

			// Calculate reference from relative position in cyclic buffer
			int absolutePosition = 0;
		
			const int currentWindowPosition = searchBuffer.window().position() % searchBuffer.window().size();
			const int currentWindowStart = searchBuffer.position() - searchBuffer.position() % searchBuffer.window().size();
			if (searchResult.position >= currentWindowPosition)
			{
				absolutePosition = currentWindowStart - searchBuffer.window().size() + searchResult.position;
			}
			else
			{
				absolutePosition = currentWindowStart + searchResult.position;
			}
			
			const int reference = patternPosition - absolutePosition;

			ASSERT(searchResult.length <= s_maxEncodingLength);
			ASSERT(searchResult.length >= s_lenghtIncrement);
			ASSERT(reference <= s_windowSize);
			ASSERT(reference >= s_referenceIncrement);
			const uint16 packedReference = ((reference - s_referenceIncrement) | ((searchResult.length - s_lenghtIncrement) << 11));
			output->write16(packedReference);

			const int availableInput = std::min<int>(static_cast<int>(input->size() - input->position()), searchResult.length);

			if (availableInput != 0)
			{
				searchBuffer.write(input, availableInput);
			}
			forwardBufferSize = forwardBufferSize - searchResult.length + availableInput;

			blockCount++;
		}
	}

	blockCount += flushUncompressed(output, searchBuffer.window(), bytesToCopy, forwardBufferSize);

	output->setByteOrder(Stream::orderLittleEndian);
	output->seek(initialPosition, Stream::seekSet);
	output->write32(blockCount);

	return true;
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
