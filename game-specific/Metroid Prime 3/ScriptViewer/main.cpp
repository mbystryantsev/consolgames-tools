#include "ScriptViewWidget.h"
#include <QApplication>
#include "ScriptViewer.h"

int main(int argc, char* argv[])
{
	QApplication app(argc, argv);

	ScriptViewer frame;
	frame.resize(800, 600);
	frame.showMaximized();

	return app.exec();
}