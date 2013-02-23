#pragma once
#include <WiiImage.h>

class QStringList;

namespace ShatteredMemories
{

class PatcherProcessor
{
public:
	enum ErrorCode
	{
		NoError = 0,
		Open_UnableToOpenImage = 0x10,
		Open_InvalidDiscId = 0x11,
		RebuildArchives_UnableToOpenFileInImage = 0x20,
		RebuildArchives_UnableToOpenArchive = 0x21,
		RebuildArchives_UnableToRebuildArchive = 0x22,
		RebuildArchives_UnableToOpenFileInArchive = 0x23,
		RebuildArchives_UnableToSeekInExecutable = 0x24,
		RebuildArchives_InvalidBootArcSize = 0x25,
		RebuildArchives_UnableToLoadTextureDatabase = 0x26,
		ReplaceArchives_UnableToOpenPakForReplace = 0x30,
		ReplaceArchives_UnableToOpenInputPak = 0x31,
		ReplaceArchives_InputPakFileTooBig = 0x32,
		ReplaceArchives_UnableToWriteFile = 0x33,
		CheckData_UnableToParseResultPak = 0x40,
		CheckData_UnableToOpenFile = 0x41,
		CheckData_UnableToExtractTemporaryFile = 0x42,
		CheckData_UnableToOpenFileInPak = 0x43,
		CheckData_FilesAreDifferent = 0x44,
		CheckData_InvalidFileSizeAlignment = 0x45,
		CheckPaks_UnableToOpenPak = 0x50,
		CheckPaks_UnableToOpenResultPak = 0x51,
		CheckPaks_InvalidPakSize = 0x52,
		CheckPaks_PaksAreNotEqual = 0x53,
		CheckImage_Failed = 0x60,
		PatchMainDol_UnableToOpenFileInImage = 0x70,
		PatchMainDol_UnableToOpenTempFile = 0x71,
		PatchMainDol_UnableToExtractFileFromImage = 0x72,
		PatchMainDol_UnableToOpenFileToPatch = 0x73,
		PatchMainDol_UnableToPatchMainDol = 0x74,
		PatchMainDol_UnableToFindMainDolInImage = 0x75,
		PatchMainDol__UnableToWriteFile = 0x76
	};

	struct BootArcInfo
	{
		BootArcInfo()
			: offset(0)
			, size(0)
			, sizeOffset(0)
		{
		}

		QString executableName;
		quint32 offset;
		quint32 size;
		quint32 sizeOffset;
	};

public:
	PatcherProcessor();
	bool openImage(const QString& path);
	bool rebuildArchives(const QString& outPath, const QStringList& resourcesPath, const BootArcInfo& info);
	int errorCode() const;
	QString errorData() const;

private:
	Consolgames::WiiImage m_image;
	ErrorCode m_errorCode;
	QString m_errorData;
};

}