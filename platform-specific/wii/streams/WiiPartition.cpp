#include "WiiPartition.h"

LOG_CATEGORY("WiiPartition")

namespace Consolgames
{

Tree<FileInfo>::Node* WiiPartition::addFilesystemObject(Tree<FileInfo>::Node* parentNode, const std::string& name, offset_t offset, largesize_t size, int fstReference, FsObjectType fsType)
{
	Tree<FileInfo>::Node& node = *(parentNode->addChild());
	DLOG << "Added file: " << name.c_str();
	node->name = name;
	node->partition = m_index;
	node->offset = offset;
	node->size = size;
	node->fstReference = fstReference;
	node->dataType = fsType;
	return &node;
}

Tree<FileInfo>::Node* WiiPartition::addFilesystemObject(const std::string& name, offset_t offset, largesize_t size, int fstReference, FsObjectType fsType)
{
	return addFilesystemObject(&m_filesystem.root(), name, offset, size, fstReference, fsType);
}

uint32_t WiiPartition::parseFst(uint8_t* fstData, int index, Tree<FileInfo>::Node* node)
{
	const char* names = reinterpret_cast<const char*>(&fstData[12 * fileCount]);

	node = (node == NULL) ? &m_filesystem.root() : node;
	const char* name = names + (be32(&fstData[12 * index]) & 0x00ffffff);
	int size = be32(&fstData[12 * index + 8]);

	if (index == 0)
	{
		// directory so need to go through the directory entries
		for (int j = 1; j < size; )
		{
			j = parseFst(fstData, j, node);
		}
		return size;
	}

	if (fstData[12 * index] != 0)
	{
		node = addFilesystemObject(node, name, 0, 0, 0, dataFile);

		for (int j = index + 1; j < size; )
		{
			j = parseFst(fstData, j, node);
		}
		return size;
	}
	else
	{
		offset_t offset = be32(&fstData[12 * index + 4]);
		if (header.isWii())
		{
			offset *= 4;
		}
		addFilesystemObject(node, name, offset, size, index, dataFile);
		//markAsUsedDC(m_imageFile->parts[part].offset + m_imageFile->parts[part].data_offset, offset, size, image->parts[part].isEncrypted);

		// 			m_imageFile->nfiles++;
		// 			m_imageFile->nbytes += size;
		return index + 1;
	}
}

}
