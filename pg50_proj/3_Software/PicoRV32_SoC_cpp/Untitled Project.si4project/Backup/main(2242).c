#include "uart.h"

#define led_address 	(*(volatile uint32_t*)0x000007f0)
#define key_address 	(*(volatile uint32_t*)0x000007f4)
#define key_point   	(volatile uint32_t*)0x000007f4

#define KEY_DATA				0xaa55


uint32_t temp_cnt = 0;
int temp_data = 0;
void set_led(int status);
void delay_us(int cnt_data);
void delay_ms(int cnt_data);


int main(void)
{
	reg_uart_clkdiv = 868;									//115200根据当前的系统时钟计算得出
	temp_data = *key_point;
	set_led(0);

	print("pango111\n");

	if(KEY_DATA == temp_data)
	{
		print("success\n");
	}
	else
	{
		print("failed\n");
	}

	while(1)
	{
		delay_ms(2000);
		led_address = ~led_address;
	}
	
	return 0;
}


void set_led(int status)
{
	if(0 == status)
	{
		led_address = 0;
	}
	else if(0 == status)
	{
		led_address = 1;
	}

}

void delay_us(int cnt_data)
{
	int cnt = 100;
	if(0 == cnt_data)
	{
		while(cnt--)
		{
		}
		cnt_data--;
	}
}

void delay_ms(int cnt_data)
{
	while(cnt_data--)
	{
		delay_us(1000);
	}

}



