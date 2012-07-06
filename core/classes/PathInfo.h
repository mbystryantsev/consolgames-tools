#ifndef __FILENAME_H
#define __FILENAME_H

#include <string>
#include <vector>

namespace Consolgames
{

class PathInfo
{
public:
	PathInfo(const std::string& name);

	std::string path() const;
	std::string extension() const;
	std::string dirname() const;
	std::string basename() const;
	std::string filename() const;
	bool isAbsolute() const;
	bool isRelative() const;
private:
	std::string m_path;
	std::string m_filename;
	std::string m_basename;
	std::string m_dirname;
	std::string m_extension;
	std::vector<std::string> m_parts;
	int m_partCount;
};

}

#endif /* __FILENAME_H */
