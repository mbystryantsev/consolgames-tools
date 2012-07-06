#include <QApplication>
#include <QByteArray>
#include <QFrame>
#include <QVBoxLayout>
#include <QFile>
#include <QMessageBox>
#include <memory>
#include "MetroidProgressBar.h"
#include "PatcherDialog.h"
#include "MetroidPatcher.h"

int main(int argc, char* argv[])
{
	QApplication application(argc, argv);
	QMessageBox box;

	{
		QFile file(":/Patcher.css");
		file.open(QIODevice::ReadOnly);
		application.setStyleSheet(QString(file.readAll()));
	}


	Consolgames::MetroidPatcher patcher;
	patcher.openImage("D:\\rev\\corruption\\Metroid_3_cor[pal].iso");

	PatcherDialog dialog;
	//std::auto_ptr<QVBoxLayout> layout(new QVBoxLayout());
	//layout->addWidget(new MetroidProgressBar(&dialog, true));
	//dialog.setLayout(layout.get());
	dialog.show();

	return application.exec();
}
