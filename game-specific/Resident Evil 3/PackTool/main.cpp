#include <Archive.h>
#include <Compressor.h>
#include <FileStream.h>
#include <iostream>

using namespace Consolgames;
using namespace ResidentEvil;

int main(int argc, char **argv)
{
	{
		FileStream inStream("D:\\rev\\re3\\test\\000.unp", Stream::modeRead);	
		FileStream outStream("D:\\rev\\re3\\test\\000.unp.pak", Stream::modeWrite);	

		Compressor::encode(&inStream, &outStream);
	}

	{
		FileStream inStream("D:\\rev\\re3\\test\\000.unp.pak", Stream::modeRead);	
		FileStream outStream("D:\\rev\\re3\\test\\000.unp2", Stream::modeWrite);	

		Compressor::decode(&inStream, &outStream);
	}

	return 0;

	FileStream inStream("D:\\rev\\re3\\3_ITEMA.SLD", Stream::modeRead);	
	FileStream slusStream("D:\\rev\\re3\\SLUS_009.23", Stream::modeRead);	
	Archive arc(&inStream, &slusStream);

	int index = 0;
	while (arc.next())
	{
		char indexStr[16];
		itoa(index++, indexStr, 10);

		std::string path("D:\\rev\\re3\\test\\img");
		path.append(indexStr);
		path.append(".tim");

		FileStream outStream(path, Stream::modeWrite);	
		VERIFY(arc.extract(&outStream));
	}

	return 0;
}
