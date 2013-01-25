#include "ScriptViewWidget.h"
#include <QApplication>
#include <QSplashScreen>
#include "ScriptViewer.h"

int main(int argc, char* argv[])
{
	QApplication app(argc, argv);

	QSplashScreen splashScreen(QPixmap(":/resources/splash.png"));
	splashScreen.show();

	ScriptViewer frame(NULL, &splashScreen);
	frame.resize(800, 600);
	frame.showMaximized();
	
	splashScreen.finish(&frame);

	return app.exec();
}