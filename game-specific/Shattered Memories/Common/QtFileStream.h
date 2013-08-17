#pragma once
#include <Stream.h>
#include <QFile>

namespace ShatteredMemories
{

// Wrapper class for possibility to use Qt resource file system
class QtFileStream : public Consolgames::Stream
{
public:
	QtFileStream(const QString& filename, QIODevice::OpenMode mode = QIODevice::ReadOnly);

	QString fileName() const;

	virtual largesize_t read(void* buf, largesize_t size) override;
	virtual largesize_t write(const void* buf, largesize_t size) override;
	virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
	virtual offset_t position() const override;
	virtual void flush() override;
	virtual largesize_t size() const override;
	virtual bool opened() const override;
	virtual bool atEnd() const override;

	QFile& file();

private:
	QFile m_file;
};

}