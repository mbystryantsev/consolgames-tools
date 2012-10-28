#pragma once
#include <pak.h>

//! Wrapper class for possibility to use Qt resource file system
class QtPakArchive : public PakArchive
{
protected:
	virtual std::string findFile(const std::vector<std::string>& inputDirs, Hash hash, ResType res) const override;
	virtual u32 storeFile(const std::string& filename, Consolgames::Stream* stream, bool isPacked, bool isTexture, u8 flags) override;
};