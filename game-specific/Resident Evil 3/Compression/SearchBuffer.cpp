#include "SearchBuffer.h"
#include <Stream.h>

using namespace Consolgames;
using namespace Compression;

namespace ResidentEvil
{

SearchBuffer::SearchBuffer(int windowSize, int maxEncodeLength, int minReference)
	: c_minReference(minReference)
	, c_windowSize(windowSize)
	, c_maxEncodingLength(maxEncodeLength)
	, m_position(0)
	, m_buffer(windowSize + maxEncodeLength)
	, m_tree(m_buffer.data(), m_buffer.size(), maxEncodeLength)
	, m_finishingMode(false)
	, m_dataLeft(0)
{
}

void SearchBuffer::write(uint8 c)
{
	ASSERT(!m_finishingMode);

	removeOldestString();
	m_buffer.write(c);
	m_position++;
	insertNewString();
}

void SearchBuffer::write(Consolgames::Stream* stream, int count)
{
	while (count-- > 0)
	{
		write(stream->read8());
	}
}

void SearchBuffer::processLastBytes(int count)
{
	ASSERT(m_finishingMode);
	ASSERT(m_dataLeft >= count);
	ASSERT(count > 0);

	while (count--)
	{
		m_dataLeft--;
		const int patternIndex = m_position - m_dataLeft;
		if (patternIndex >= c_minReference)
		{
			m_tree.insert((patternIndex - c_minReference) % m_buffer.size());
		}
	}
}

const SearchTree& SearchBuffer::tree() const
{
	return m_tree;
}

const CyclicBuffer& SearchBuffer::window() const
{
	return m_buffer;
}

int SearchBuffer::position() const
{
	return m_position;
}

void SearchBuffer::removeOldestString()
{
	const int patternIndex = m_position - c_maxEncodingLength;
	const int oldestStringIndex = patternIndex - c_windowSize;
	if (oldestStringIndex >= 0)
	{
		m_tree.remove(oldestStringIndex % m_buffer.size());
	}
}

void SearchBuffer::insertNewString()
{
	const int patternIndex = m_position - c_maxEncodingLength;

	if (patternIndex >= c_maxEncodingLength)
	{
		const int newStringIndex = patternIndex - c_maxEncodingLength;
		m_tree.insert(newStringIndex % m_buffer.size());
	}
}

void SearchBuffer::setFinishingMode(int dataLeft)
{
	ASSERT(!m_finishingMode);
	m_dataLeft = dataLeft;
	m_finishingMode = true;

	// Index left strings
	const int patternIndex = m_position - dataLeft;
	const int startIndex = max(0, patternIndex - c_maxEncodingLength);
	const int endIndex = patternIndex - c_minReference;
	for (int i = startIndex; i <= endIndex; i++)
	{
		m_tree.insert(i % m_buffer.size());
	}
}

bool SearchBuffer::finishingMode() const
{
	return m_finishingMode;
}

}