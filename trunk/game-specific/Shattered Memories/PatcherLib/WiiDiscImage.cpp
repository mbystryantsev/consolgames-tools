#include "WiiDiscImage.h"
#include <WiiFileStream.h>

using namespace Consolgames;

namespace ShatteredMemories
{

WiiDiscImage::WiiDiscImage()
{
	m_image.setProgressHandler(&m_progressNotifier);
}

bool WiiDiscImage::open(const std::wstring& filename, Stream::OpenMode mode)
{
	return m_image.open(filename, mode);
}

bool WiiDiscImage::opened() const 
{
	return m_image.opened();
}

void WiiDiscImage::close()
{
	m_image.close();
}

Stream* WiiDiscImage::openFile(const std::string& filename, Stream::OpenMode mode)
{
	return m_image.openFile(filename, mode);
}

WiiDiscImage::FileInfo WiiDiscImage::findFile(const std::string& filename)
{
	Tree<Consolgames::FileInfo>::Node* info = m_image.findFile(filename);

	if (info == NULL)
	{
		return FileInfo();
	}

	FileInfo result;
	result.offset = info->data().offset;
	result.size = info->data().size;
	return result;
}

std::string WiiDiscImage::discId() const 
{
	return m_image.discId();
}

WiiImage& WiiDiscImage::image()
{
	return m_image;
}

ProgressNotifier* WiiDiscImage::progressNotifier()
{
	return &m_progressNotifier;
}

bool WiiDiscImage::writeData(offset_t offset, Stream* stream, largesize_t size)
{
	return m_image.wii_write_data_file(m_image.dataPartition(), offset, stream, size);
}

bool WiiDiscImage::checkImage()
{
	return m_image.checkPartition(m_image.dataPartition());
}

std::string WiiDiscImage::lastErrorData() const 
{
	return m_image.lastErrorData();
}

}
