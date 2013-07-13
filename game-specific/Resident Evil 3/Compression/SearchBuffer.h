#pragma once
#include "CyclicBuffer.h"
#include <SearchTree.h>
#include <core.h>

namespace Consolgames
{
class Stream;
}

namespace ResidentEvil
{

class SearchBuffer
{
public:
	SearchBuffer(int windowSize, int maxEncodeLength, int minReference);

	void write(uint8 c);
	void write(Consolgames::Stream* stream, int count);
	void processLastBytes(int count);
	void setFinishingMode(int dataLeft);
	int position() const;
	bool finishingMode() const;

	const Consolgames::Compression::SearchTree& tree() const;
	const CyclicBuffer& window() const;

private:
	void removeOldestString();
	void insertNewString(int forwardBufferSize);

private:
	CyclicBuffer m_buffer;
	Consolgames::Compression::SearchTree m_tree;
	const int c_minReference;
	const int c_windowSize;
	const int c_maxEncodingLength;
	int m_position;
	bool m_finishingMode;
	int m_dataLeft;
};

}