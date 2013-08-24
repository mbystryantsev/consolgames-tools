#pragma once
#include <QMap>
#include <QByteArray>

class QTextStream;

namespace Consolgames
{
class Stream;
}

namespace ShatteredMemories
{

class ExecutablePatcher
{
public:
	ExecutablePatcher(const QString& filename);
	bool loaded() const;
	bool apply(Consolgames::Stream* executableStream) const;

private:
	struct SpaceRecord
	{
		SpaceRecord(quint32 offset = 0, quint32 size = 0)
			: offset(offset)
			, size(size)
		{
		}

		bool isNull() const
		{
			return size <= 0;
		}

		quint32 offset;
		int size;
	};

	enum Type
	{
		typeByte,
		typeWord,
		typeInt,
		typeString
	};

	struct PatchRecord
	{
		Type type;
		QList<quint32> offsets;
		QList<quint32> values;
	};

private:
	bool loadFromStream(QTextStream* stream);
	bool loadMessages(const QString& filename);
	static quint32 allocSpace(QList<SpaceRecord>& space, int size);
	quint32 fileOffset(quint32 memOffset) const;

private:
	QString m_filename;
	bool m_loaded;
	quint32 m_executableStartOffset;
	quint32 m_executableLoadOffset;
	QList<SpaceRecord> m_spaceRecords;
	QList<PatchRecord> m_patchRecords;
	QMap<quint32, QByteArray> m_messages;
};

}