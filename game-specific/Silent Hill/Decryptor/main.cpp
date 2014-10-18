#include "crypto.h"
#include <fstream>
#include <iostream>

static unsigned int stream_size(std::ifstream& stream)
{
	const std::streampos pos = stream.tellg();
	stream.seekg(0, std::ios::end);
	const unsigned int size = stream.tellg();
	stream.seekg(pos, std::ios::beg);
	return size;
}

static bool do_crypto(const char* filename, const char* outfile)
{
	const int chunkSize = 0x400;
	std::ifstream stream(filename, std::ios_base::in | std::ios_base::binary);
	if (!stream.is_open())
	{
		std::cout << "Unable to open input file!" << std::endl;
		return false;
	}

	std::ofstream outStream(outfile, std::ios_base::out | std::ios_base::binary);
	if (!outStream.is_open())
	{
		std::cout << "Unable to open output file!" << std::endl;
		return false;
	}
	
	unsigned char buffer[chunkSize] = {};
	
	unsigned int size = stream_size(stream);
	
	unsigned int state = 0;
	while (size > 0)
	{
		const int chunk = std::min<int>(size, chunkSize);
		stream.read(reinterpret_cast<char*>(buffer), chunk);
		size -= chunk;
		state = crypto(buffer, chunk, state);
		outStream.write(reinterpret_cast<char*>(buffer), chunk);
	}

	return true;
}

static void print_usage()
{
	std::cout <<
		"Silent Hill encryption/decryption util by horror_x @ consolgames.ru\n"
		"Usage:\n"
		"crypto <InputFile> <OutputFile>\n";
}

int main(int argc, char* argv[])
{
	if (argc != 3)
	{
		print_usage();
		return -2;
	}
	
	const char* in = argv[1];
	const char* out = argv[2];
	return do_crypto(in, out) ? 0 : -1;
}
