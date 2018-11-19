#include "Archive.h"
#include "Compressor.h"
#include <PartStream.h>

using namespace Consolgames;

namespace ResidentEvil
{

Archive::Archive(Stream* stream, Stream* slesStream, uint32 offsetsAddr, int fileCount)
	: m_stream(stream)
	, m_position(-1)
{
	parseOffsets(slesStream, offsetsAddr, fileCount);
}


void Archive::parseOffsets(Stream* slusStream, uint32 offsetsAddr, int fileCount)
{
	if (slusStream == NULL || !slusStream->isOpen())
	{
		return;
	}

	m_offsets.resize(fileCount);
	slusStream->seek(offsetsAddr, Stream::seekSet);

	for (int i = 0; i < fileCount; i++)
	{
		m_offsets[i] = slusStream->read32();
	}
}

bool Archive::next()
{
	m_position++;

	if (m_position == m_offsets.size())
	{
		return false;
	}

	return true;
}

bool Archive::extract(Consolgames::Stream* outStream)
{
	if (m_position < 0 || m_position >= static_cast<int>(m_offsets.size()))
	{
		return false;
	}

	m_stream->seek(m_offsets[m_position], Stream::seekSet);
	const uint32 compressedSize = (m_position == m_offsets.size() - 1 ? static_cast<uint32>(m_stream->size()) : m_offsets[m_position + 1]) - m_offsets[m_position];

	return Compressor::decode(&PartStream(m_stream, m_stream->position(), compressedSize), outStream);
}

}
