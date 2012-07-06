#include "DataPackage.h"

bool DataPackage::open(const std::string& filename, OpenMode mode)
{
	m_packageFile.open(filename.c_str(), std::ios_base::in | std::ios::binary | (mode == ReadWrite ? std::ios_base::out : 0));
	if (!m_packageFile.is_open())
	{
		return false;
	}

	PackageHeader header;
	m_packageFile.read(reinterpret_cast<char*>(&header), sizeof(header));

	m_packageFile.seekg(0, std::ios_base::end);
	if (header.totalSize != m_packageFile.tellg())
	{
		m_packageFile.close();
		return false;
	}
	m_packageFile.seekg(sizeof(header), std::ios_base::beg);

	m_files.resize(header.fileCount);
	m_packageFile.read(reinterpret_cast<char*>(&m_files[0]), header.fileCount * sizeof(FileRecord));

	return true;
}

const FileList& DataPackage::files() const
{
	return m_files;
}

int DataPackage::fileCount() const
{
	return m_files.size();
}

void DataPackage::seekTo(const FileRecord& fileRecord)
{
	m_packageFile.seekg(fileRecord.offset, std::ios::beg);
}

void DataPackage::readRaw(void* data, int size)
{
	m_packageFile.read(reinterpret_cast<char*>(data), size);
}