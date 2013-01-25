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
		PagePatchType,
		PageRiivolutionPatch,
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

	void setCheckingEnabled(bool enabled);
	bool checkingEnabled() const;

	void setPatchType(PatchType type);
	PatchType patchType() const;

	void setErrorCode(int code);
	int errorCode() const;

	void setErrorData(const QString& errorData);
	QString errorData() const;

	QString version() const;

private:
	PatchType m_patchType;
	bool m_checkingEnabled;
	int m_errorCode;
	QString m_errorData;
};
