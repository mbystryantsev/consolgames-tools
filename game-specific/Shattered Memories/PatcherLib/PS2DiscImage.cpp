#include "PS2DiscImage.h"
#include <QTextStream>
#include <QStringList>
#include <QFileInfo>

using namespace Consolgames;

namespace ShatteredMemories
{

std::string PS2DiscImage::loadDiscId()
{
	// Custom built or patched discs often do not save
	// game id in system sectors, so we should extract
	// the id from the SYSTEM.CNF file.

	const IsoFileDescriptor d = m_image.findFile("SYSTEM.CNF");
	if (d.isNull() || !d.isFile())
	{
		return std::string();
	}

	const std::unique_ptr<Stream> file(m_image.openFile("SYSTEM.CNF"));
	if (file.get() == NULL || !file->isOpen() || file->size() > 1024)
	{
		return std::string();
	}

	QByteArray content(file->size(), Qt::Uninitialized);
	file->read(content.data(), content.size());

	QTextStream stream(&content, QIODevice::ReadOnly);
	while (!stream.atEnd())
	{
		const QString line = stream.readLine().simplified();
		const QStringList parts = line.split('=', QString::SkipEmptyParts);
		if (parts.size() != 2)
		{
			continue;
		}

		if (parts.first().trimmed() == "BOOT2")
		{
			QString executableName = QFileInfo(parts.last().split(';').first().trimmed()).fileName();
			return executableName.remove('.').toStdString();
		}
	}

	return false;
}

}
