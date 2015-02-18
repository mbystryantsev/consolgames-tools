#pragma once
#include "IsoDiscImage.h"

namespace ShatteredMemories
{

class PSPDiscImage : public IsoDiscImage
{
protected:
	virtual std::string loadDiscId() override;
};

}
