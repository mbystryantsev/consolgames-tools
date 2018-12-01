#pragma once
#include <cinttypes>

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
#endif

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

inline uint16_t endian16(uint16_t v)
{
	return (v >> 8) | (v << 8);
}

inline uint32_t endian32(uint32_t v)
{
	return (v >> 24) | (v << 24) | ((v >> 8) & 0xFF00) | ((v << 8) & 0xFF0000);
}

inline uint64_t endian64(uint64_t v)
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

#ifndef UNUSED
# define UNUSED(x) ((void)x)
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
	DLog& operator <<(int64_t v){std::cout << (modifier == LogModifiers::modHex ? std::hex : std::dec); std::cout << v; return *this;}
	DLog& operator <<(uint64_t v){std::cout << (modifier == LogModifiers::modHex ? std::hex : std::dec); std::cout << v; return *this;}
	DLog& operator <<(int v) { return (*this << (int64_t)v); }
	DLog& operator <<(unsigned int v) { return (*this << (uint64_t)v); }
#if defined(_MSC_VER)
	DLog& operator <<(long v) { return (*this << (int64_t)v); }
	DLog& operator <<(unsigned long v) { return (*this << (uint64_t)v); }
#endif
	DLog& operator <<(short v) { return (*this << (int64_t)v); }
	DLog& operator <<(unsigned short v) { return (*this << (uint64_t)v); }
	DLog& operator <<(char c){std::cout << c; return *this;}
	DLog& operator <<(unsigned char c){std::cout << c; return *this;}
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

#if defined(_MSC_VER)
#define DLOG \
	__if_not_exists(__s_consolgames_log_category){ DLog()} \
	__if_exists(__s_consolgames_log_category){ (DLog() << __s_consolgames_log_category << ": ") }
#else
#define DLOG DLog()
#endif
#define LOG_CATEGORY(category) static const char* __s_consolgames_log_category = category;

#if __cplusplus < 201103L && !defined(_MSC_VER)
# define override
#endif

typedef int64_t offset_t;
typedef int64_t largesize_t;

#if __cplusplus >= 201103L || (defined(_MSC_VER) && _MSC_VER >= 1800)
# define CPP_SUPPORTS_MOVE_SEMANTICS
#endif
