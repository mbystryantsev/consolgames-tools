#include "MainFrame.h"
#include <QApplication>

int main(int argc, char* argv[])
{
	QApplication app(argc, argv);
	QApplication::setOrganizationName("Consolgames");
	QApplication::setOrganizationDomain("consolgames.ru");
	QApplication::setApplicationName("SHSM Worker Patcher");

	MainFrame mainFrame;
	mainFrame.show();
	return app.exec();
}