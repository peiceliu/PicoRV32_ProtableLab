#ifndef _UART_H_
#define _UART_H_

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stddef.h>
#include <stdarg.h>

//define the UART register
#define reg_uart_clkdiv (*(volatile uint32_t*)0x00008000)
#define reg_uart_txdata (*(volatile uint32_t*)0x00008010)
#define reg_uart_rxdata (*(volatile uint32_t*)0x00008020)
#define parameter_id (*(volatile uint32_t*)0x00008030)
#define parameter_value (*(volatile uint32_t*)0x00008040)

void put_char(char c);
void print_num(uint32_t num, int base);
void print_str(const char *p);
void print_hex(uint32_t v, int digits);
void print_hex2(uint32_t hex);
void print_dec(uint32_t v);
void print_flt(double flt);
void printk(char *fmt, ...);


char read_uart(void);
void uart_handler(void);
void serial_receive_data(char data);
char getchar_prompt(char *prompt);
char get_char();
#endif
