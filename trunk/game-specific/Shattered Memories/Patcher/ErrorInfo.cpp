#include "ErrorInfo.h"
#include "PatchSpec.h"
#include <PatcherProcessor.h>
#include <QObject>

using namespace ShatteredMemories;

#define DEF_ERROR(code, message, description) \
	case PatcherProcessor::code: \
		return ErrorInfo(QObject::tr(message), QObject::tr(description))

ErrorInfo ErrorInfo::fromCode(int code)
{
	switch (code)
	{
	DEF_ERROR(Open_UnableToOpenImage, "���������� ������� ���� ������.", "���������, ��� ������ ���������� ���� � ����� �����-������ � �� �������� ��� ������.");
	DEF_ERROR(Open_InvalidDiscId, "������ �������� �����-�����.", "���������, ��� ������ �����-����� ���� " GAME_TITLE " ��� PAL-�������.");
	}

	const PatcherProcessor::ErrorCategory category = PatcherProcessor::errorCategory(static_cast<PatcherProcessor::ErrorCode>(code));
	switch (category)
	{
	DEF_ERROR(category_Init, "������ ��� �������������.", "");
	DEF_ERROR(category_Open, "���������� ������� ���� ������.", "");
	DEF_ERROR(category_RebuildArchives, "������ ��� ��������� ������ ����.", "");
	DEF_ERROR(category_CheckArchives, "����� ���� �� ������ �������� �� ������������ ��������� �����.", "");
	DEF_ERROR(category_ReplaceArchives, "������ ��� ������ ������ � �����-������.", "");
	DEF_ERROR(category_PatchExecutable, "������ ��� ��������� ������������ ����� ����.", "");
	DEF_ERROR(category_CheckData, "�����-����� �� ������ �������� �� ������������ ��������� �����.", "");
	DEF_ERROR(category_CheckImage, "�����-����� �� ������ �������� �� ������������ ��������� �����.", "");
	}


	return ErrorInfo(QObject::tr("������ ��� ��������� �����"), QObject::tr(""));
}

#undef ERROR
