#include <ExecutablePatcher.h>
#include <FileStream.h>
#include <iostream>

using namespace Consolgames;
using namespace ShatteredMemories;

static void printUsage()
{
	std::cout
		<< "ExecutablePatcher by consolgames.ru" << std::endl
		<< "Usage: ExecutablePatcher <patch> <executable> [endian], endian = big|little" << std::endl;
}

int main(int argc, char* argv[])
{
	if (argc != 3 && argc != 4)
	{
		printUsage();
		return -1;
	}

	ExecutablePatcher patcher(argv[1]);
	if (!patcher.loaded())
	{
		std::cout << "Unable to load patch file!" << std::endl;
		return -1;
	}

	FileStream executable(argv[2], Stream::modeWrite);
	if (!executable.opened())
	{
		std::cout << "Unable to open executable file!" << std::endl;
		return -1;
	}

	if (argc > 2)
	{
		if (QString(argv[3]) == "big")
		{
			executable.setByteOrder(Stream::orderBigEndian);
		}
		else if (QString(argv[3]) != "little")
		{
			std::cout << "Invalid byte order!" << std::endl;
			return -1;
		}
	}

	if (!patcher.apply(&executable))
	{
		std::cout << "Unable to apply patch!" << std::endl;
		return -1;
	}

	return 0;
}

