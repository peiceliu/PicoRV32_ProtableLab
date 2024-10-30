#include "uart.h"


#define SYSTEM_CNT_M			125										//系统时钟单位：MHz
#define system_clk				50
#define SYSTEM_CLOCK			SYSTEM_CNT_M*1000000UL
#define system_CLOCK 			system_clk*1000000UL
#define BAUND_9600				((system_CLOCK)/9600)
#define BAUND_115200			(SYSTEM_CLOCK/115200)



int main(void)
{
	reg_uart_clkdiv = BAUND_9600;

    printk("Hello Risc-V Pango 2024\n");
    while(1)
    {
    	uart_handler();
        printk("once handler\n");
    }

	return 0;
}






