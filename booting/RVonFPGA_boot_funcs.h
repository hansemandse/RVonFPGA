// The following functions are defined in boot_funcs.c
char uart_stb_in(void);

char uart_stb_out(void);

char read_uart(void);

void write_uart(char val);

void write_led_lo(char val);

void write_led_hi(char val);

char read_sw_lo(void);

char read_sw_hi(void);

int read_srec(void);
