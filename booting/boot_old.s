# Function to read a byte from the UART (by spinning on the std_in register)
#    .align  2
#    .globl  read_uart
#    .type   read_uart, @function
#read_uart:
#    addi sp, sp, -8
#    sd ra, 0(sp)
#.L1:
#    jal ra, read_uart_std_in
#    beqz a0, .L1
#    ld ra, 0(sp)
#    addi sp, sp, 8
#    li t0, UART_DATA_ADDR
#    lb a0, 0(t0)
#    ret
#    .size   read_uart, .-read_uart

# Function to read the std_out register
#    .align  2
#    .globl  read_uart_std_out
#    .type   read_uart_std_out, @function
#read_uart_std_out:
#    li t0, UART_STD_OUT_ADDR
#    lb a0, 0(t0)
#    ret
#    .size   read_uart_std_out, .-read_uart_std_out

# Function to read the std_in register
#    .align  2
#    .globl  read_uart_std_in
#    .type   read_uart_std_in, @function
#read_uart_std_in:
#    li t0, UART_STD_IN_ADDR
#    lb a0, 0(t0)
#    ret
#    .size   read_uart_std_in, .-read_uart_std_in

# Function to write a byte to the UART (overwriting the current value)
#    .align  2
#    .globl  write_uart
#    .type   write_uart, @function
#write_uart:
#    li t0, UART_DATA_ADDR
#    sb a0, 0(t0)
#    ret
#    .size   write_uart, .-write_uart

# Function to write a byte to the low half of the LEDs
#    .align  2
#    .globl  write_led_lo
#    .type   write_led_lo, @function
#write_led_lo:
#    li t0, LED_LO_ADDR
#    sb a0, 0(t0)
#    ret
#    .size   write_led_lo, .-write_led_lo

# Function to write a byte to the high half of the LEDs
#    .align  2
#    .globl  write_led_hi
#    .type   write_led_hi, @function
#write_led_hi:
#    li t0, LED_HI_ADDR
#    sb a0, 0(t0)
#    ret
#    .size   write_led_hi, .-write_led_hi

# Function to read a byte from the low half of the switches
#    .align  2
#    .globl  read_sw_lo
#    .type   read_sw_lo, @function
#read_sw_lo:
#    li t0, SW_LO_ADDR
#    lbu a0, 0(t0)
#    ret
#    .size   read_sw_lo, .-read_sw_lo

# Function to read a byte from the high half of the switches
#    .align  2
#    .globl  read_sw_hi
#    .type   read_sw_hi, @function
#read_sw_hi:
#    li t0, SW_HI_ADDR
#    lbu a0, 0(t0)
#    ret
#    .size   read_sw_hi, .-read_sw_hi
