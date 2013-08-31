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
	DEF_ERROR(Open_UnableToOpenImage, "Невозможно открыть файл образа.", "Убедитесь, что указан правильный путь к файлу бэкап-образа и он доступен для записи.");
	DEF_ERROR(Open_InvalidDiscId, "Выбран неверный бэкап-образ.", "Убедитесь, что выбран бэкап-образ игры " GAME_TITLE " для PAL-региона.");
	}

	const PatcherProcessor::ErrorCategory category = PatcherProcessor::errorCategory(static_cast<PatcherProcessor::ErrorCode>(code));
	switch (category)
	{
	DEF_ERROR(category_Init, "Ошибка при инициализации.", "");
	DEF_ERROR(category_Open, "Невозможно открыть файл образа.", "");
	DEF_ERROR(category_RebuildArchives, "Ошибка при обработке файлов игры.", "");
	DEF_ERROR(category_CheckArchives, "Файлы игры не прошли проверку на правильность установки патча.", "");
	DEF_ERROR(category_ReplaceArchives, "Ошибка при замене данных в бэкап-образе.", "");
	DEF_ERROR(category_PatchExecutable, "Ошибка при обработке исполняемого файла игры.", "");
	DEF_ERROR(category_CheckData, "Бэкап-образ не прошёл проверку на правильность установки патча.", "");
	DEF_ERROR(category_CheckImage, "Бэкап-образ не прошёл проверку на правильность установки патча.", "");
	}


	return ErrorInfo(QObject::tr("Ошибка при установке патча"), QObject::tr(""));
}

#undef ERROR
