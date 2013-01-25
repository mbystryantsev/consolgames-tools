#pragma once
#include "PathChecker.h"

class ImageFileChecker: public PathChecker
{
	Q_OBJECT

public:
	ImageFileChecker(QLineEdit* pathEdit, QObject* parent = NULL);

public:
	Q_SIGNAL void pathError();
	Q_SIGNAL void accessError();

private:
	virtual void onPathChanged() override;
};
