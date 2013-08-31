#pragma once
#include "CompoundProgressNotifier.h"
#include "DiscImage.h"
#include "ExecutablePatcher.h"
#include <WiiImage.h>
#include <QStringList>
#include <QObject>

class QStringList;

namespace ShatteredMemories
{

class DiscImage;

class PatcherProcessor : public QObject
{
	Q_OBJECT;
	Q_ENUMS(ErrorCode);

public:
	enum Platform
	{
		platformUndefined = -1,
		platformWii,
		platformPS2,
		platformPSP
	};

	enum GameId
	{
		gameUndefined = -1,
		gameShatteredMemories,
		gameOrigins
	};

	enum ErrorCategory
	{
		category_Undefined = -1,
		category_Init = 0x0,
		category_Open = 0x1,
		category_RebuildArchives = 0x2,
		category_ReplaceArchives = 0x3,
		category_CheckData = 0x4,
		category_CheckArchives = 0x5,
		category_CheckImage = 0x6,
		category_PatchExecutable = 0x7
	};

	enum ErrorCode
	{
		NoError = 0,
		Init_UnableToLoadManifest = 0x01,
		Init_InvalidManifest = 0x02,
		Init_InvalidPlatform = 0x03,
		Init_InvalidGame = 0x04,
		Init_UnableToLoadExecutablePatch = 0x05,
		Init_UnableToLoadFileList = 0x06,
		Open_UnableToOpenImage = 0x10,
		Open_InvalidDiscId = 0x11,
		Open_UnableToCreateImageFormPlatform = 0x12,
		RebuildArchives_UnableToOpenFileInImage = 0x20,
		RebuildArchives_UnableToOpenArchive = 0x21,
		RebuildArchives_UnableToRebuildArchive = 0x22,
		RebuildArchives_UnableToOpenFileInArchive = 0x23,
		RebuildArchives_UnableToSeekInExecutable = 0x24,
		RebuildArchives_InvalidBootArcSize = 0x25,
		RebuildArchives_UnableToLoadTextureDatabase = 0x26,
		RebuildArchives_UnableToParseEmbededResource = 0x27,
		ReplaceArchives_UnableToOpenArcForReplace = 0x30,
		ReplaceArchives_UnableToOpenInputPak = 0x31,
		ReplaceArchives_InputArcFileTooBig = 0x32,
		ReplaceArchives_UnableToWriteFile = 0x33,
		ReplaceArchives_UnableToOpenExecutable = 0x34,
		ReplaceArchives_UnableToParseEmbededResource = 0x35,
		ReplaceArchives_UnableToParseArc = 0x36,
		ReplaceArchives_UnableToOpenInputFileToReplace = 0x37,
		ReplaceArchives_UnableToOpenFileToReplace = 0x38,
		ReplaceArchives_InputFileTooBig = 0x39,
		CheckData_UnableToParseResultArc = 0x40,
		CheckData_UnableToOpenFile = 0x41,
		CheckData_UnableToExtractTemporaryFile = 0x42,
		CheckData_UnableToOpenFileInPak = 0x43,
		CheckData_FilesAreDifferent = 0x44,
		CheckData_InvalidFileSizeAlignment = 0x45,
		CheckArchives_UnableToOpenArchive = 0x50,
		CheckArchives_UnableToOpenResultArchive = 0x51,
		CheckArchives_InvalidArcSize = 0x52,
		CheckArchives_ArcsAreNotEqual = 0x53,
		CheckArchives_UnableToParseEmbededResource = 0x54,
		CheckArchives_InvalidBootArcSize = 0x55,
		CheckArchives_UnableToParseArchive = 0x56,
		CheckArchives_UnableToOpenExecutable = 0x57,
		CheckImage_Failed = 0x60,
		PatchExecutable_UnableToOpenFileInImage = 0x70,
		PatchExecutable_UnableToOpenTempFile = 0x71,
		PatchExecutable_UnableToExtractFileFromImage = 0x72,
		PatchExecutable_UnableToOpenFileToPatch = 0x73,
		PatchExecutable_UnableToPatchMainDol = 0x74,
		PatchExecutable_UnableToFindMainDolInImage = 0x75,
		PatchExecutable__UnableToWriteFile = 0x76
	};

private:
	struct PatchInfo
	{
		PatchInfo()
			: platform(platformUndefined)
			, game(gameUndefined)
			, embededArcOffset(0)
			, headersOffset(0)
		{
		}

		Platform platform;
		GameId game;
		QByteArray discId;
		QString executablePath;
		quint32 embededArcOffset;
		quint32 headersOffset;
		QStringList files;
	};

public:
	PatcherProcessor();
	bool init(const QString& manifestPath);
	bool openImage(const QString& path);
	bool rebuildArchives(const QString& outPath, const QStringList& resourcesPaths);
	bool replaceArchives(const QString& arcPath);
	bool checkArchives(const QString& arcPath);
	bool replaceFiles(const QStringList& resourcesPaths);
	bool checkImage();

	int errorCode() const;
	QString errorData() const;
	static ErrorCategory errorCategory(ErrorCode error);

	QObject* progressNotifier();

private:
	bool compareStreams(Consolgames::Stream* stream1, Consolgames::Stream* stream2, bool ignoreSize, double progressCoeff = 0);

private:
	
	PatchInfo m_info;
	std::auto_ptr<DiscImage> m_image; 
	ErrorCode m_errorCode;
	QString m_errorData;
	std::auto_ptr<ExecutablePatcher> m_exePatcher;
	CompoundProgressNotifier m_progressNotifier;
};

}