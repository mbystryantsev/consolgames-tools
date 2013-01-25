#pragma once
#include <QObject>
#include <WiiImage.h>

namespace Consolgames
{

class MetroidPatcher : public QObject
{
	Q_OBJECT
public:
	Q_SLOT void openImage(const QString& filename);
	Q_SLOT void checkImage();

	Q_SIGNAL void stepCompleted(bool result, const QString& errorMessage);
protected:
	WiiImage m_image;
};

}
