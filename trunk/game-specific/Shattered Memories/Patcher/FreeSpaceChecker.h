#pragma once
#include "PathChecker.h"

class FreeSpaceChecker : public PathChecker
{
	Q_OBJECT

public:
	FreeSpaceChecker(QLineEdit* pathEdit, QObject* parent = NULL);

public:
	Q_SIGNAL void pathError();
	Q_SIGNAL void freeSpaceError(quint64);

private:
	virtual void onPathChanged() override;
};
