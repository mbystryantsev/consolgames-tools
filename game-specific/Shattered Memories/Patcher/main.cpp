#include "PatchWizard.h"
#include "PatchSpec.h"
#include "Configurator.h"
#include <QApplication>
#include <QIcon>
#include <QLocale>
#include <QFile>
#include <QTranslator>
#include <QTextCodec>

QString loadTextFile(const QString& filename, const QString& defaultText = "")
{
	QFile file(filename);
	if (!file.open(QIODevice::ReadOnly))
	{
		return defaultText;
	}
	return file.readAll();
}

int main(int argc, char* argv[])
{
	QLocale::setDefault(QLocale(QLocale::Russian, QLocale::RussianFederation));

	QApplication application(argc, argv);
#if QT_VERSION >= 0x040000 && QT_VERSION < 0x050000
	QTextCodec::setCodecForTr(QTextCodec::codecForName("Windows-1251"));
#else
#if defined(PRODUCTION)
#error "Supported only Qt4, some strings in GUI will be unreadable!"
#endif
#endif

	QTranslator *translator = new QTranslator(&application); 
	if (translator->load(":/qt_ru.qm")) 
	{
		application.installTranslator(translator);
	}

	application.setStyleSheet(loadTextFile(":/Patcher.css"));
	application.setWindowIcon(QIcon(":/icon.png"));
	application.setApplicationName(GAME_TITLE " Translation Patch");
	application.setApplicationVersion(loadTextFile(":/version", "1.0"));
	application.setOrganizationName("Consolgames");
	application.setOrganizationDomain("consolgames.ru");

#if !defined(PRODUCTION)
	const bool checkingEnabled = !application.arguments().contains("--no-check");
#else
	const bool checkingEnabled = application.arguments().contains("--check");
#endif

	Configurator& configurator = Configurator::instance();
	configurator.setDebug(checkingEnabled);

	configurator.setAvailablePlatforms(Configurator::parsePlatforms(PLATFORMS));

	PatchWizard wizard;
	wizard.show();

	return application.exec();
}
