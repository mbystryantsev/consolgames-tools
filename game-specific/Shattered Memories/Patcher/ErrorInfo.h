#pragma once

struct ErrorInfo
{
	ErrorInfo(const QString& message = QString(), const QString& description = QString())
		: message(message)
		, description(description)
	{
	}

	static ErrorInfo fromCode(int code);

	QString message;
	QString description;
};
