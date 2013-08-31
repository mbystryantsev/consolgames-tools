#pragma once
#include <QWizard>

class PatchWizard: public QWizard
{
	Q_OBJECT

public:
	enum Pages
	{
		PageIntro,
		PageEula,
		PageImagePatch,
		PageProgress,
		PageFailed,
		PageCanceled,
		PageCompleted
	};
	enum PatchType
	{
		ImagePatch,
		RiivolutionPatch
	};

public:
	PatchWizard(QWidget* parent = NULL);

private:
	PatchType m_patchType;
	bool m_checkingEnabled;
	int m_errorCode;
	QString m_errorData;
};
