#pragma once
#include <WiiImage.h>
#include <QObject>

namespace Consolgames
{
	class Stream;
}

class WiiImageTests : public QObject
{
	Q_OBJECT

private:
	Q_SLOT void initTestCase();
	Q_SLOT void filesTest();
	Q_SLOT void fileStreamsTest();
	Q_SLOT void writeFileTest();
	Q_SLOT void cleanupTestCase();

private:
	static QByteArray calcHash(Consolgames::Stream* file);
	static quint64 getFreeSpace();

private:
	static const std::string s_imageFilename;
	Consolgames::WiiImage m_image;
};