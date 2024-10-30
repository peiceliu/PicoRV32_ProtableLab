#include <stdint.h>
#include <stdbool.h>



// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.

#define reg_uart_clkdiv (*(volatile uint32_t*)0x000007d0)
#define reg_uart_data   (*(volatile uint32_t*)0x000007e0)

void putchar(char c);
void print(const char *p);
void print_hex(uint32_t v, int digits);
void print_dec(uint32_t v);
char getchar_prompt(char *prompt);
char getchar();

