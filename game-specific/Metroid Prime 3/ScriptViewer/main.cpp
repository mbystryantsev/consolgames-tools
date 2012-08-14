#include "ScriptViewWidget.h"
#include <QApplication>
#include <QHBoxLayout>
#include <QFrame>

int main(int argc, char* argv[])
{
	QApplication app(argc, argv);

	QFrame frame;
	frame.setLayout(new QHBoxLayout());
	frame.layout()->addWidget(new ScriptViewWidget(&frame));
	frame.resize(256, 256);
	frame.show();

	return app.exec();
}