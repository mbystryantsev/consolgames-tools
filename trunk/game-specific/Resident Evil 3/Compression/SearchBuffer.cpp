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
	insertNewString(c_maxEncodingLength);
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
		insertNewString(m_dataLeft);
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

void SearchBuffer::insertNewString(int forwardBufferSize)
{
	const int patternIndex = m_position - forwardBufferSize;

	if (patternIndex >= c_minReference)
	{
		const int newStringIndex = patternIndex - c_minReference;
		m_tree.insert(newStringIndex % m_buffer.size());
	}
}

void SearchBuffer::setFinishingMode(int dataLeft)
{
	ASSERT(!m_finishingMode);
	m_dataLeft = dataLeft;
	m_finishingMode = true;
}

bool SearchBuffer::finishingMode() const
{
	return m_finishingMode;
}

}