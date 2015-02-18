#include "PSPDiscImage.h"
#include <QByteArray>
#include <QString>

using namespace Consolgames;

namespace ShatteredMemories
{


std::string PSPDiscImage::loadDiscId()
{
	const char* paramSfoPath = "UMD_DATA.BIN";

	IsoFileDescriptor d = m_image.findFile(paramSfoPath);
	if (d.isNull() || !d.isFile())
	{
		return std::string();
	}

	std::auto_ptr<Stream> file(m_image.openFile(paramSfoPath));
	if (file.get() == NULL || !file->opened() || file->size() > 1024)
	{
		return std::string();
	}

	QByteArray content(file->size(), Qt::Uninitialized);
	file->read(content.data(), content.size());

	const int separatorPos = content.indexOf("|");
	if (separatorPos != -1)
	{
		return content.left(separatorPos).constData();
	}

	return std::string();
}

}
