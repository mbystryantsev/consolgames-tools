#pragma once
#include "DiscImage.h"
#include "ProgressNotifier.h"
#include <IsoImage.h>

namespace ShatteredMemories
{

class IsoDiscImage : public DiscImage
{
public:
	virtual bool open(const std::wstring& filename, Consolgames::Stream::OpenMode mode) override;
	virtual bool opened() const override;
	virtual void close() override;
	virtual Consolgames::Stream* openFile(const std::string& filename, Consolgames::Stream::OpenMode mode) override;
	virtual bool writeData(offset_t offset, Consolgames::Stream* stream, largesize_t size) override;
	virtual FileInfo findFile(const std::string& filename) override;
	virtual std::string discId() const override;
	virtual bool checkImage() override;
	virtual std::string lastErrorData() const override;
	virtual ProgressNotifier* progressNotifier() override;

protected:
	virtual std::string loadDiscId() = 0;

protected:
	Consolgames::IsoImage m_image;
	std::string m_discId;
	ProgressNotifier m_notifier;
};

}