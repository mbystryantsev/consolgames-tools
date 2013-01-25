#pragma once
#include <Stream.h>
#include <QByteArray>
#include <QCryptographicHash>

class HashStream : public Consolgames::Stream
{
public:
	HashStream();
	QByteArray hash() const;
	void reset();

	// Stream implementation
	virtual largesize_t read(void*, largesize_t) override {return 0;}
	virtual largesize_t write(const void* buf, largesize_t size);
	virtual offset_t seek(offset_t, SeekOrigin) override {return 0;}
	virtual offset_t tell() const override {return 0;}
	virtual void flush() override {}
	virtual offset_t size() const;


protected:
	QCryptographicHash m_hash;
};
