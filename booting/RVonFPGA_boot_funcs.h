// Constants for addressing the memory mapped I/O modules
#define UART_DATA_ADDR      0x8000000000000001
#define UART_STB_OUT_ADDR   0x8000000000000010
#define UART_STB_IN_ADDR    0x8000000000000011
#define LED_LO_ADDR         0x8000000000000100
#define LED_HI_ADDR         0x8000000000000101
#define SW_LO_ADDR          0x8000000000000100
#define SW_HI_ADDR          0x8000000000000101

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
