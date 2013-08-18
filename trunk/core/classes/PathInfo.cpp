#include "PathInfo.h"
#include <core.h>

namespace Consolgames
{
	
PathInfo::PathInfo(const std::string& path)
	: m_path(path)
{
	int pos = 0;
	int nextPos = m_path.size();
	if (!m_path.empty() && m_path[0] == '/')
	{
		pos++;
	}

	while (pos < static_cast<int>(m_path.size()))
	{
		nextPos = m_path.find('/', pos);
		if (nextPos == std::string::npos)
		{
			m_parts.push_back(m_path.substr(pos));			
			break;
		}
		m_parts.push_back(m_path.substr(pos, nextPos - pos));
		pos = nextPos + 1;
		while (pos < static_cast<int>(m_filename.size()) && m_filename[pos] == '/')
		{
			pos++;
		}
	}

	if (m_parts.size() > 0)
	{
		m_basename = m_parts.back();
	}

	int extPos = m_basename.rfind('.');
	if (extPos != std::string::npos)
	{
		m_extension = m_basename.substr(extPos + 1);
	}
	
	m_filename = m_extension.empty() ? m_basename : m_basename.substr(0, m_basename.size() - m_extension.size() - 1);

	m_dirname = m_parts.size() > 1 ? m_path.substr(0, m_path.size() - m_basename.size() - 1) : std::string();
}

std::string PathInfo::filename() const
{
	return m_filename;
}

std::string PathInfo::part(int index) const
{
	return m_parts[index];
}

std::string PathInfo::basename() const
{
	return m_basename;
}

std::string PathInfo::dirname() const
{
	return m_dirname;
}

std::string PathInfo::extension() const
{
	return m_extension;
}

bool PathInfo::isAbsolute() const
{
	return (m_filename.size() > 0 && m_filename[0] == '/');
}

bool PathInfo::isRelative() const
{
	return !isAbsolute();
}

int PathInfo::partCount() const
{
	return m_parts.size();
}

std::string PathInfo::path() const
{
	return m_path;
}

}
