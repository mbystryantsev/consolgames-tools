#pragma once
#include "DiscImage.h"
#include <WiiImage.h>
#include <WiiImageProgressNotifier.h>

namespace ShatteredMemories
{

class WiiDiscImage : public DiscImage
{
public:
	WiiDiscImage();		

	virtual bool open(const std::wstring& filename, Consolgames::Stream::OpenMode mode) override;
	virtual bool isOpen() const override;
	virtual void close() override;
	virtual Consolgames::Stream* openFile(const std::string& filename, Consolgames::Stream::OpenMode mode) override;
	virtual bool writeData(offset_t offset, Consolgames::Stream* stream, largesize_t size) override;
	virtual FileInfo findFile(const std::string& filename) override;
	virtual std::string discId() const override;
	virtual ProgressNotifier* progressNotifier() override;
	virtual bool checkImage() override;
	virtual std::string lastErrorData() const override;

	Consolgames::WiiImage& image();

private:
	Consolgames::WiiImage m_image;
	WiiImageProgressNotifier m_progressNotifier;
};

}
