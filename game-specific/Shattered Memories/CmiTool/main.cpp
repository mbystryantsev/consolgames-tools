#include "Map.h"
#include <cstring>
#include <iostream>

using namespace Origins;

void printUsage()
{
	std::cout << "CMI Tool by consolgames.ru\n"
		"Usage:\n"
		"  -d,--decode <map.cmi> <Layer1.png> [Layer0.png] [BG.png]\n"
		"    Decode map.cmi file, save layers to png files\n"
		"  -e,--encode <Layer1.png> <Layer0.png> <BG.png> <map.cmi>\n"
		"    Encode map.cmi from specified layers\n";
}

bool isAction(const char* action, const char* shortName, const char* longName)
{
	return (strcmp(action, shortName) == 0 || strcmp(action, longName) == 0);
}

int main(int argc, const char* argv[])
{
	if (argc <= 1)
	{
		printUsage();
		return 0;
	}

	const char* action = argv[1];

	if (isAction(action, "-d", "--decode"))
	{
		if (argc < 3 || argc > 6)
		{
			std::cout << "Invalid parameter count specified!" << std::endl;
			return -1;
		}

		std::cout << "Decoding map..." << std::endl;

		Map map;
		
		if (!map.open(argv[2]))
		{
			std::cout << "Unable to open map file!" << std::endl;
			return -1;
		}

		if (!map.saveLayer1(argv[3]))
		{
			std::cout << "Unable to save layer 1!" << std::endl;
			return -1;
		}

		if (argc >= 5 && !map.saveLayer0(argv[4]))
		{
			std::cout << "Unable to save layer 0!" << std::endl;
			return -1;
		}

		if (argc == 6 && !map.saveBG(argv[5]))
		{
			std::cout << "Unable to save bg!" << std::endl;
			return -1;
		}

		std::cout << "Done!" << std::endl;
	}
	else if (isAction(action, "-e", "--encode"))
	{
		if (argc != 6)
		{
			std::cout << "Invalid parameter count specified!" << std::endl;
			return -1;
		}

		std::cout << "Encoding map..." << std::endl;

		Map map;

		if (!map.loadLayer1(argv[2]))
		{
			std::cout << "Unable to load layer 1!" << std::endl;
			return -1;
		}

		if (!map.loadLayer0(argv[3]))
		{
			std::cout << "Unable to load layer 0!" << std::endl;
			return -1;
		}

		if (!map.loadBG(argv[4]))
		{
			std::cout << "Unable to load bg!" << std::endl;
			return -1;
		}

		if (!map.save(argv[5]))
		{
			std::cout << "Unable to encode map!" << std::endl;
			return -1;
		}

		std::cout << "Done!" << std::endl;

	}

	return 0;
}
