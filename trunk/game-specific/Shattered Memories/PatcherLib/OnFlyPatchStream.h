#pragma once
#include <Stream.h>

namespace ShatteredMemories
{

class OnFlyPatchStream : public Consolgames::Stream
{
public:
	struct PartInfo
	{
		u32 offset;
		u32 size;
	};

	class DataSource
	{
	public:
		virtual std::tr1::shared_ptr<Consolgames::Stream> getAt(int index);
		virtual int partCount() const;
		virtual PartInfo partInfoAt(int index) const;
	};

public:
	OnFlyPatchStream(std::tr1::shared_ptr<Consolgames::Stream> stream, const DataSource& dataSource);

	virtual largesize_t read(void* buf, largesize_t size) override;
	virtual largesize_t write(const void* buf, largesize_t size) override;
	virtual offset_t seek(offset_t offset, SeekOrigin origin) override;
	virtual offset_t position() const override;
	virtual void flush() override;
	virtual offset_t size() const override;

private:
	std::tr1::shared_ptr<Consolgames::Stream> m_stream;
	std::tr1::shared_ptr<Consolgames::Stream> m_currentPartStream;
	PartInfo m_currentPartInfo;
	int m_currentPartIndex;
	DataSource m_patchDataSource;
};

}
