#include "MetroidPatcher.h"

namespace Consolgames
{

void MetroidPatcher::openImage(const QString& filename)
{
	const bool success = m_image.open(filename.toStdWString(), Stream::modeRead);
	emit stepCompleted(success, tr("Unable to open an image file!"));
}

void MetroidPatcher::checkImage()
{
	const PartitionHeader& header = m_image.firstPartitionHeader();
	const bool success = header.isWii() && header.gamecode &&
		(strncmp(header.name, "Metroid Prime 3", sizeof(header.name)) == 0);
	emit stepCompleted(success, tr("Image is invalid. Please select valid Metroid Prime 3 image."));
}

}