#ifndef __COMMON_H
#define __COMMON_H

#ifdef _DEBUG
#include <iostream>
#include <iomanip>
#endif

#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS 1
#define _CRT_SECURE_NO_DEPRECATE 1
#include <windows.h>
#endif

typedef unsigned int u32;
typedef unsigned short u16;
typedef unsigned __int64 u64;
typedef unsigned char u8;
typedef char s8;
typedef short s16;
typedef int s32;
typedef __int64 s64;

namespace Consolgames
{

#if defined(_WIN32) || defined(__WIN32)
#define PATH_SEPARATOR '\\'
#define PATH_SEPARATOR_STR "\\"
#else
#define PATH_SEPARATOR '/'
#define PATH_SEPARATOR_STR "/"
#endif

inline u16 endian16(u16 v)
{
	return (v >> 8) | (v << 8);
}

inline u32 endian32(u32 v)
{
	return (v >> 24) | (v << 24) | ((v >> 8) & 0xFF00) | ((v << 8) & 0xFF0000);
}

inline u64 endian64(u64 v)
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
		std::cerr << "File:       " << m_file;
		std::cerr << "Line:       " << m_line;
		std::cerr << "Function:   " << m_function;
		std::cerr << "Expression: " << expression;
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
#ifdef _MSC_VER
		try
		{
			DebugBreak();
		}
		catch(...)
		{
			throw new AssertException(file, line, function, expression);
		}
#endif
	}
};

}

#ifdef ASSERT
#undef ASSERT
#endif
#ifdef _DEBUG
#define ASSERT(expression) if (!(expression)) Consolgames::AssertHandler(__FILE__, __LINE__, __FUNCTION__, #expression)
#else
#define ASSERT(expression) ((void)0)
#endif

#ifdef VERIFY
#undef VERIFY
#endif
#ifdef _DEBUG
#define VERIFY(expression) if (!(expression)) Consolgames::AssertHandler(__FILE__, __LINE__, __FUNCTION__, #expression)
#else
#define VERIFY(expression) (expression)
#endif
class DLog
{
public:
	struct LogModifiers
	{
		enum Type
		{
			modHex
		};
		LogModifiers(Type t) : type(t){}
		Type type;
	};
#ifdef _DEBUG
	~DLog(){std::cout << std::endl;}
	DLog& operator ()(const char* s, ...){std::cout << s; return *this;}
	DLog& operator <<(const char* s){std::cout << s; return *this;}
	DLog& operator <<(__int64 v){if(modifier == LogModifiers::modHex) std::cout << std::hex; std::cout << v; return *this;}
	DLog& operator <<(const LogModifiers& m){setModifier(m); return *this;}
	void setModifier(const LogModifiers& m)
	{
		modifier = m.type;
	}
protected:
	LogModifiers::Type modifier;

public:
#else
	DLog& operator ()(const char* s){return *this;}
	DLog& operator <<(const char* s){return *this;}
	DLog& operator <<(__int64 v){return *this;}
	DLog& operator <<(const LogModifiers& m){return *this;}
#endif
};

const DLog::LogModifiers HEX(DLog::LogModifiers::modHex);

#define DLOG DLog()

#ifndef _MSC_VER
#define override
#endif

typedef __int64 offset_t;
typedef __int64 largesize_t;

#endif // __COMMON_H
