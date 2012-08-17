#include "ScriptViewWidget.h"
#include <QApplication>
#include <QHBoxLayout>
#include <QFrame>
#include <QPlainTextEdit>
#include "ScriptHighlighter.h"
#include "ScriptViewer.h"

int main(int argc, char* argv[])
{
	QApplication app(argc, argv);

// 	QFrame frame;
// 	frame.setLayout(new QHBoxLayout());
// 	frame.layout()->addWidget(new ScriptViewWidget(&frame));




// 	QPlainTextEdit* edit = new QPlainTextEdit();
// 	edit->setFont(QFont("Courier New"));
// 	new ScriptHighlighter(edit);
// 
// 	frame.layout()->addWidget(edit);

	ScriptViewer frame;

	frame.resize(640, 480);
	frame.show();

	return app.exec();
}