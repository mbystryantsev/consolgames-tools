#pragma once

#if defined(_DEBUG) && !defined(CG_DEBUG)
# define CG_DEBUG
#endif

#ifdef CG_DEBUG
# ifndef CG_LOG_ENABLED
#  define CG_LOG_ENABLED
# endif
#endif

#ifdef CG_LOG_ENABLED
# include <iostream>
# include <iomanip>
# include <string>
#endif

#ifdef QT_CORE_LIB
# include <QString>
# include <QByteArray>
#endif

#ifdef _MSC_VER
# define _CRT_SECURE_NO_WARNINGS 1
# define _CRT_SECURE_NO_DEPRECATE 1
# include <windows.h>
#endif

typedef unsigned char uint8;
typedef unsigned short uint16;
typedef unsigned int uint32;
typedef unsigned __int64 uint64;

namespace Consolgames
{

#if defined(_WIN32) || defined(__WIN32)
# define PATH_SEPARATOR '\\'
# define PATH_SEPARATOR_STR "\\"
# define PATH_SEPARATOR_L L'\\'
# define PATH_SEPARATOR_STR_L L"\\"
#else
# define PATH_SEPARATOR '/'
# define PATH_SEPARATOR_STR "/"
# define PATH_SEPARATOR_L L'/'
# define PATH_SEPARATOR_STR_L L"/"
#endif

inline uint16 endian16(uint16 v)
{
	return (v >> 8) | (v << 8);
}

inline uint32 endian32(uint32 v)
{
	return (v >> 24) | (v << 24) | ((v >> 8) & 0xFF00) | ((v << 8) & 0xFF0000);
}

inline uint64 endian64(uint64 v)
{
	return (v >> 56)
		| (v << 56)
		| ((v >> 40) & (0xFFULL << 8))
		| ((v << 40) & (0xFFULL << 48))
		| ((v >> 24) & (0xFFULL << 16))
		| ((v << 24) & (0xFFULL << 40))
		| ((v >> 8) & (0xFFULL << 24))
		| ((v << 8) & (0xFFULL << 32));
}

#ifdef CG_DEBUG
class AssertException
{
public:
	AssertException(const char* file, int line, const char* function, const char* expression)
		: m_file(file)
		, m_line(line)
		, m_function(function)
		, m_expression(expression)
	{
		std::cerr << "ASSERT\n";
		std::cerr << "File:       " << m_file << std::endl;
		std::cerr << "Line:       " << m_line << std::endl;
		std::cerr << "Function:   " << m_function << std::endl;
		std::cerr << "Expression: " << expression << std::endl;
	}

private:
	const char* m_file;
	int m_line;
	const char* m_function;
	const char* m_expression;
};

class AssertHandler
{
public:
	AssertHandler(const char* file, int line, const char* function, const char* expression)
	{
#ifdef CG_LOG_ENABLED
		std::cout << "ASSERT triggered at " << file << "@" << line << " (" << function << "): " << expression << std::endl;
#endif
# ifdef _MSC_VER
// 		try
// 		{
// 			DebugBreak();
// 		}
// 		catch(...)
		{
			throw new AssertException(file, line, function, expression);
		}
# endif
	}
};
#endif

}

#ifdef ASSERT
# undef ASSERT
#endif
#ifdef CG_DEBUG
# define ASSERT(expression) if (!(expression)) Consolgames::AssertHandler(__FILE__, __LINE__, __FUNCTION__, #expression)
#else
# define ASSERT(expression) ((void)0)
#endif

#ifdef VERIFY
# undef VERIFY
#endif

#ifdef CG_DEBUG
# define VERIFY(expression) if (!(expression)) Consolgames::AssertHandler(__FILE__, __LINE__, __FUNCTION__, #expression)
#else
# define VERIFY(expression) (expression)
#endif

class DLog
{
public:
	struct LogModifiers
	{
		enum Type
		{
			modNone,
			modHex
		};
		LogModifiers(Type t) : type(t){}
		Type type;
	};

#ifdef CG_LOG_ENABLED
	DLog()
		: modifier(LogModifiers::modNone)
	{
	}
	~DLog(){std::cout << std::endl;}
	DLog& operator ()(const char* s, ...){std::cout << s; return *this;}
	DLog& operator <<(const char* s){std::cout << s; return *this;}
	DLog& operator <<(const std::string& s){std::cout << s; return *this;}
	DLog& operator <<(const std::wstring& s){std::cout << s.c_str(); return *this;}
	DLog& operator <<(__int64 v){std::cout << (modifier == LogModifiers::modHex ? std::hex : std::dec); std::cout << v; return *this;}
	DLog& operator <<(const LogModifiers& m){setModifier(m); return *this;}
# ifdef QT_CORE_LIB
	DLog& operator <<(const QString& s){std::cout << s.toStdString(); return *this;}
	DLog& operator <<(const QByteArray& s){std::cout << s.data(); return *this;}
# endif
	void setModifier(const LogModifiers& m)
	{
		modifier = m.type;
	}
protected:
	LogModifiers::Type modifier;

public:
#else
	const DLog& operator ()(const char*) const {return *this;}
	template<typename T>
	const DLog& operator <<(const T&) const {return *this;}
#endif
};

const DLog::LogModifiers HEX(DLog::LogModifiers::modHex);

#define DLOG \
	__if_not_exists(__s_consolgames_log_category){ DLog()} \
	__if_exists(__s_consolgames_log_category){ (DLog() << __s_consolgames_log_category << ": ") }
#define LOG_CATEGORY(category) static const char* __s_consolgames_log_category = category;

#ifndef _MSC_VER
# define override
#endif

typedef __int64 offset_t;
typedef __int64 largesize_t;
