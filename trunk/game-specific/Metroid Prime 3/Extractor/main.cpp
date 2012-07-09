#include <pak.h>
#include <set>
#include <iostream>

void printUsage()
{
	std::cout << "Metroid Prime 3: Corruption PAK Extractor by consolgames.ru" << std::endl;
	std::cout << "Usage:" << std::endl;
	std::cout << "  -e <InFile> <OutDir> [Type1 Type2 ... TypeN]" << std::endl;
	std::cout << "  Type: resource type (TXTR, STRG, FONT, etc.)";
}

class ProgressHandler : public IPakProgressHandler
{
public:
	virtual void progress(Action action, int value, const char* message) override
	{
		if (action == SetMax)
		{
			m_max = value;
			return;
		}
		if (value != m_max)
		{
			std::cout << "[" << value << "/" << m_max << "] " << (message != NULL ? message : "") << "..." << std::endl;
		}
	}
protected:
	int m_max;
};

int main(int argc, char* argv[])
{
	if (argc >= 4 && strcmp(argv[1], "-e") == 0)
	{															 
		std::cout << "Extracting..." << std::endl;
		std::set<ResType> types;
		for(int i = 4; i < argc; i++)
		{
			types.insert(argv[i]);
		}

		PakArchive pak;
		ProgressHandler handler;
		pak.setProgressHandler(&handler);
		if (!pak.open(argv[2]))
		{
			std::cout << "Unable to open file!" << std::endl;
			return -1;
		}
		if (pak.extract(argv[3], types, true))
		{
			std::cout << "Done!" << std::endl;
		}
		else
		{
			std::cout << "Error occured during extracting!" << std::endl;
			return -2;
		}
	}
	else
	{
		printUsage();
	}
	return 0;
}
