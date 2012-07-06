#include <QCoreApplication>
#include <QDir>
#include <QCryptographicHash>
#include <iostream>

using namespace std;

int main(int argc, char** argv)
{
	QCoreApplication app(argc, argv);
	
	if (app.arguments().count() < 3)
	{
		return 0;
	}

	const QString path = app.arguments()[1];
	const QString baseFileName = app.arguments()[2];
	
	QDir dir(path);
	QStringList files = dir.entryList(QDir::Files);

	QFile baseFile(baseFileName);
	baseFile.open(QIODevice::WriteOnly | QIODevice::Text);

	int num = 1;
	foreach (const QString& filename, files)
	{
		std::cout << "[" << num++ << "/" << files.count() << "] Processing " << filename.toStdString() << "..." << std::endl; 

		QFile file(path + "/" + filename);
		file.open(QIODevice::ReadOnly);

		const int size = file.size();

		QByteArray data = file.readAll();
		QCryptographicHash hash(QCryptographicHash::Md5);
		hash.addData(data);

		baseFile.write
			(
				QString("%1 %2 %3\n")
					.arg(filename)
					.arg(size)
					.arg(QString::fromLatin1(hash.result().toHex()))
					.toLatin1()
			);
	}
}
