#include "MessageSet.h"
#include "FontGenerator.h"
#include <iostream>
#include <QApplication>
#include <QDir>

using namespace std;

int main(int argc, char** argv)
{
	QApplication app(argc, argv);

	FontGenerator gen;
 	gen.addMessage("testgl!Iih");
 	//qDebug(gen.alphabet().toAscii());
 	gen.texture();//.save("test.png", "PNG");

	return 0;

	QDir dir("E:/misc/ff1/ff1psp/");
	

	QStringList list = dir.entryList(QDir::Dirs | QDir::NoDot | QDir::NoDotDot);

	foreach (const QString directory, list)
	{
		if (directory.startsWith("FM_")
			|| directory.startsWith("J1")
			|| directory.startsWith("J2")
			|| directory.startsWith("EVM")
			|| directory.endsWith("J1")
			|| directory.endsWith("J2"))
		{
			continue;
		}

		QDir msgDir(dir.path() + "/" + directory);
		QStringList msgFiles = msgDir.entryList(QStringList() << "*.MSG", QDir::Files);
		QStringList fifFiles = msgDir.entryList(QStringList() << "*.FIF", QDir::Files);

		FontInfo info;
		if (fifFiles.size() > 0)
		{
			info.open(msgDir.path() + "/" + fifFiles[0]);
		}

		for (int i = 0; i < msgFiles.size(); i++)
		{
			qDebug(directory.toLocal8Bit() + "/" + msgFiles[i].toLocal8Bit());

			MessageSet messages;
			messages.open(msgDir.path() + "/" + msgFiles[i], info);

			QFile file("text/" + QFileInfo(msgFiles[i]).baseName() + ".txt");
			file.open(QIODevice::WriteOnly | QIODevice::Text);
			file.write(QString("[@%1/%2,%3,%4,%5]\n\n").arg(directory).arg(msgFiles[i]).arg(messages.messages().size()).arg(info.height()).arg(fifFiles[0]).toUtf8());

			foreach (const QString& string, messages.messages())
			{
				file.write(string.toUtf8());
				file.write(QString("\n{E}\n\n").toUtf8());
// 				qDebug("Message:");
// 				qDebug(string.toAscii().constData());
// 				qDebug("");
				//cout << string.constData() << endl;
			}
		}
	}
	return 0;
}
