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
	virtual void init(int count) override
	{
		m_count = count;
	}
	virtual void progress(int value, const char* message) override
	{
		std::cout << "[" << (value + 1) << "/" << m_count << "] " << (message != NULL ? message : "") << "..." << std::endl;
	}
	virtual void finish() override
	{
	}
protected:
	int m_count;
};

std::wstring strToWStr(const std::string& str)
{
	std::wstring wstr(str.begin(), str.end());
	return wstr;
}

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
		const std::wstring filename = strToWStr(argv[2]);
		if (!pak.open(filename))
		{
			std::cout << "Unable to open file: " << argv[2] << "!" << std::endl;
			return -1;
		}
		if (pak.extract(strToWStr(argv[3]), types, false))
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
