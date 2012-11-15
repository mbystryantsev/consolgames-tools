#pragma once
#include <pak.h>
#include <WiiImage.h>
#include <QString>
#include <string>

class PakToWiiImageProgressHandlerAdapter : public Consolgames::WiiImage::IProgressHandler
{
public:
	PakToWiiImageProgressHandlerAdapter() : m_handler(NULL)
	{
	}
	virtual void startProgress(const char*, int maxValue)
	{
		if (m_handler != NULL)
		{
			m_handler->init(maxValue);
		}
	}
	virtual void progress(int value)
	{
		if (m_handler != NULL)
		{
			m_handler->progress(value, NULL);
		}
	}
	virtual void finishProgress()
	{
		if (m_handler != NULL)
		{
			m_handler->finish();
		}
	}
	virtual bool stopRequested()
	{
		if (m_handler == NULL)
		{
			return false;
		}
		return m_handler->stopRequested();
	}
	void setHandler(IPakProgressHandler* handler)
	{
		m_handler = handler;
	}

private:
	IPakProgressHandler* m_handler;
};

class QStringList;

class DataPaster
{
public:
	enum ErrorCode
	{
		NoError = 0,
		Open_UnableToOpenImage = 0x10,
		Open_InvalidDiscId = 0x11,
		RebuildPaks_UnableToOpenFileInImage = 0x20,
		RebuildPaks_UnableToParsePak = 0x21,
		RebuildPaks_UnableToRebuildPak = 0x22,
		ReplacePaks_UnableToOpenPakForReplace = 0x30,
		ReplacePaks_UnableToOpenInputPak = 0x31,
		ReplacePaks_InputPakFileTooBig = 0x32,
		ReplacePaks_UnableToWriteFile = 0x33,
		CheckData_UnableToParseResultPak = 0x40,
		CheckData_UnableToOpenFile = 0x41,
		CheckData_UnableToExtractTemporaryFile = 0x42,
		CheckData_UnableToOpenFileInPak = 0x43,
		CheckData_FilesAreDifferent = 0x44,
		CheckPaks_UnableToOpenPak = 0x50,
		CheckPaks_UnableToOpenResultPak = 0x51,
		CheckPaks_InvalidPakSize = 0x52,
		CheckPaks_PaksAreNotEqual = 0x53,
	};

public:

	DataPaster(const QString& wiiImageFile);

	bool open();
	bool rebuildPaks(const QStringList& pakArchives, const std::vector<std::string>& inputDirs, const std::string& outDir);
	bool replacePaks(const QStringList& pakArchives, const QString& inputDir);
	bool checkData(const QStringList& pakArchives, const QStringList& inputDirs, const QString& outDir, const QString& tempDir = QString());
	bool checkPaks(const QStringList& pakArchives, const QString& paksDir);
	bool checkImage();
	void setProgressHandler(IPakProgressHandler* handler);
	void setActionProgressHandler(IPakProgressHandler* handler);
	void setMergeMap(const std::map<Hash,Hash>& mergeMap);
	static void loadMergeMap(const QString& filename, std::map<Hash,Hash>& mergeMap);

	ErrorCode errorCode() const;
	QString errorData() const;

protected:
	bool compareStreams(Consolgames::Stream* stream1, Consolgames::Stream* stream2, bool ignoreSize = false) const;

protected:
	QString m_imageFilename;
	Consolgames::WiiImage m_image;
	std::map<Hash,Hash> m_mergeMap;
	IPakProgressHandler* m_pakProgressHandler;
	IPakProgressHandler* m_actionProgressHandler;
	PakToWiiImageProgressHandlerAdapter m_pakToWiiImageProgressHandlerAdapter;

	ErrorCode m_errorCode;
	QString m_errorData;
};