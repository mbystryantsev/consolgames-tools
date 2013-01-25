#pragma once
#include <pak.h>

//! Wrapper class for possibility to use Qt resource file system
class QtPakArchive : public PakArchive
{
protected:
	virtual std::wstring findFile(const std::vector<std::wstring>& inputDirs, Hash hash, ResType res) const override;
	virtual u32 storeFile(const std::wstring& filename, Consolgames::Stream* stream, bool isPacked, bool isTexture, u8 flags) override;
};