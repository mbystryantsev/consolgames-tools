#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <iostream>

void buildHashDatabase(const QString& sourceDir, const QString& destFile)
{
	QDir dir(sourceDir);
	if (!dir.exists())
	{
		std::cout << "Source directory does not exists!" << std::endl;
		return;
	}

	QFile hashDB(destFile);
	if (!hashDB.open(QIODevice::WriteOnly | QIODevice::Text))
	{
		std::cout << "Unable to open result file!" << std::endl;
		return;
	}
	QTextStream stream(&hashDB);

	std::cout << "Calculating..." << std::endl;

	foreach (const QString& filename, dir.entryList(QDir::Files))
	{
		QFile file(sourceDir + "/" + filename);
		if (!file.open(QIODevice::ReadOnly))
		{
			std::cout << "Warning: Unable to open " << filename.toStdString() << std::endl;
			continue;
		}

		char buffer[1024];
		qint64 size = file.size();

		QCryptographicHash hash(QCryptographicHash::Md5);
		while (size > 0)
		{
			qint64 readed = file.read(buffer, sizeof(buffer));
			hash.addData(buffer, static_cast<int>(readed));
			size -= readed;
		}
		stream << filename << " " << hash.result().toHex().toUpper() << "\n";
	}

	std::cout << "Done!" << std::endl;
}

void printUsage()
{
	std::cout << "Hash database creator by consolgames.ru" << std::endl;
	std::cout << "Usage: <inputDir> <dbFile>" << std::endl;
}

int main(int argc, char* argv[])
{
	QCoreApplication app(argc, argv);

	if (QCoreApplication::arguments().size() >= 3)
	{
		const QString sourceDir = QCoreApplication::arguments()[1];
		const QString destFile = QCoreApplication::arguments()[2];
		buildHashDatabase(sourceDir, destFile);
	}
	else
	{
		printUsage();
	}
	return 0;
}
