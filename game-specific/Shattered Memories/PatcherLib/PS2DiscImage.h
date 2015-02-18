#pragma once
#include "IsoDiscImage.h"

namespace ShatteredMemories
{

class PS2DiscImage : public IsoDiscImage
{
protected:
	virtual std::string loadDiscId() override;
};

}
