#include <MetroidFont.h>
#include <TextureAtlas.h>
#include <QCoreApplication>
#include <QStringList>
#include <iostream>

using namespace std;
using namespace Consolgames;

static const QString s_interpolationHintStr = "--interpolation-hint";

void printUsage()
{
	cout << "Metroid Prime 3 Font Tool by consolgames.ru" << endl;
	cout << "Usage: " << endl;
	cout << "  -c, --convert <source file in editor format> <dest FONT file> <dest TXTR file> [--interpolation-hint]" << endl;
	cout << "    You can use %TEXHASH% macro to define texture hash in TXTR filename." << endl;
	cout << "    Example: --convert font.mft 8E959CB18B3E28C1.FONT %TEXHASH%.TXTR" << endl;
}

bool checkAction(const QStringList& args, int argumentCount, const QString& shortCmd, const QString& cmd)
{
	if (args.size() == argumentCount + 3 && args[5] != s_interpolationHintStr)
	{
		cout << "Unknown argument: " << args[5].constData() << endl;
		return false;
	}
	return (args.size() >= argumentCount + 2 && (args[1] == shortCmd || args[1] == cmd));
}

const QString& extractArg(const QStringList& args, int index)
{
	return args[index + 2];
}

QString hashToStr(quint64 hash)
{
	const QString temp = QString::number(hash, 16).toUpper();
	QString hashStr(16, '0');
	qCopy(temp.begin(), temp.end(), hashStr.end() - temp.size());
	return hashStr;
}

int convertFromEditorFormat(const QString& sourceFontFilename, const QString& destFontFilename, const QString& destTextureFilename, bool interpolationHint)
{
	MetroidFont font;
	if (!font.loadFromEditorFormat(sourceFontFilename, interpolationHint))
	{
		cout << "Unable to load font file!" << endl;
		return -1;
	}

	if (!font.save(destFontFilename, QString(destTextureFilename).replace("%TEXHASH%", hashToStr(font.textureHash()))))
	{
		cout << "Unable to save font files!" << endl;
		return -1;
	}

	return 0;
}

int main(int argc, char* argv[])
{
	QCoreApplication app(argc, argv);
	const QStringList arguments = QCoreApplication::arguments();

	if (checkAction(arguments, 3, "-c", "--convert"))
	{
		const QString& sourceFontFilename = extractArg(arguments, 0);
		const QString& destFontFilename = extractArg(arguments, 1);
		const QString& destTextureFilename = extractArg(arguments, 2);
		const bool interpolationHint = arguments.contains(s_interpolationHintStr);
		return convertFromEditorFormat(sourceFontFilename, destFontFilename, destTextureFilename, interpolationHint);
	}

	printUsage();

	return (arguments.size() == 1 ? 0 : -1);
}
