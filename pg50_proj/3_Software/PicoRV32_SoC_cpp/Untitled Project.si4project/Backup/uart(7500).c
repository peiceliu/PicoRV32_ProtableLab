
#include <stdint.h>
#include <stdbool.h>
#include "uart.h"

/********************************************************************
 ** 函数名称：put_char
 ** 函数功能：打印单个字符
 ** 输入参数：c:需要打印的字符信息
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void put_char(char c)
{
	if (c == '\n')
		put_char('\r');
	reg_uart_data = c;
}

/********************************************************************
 ** 函数名称：printstr
 ** 函数功能：打印字符串
 ** 输入参数：*p:需要打印的字符串信息
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void printstr(const char *p)
{
	while (*p)
		put_char(*(p++));
}

/********************************************************************
 ** 函数名称：print_hex
 ** 函数功能：十进制转换为16进制
 ** 输入参数：v:需要转换的十进制数据
 ** 		digits：
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void print_hex(uint32_t v, int digits)
{
	for (int i = 7; i >= 0; i--)
	{
		char c = "0123456789abcdef"[(v >> (4*i)) & 15];
		if (c == '0' && i >= digits)
			continue;
		putchar(c);
		digits = i;
	}
}

/********************************************************************
 ** 函数名称：my_printf
 ** 函数功能：自定义printf打印函数
 ** 输入参数：fmt：打印的字符串内容
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
void my_printf(char *fmt, ...)
{
	double vargflt = 0;
	int vargint = 0;
	char *vargstr = NULL;
	char vargch = 0;
	char *pfmt = NULL;
	va_list vp;

	va_start(vp, fmt);
	pfmt = fmt;

	while(*pfmt)
	{
		if(*pfmt = '%')
		{
			switch(*(++pfmt))
			{
				case 'c':
				case 'C':
					vargch = va_arg(vp, int);
					put_char(vargch);
					break;

				case 'd':
				case 'D':
				case 'i':

			}

		}
		else
		{
			printstr(*pfmt++);
		}

	}
	va_end(vp);

}

/********************************************************************
 ** 函数名称：getchar_prompt
 ** 函数功能：
 ** 输入参数：
 ** 输出参数：无
 ** 返回参数：无
 ********************************************************************/
char getchar_prompt(char *prompt)
{
	int32_t c = -1;

	uint32_t cycles_begin, cycles_now, cycles;
	__asm__ volatile ("rdcycle %0" : "=r"(cycles_begin));

	if (prompt)
		printstr(prompt);

	while (c == -1)
	{
		__asm__ volatile ("rdcycle %0" : "=r"(cycles_now));
		cycles = cycles_now - cycles_begin;
		if (cycles > 12000000)
		{
			if (prompt)
			{
				printstr(prompt);
			}
			cycles_begin = cycles_now;
		}
		c = reg_uart_data;
	}

	return c;
}

char get_char()
{
	return getchar_prompt(0);
}
