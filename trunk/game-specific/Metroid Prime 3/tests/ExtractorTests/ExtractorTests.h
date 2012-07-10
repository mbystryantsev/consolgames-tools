#pragma once
#include <pak.h>
#include <QObject>
#include <QMap>

class ExtractorTests : public QObject
{
	Q_OBJECT;

private:
	Q_SLOT void initTestCase();
	Q_SLOT void extractTest();
	Q_SLOT void rebuildTest();

private:
	void loadHashDatabase();

private:
	QMap<Hash, QByteArray> m_hashes;
	PakArchive m_pakArchive;
};
