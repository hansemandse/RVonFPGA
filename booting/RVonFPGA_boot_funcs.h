// The following functions are defined in boot_funcs.c
char read_uart(void);
char uart_data_ready(void);
char uart_write_ready(void);
void write_uart(char val);
//void (*write_led_lo_f)(char) = 0x9C;
void write_led_lo(char val);
//void (*write_led_hi_f)(char) = 0xAC;
void write_led_hi(char val);
char read_sw_lo(void);
char read_sw_hi(void);
int read_srec(void);
