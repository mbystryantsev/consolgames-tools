#pragma once
#include <pak.h>
#include <QObject>
#include <QMap>
#include <vector>
#include <string>

class ExtractorTests : public QObject
{
	Q_OBJECT;

private:
	Q_SLOT void initTestCase();
	Q_SLOT void extractTest();
	Q_SLOT void rebuildSimplyTest();
	Q_SLOT void rebuildTest();

private:
	static void loadHashDatabase(const QString& hashesFile, QMap<Hash, QByteArray>& hashes);
	static void compareHashes(PakArchive& pak, const QMap<Hash, QByteArray>& hashes);
	static void testRebuild(PakArchive& pak, const QMap<Hash, QByteArray>& hashes, const std::vector<std::string>& inputDirs);

private:
	QMap<Hash, QByteArray> m_hashes;
	PakArchive m_pakArchive;
};
