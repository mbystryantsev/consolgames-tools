#pragma once
#include <QObject>

class ScriptParserTests : public QObject
{
	Q_OBJECT;

	Q_SLOT void parseMessage();
	Q_SLOT void parseMessageCrLf();
	Q_SLOT void parseMessageCrLf2();
	Q_SLOT void parseMessageCrLf3();
	Q_SLOT void parseMessageMultiline();
	Q_SLOT void parseMessageFromSet();
	Q_SLOT void parseEmptyMessage();
	Q_SLOT void parseEmptyMessageCrLf();
	Q_SLOT void parseMessageSet();
	Q_SLOT void parseEmptyMessageSet();
	Q_SLOT void parseMultiHashesMessageSet();
	Q_SLOT void readScript();
};
