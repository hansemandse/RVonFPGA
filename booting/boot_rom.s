# *******************************************************************************************
#              |
# Title        : Implementation and Optimization of a RISC-V Processor on a FPGA
#              |
# Developers   : Hans Jakob Damsgaard, Technical University of Denmark
#              : s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
#              |
# Purpose      : This file is a part of a full system implemented as part of a bachelor's
#              : thesis at DTU. The thesis is written in cooperation with the Institute
#              : of Mathematics and Computer Science.
#              : This piece of code represents a minimal bootloader used on the RISC-V
#              : processor. It initializes the system after a reset and provides basic
#              : IO and program loading-related functionality.
#              |
# Revision     : 1.0   (last updated May 31, 2019)
#              |
# Available at : https://github.com/hansemandse/RVonFPGA
#              |
# *******************************************************************************************

# File identifier, option disabling position-independent code generation, and indication of
# the start of the .text segment
    .file   "boot_rom.s"
    .option nopic
    .text

# Constant definitions (addresses for UART, switches and LEDs and so on)
    .equ    TEXT_START,         0x1000
    .equ    SP_START,           0xF000
#    .equ    UART_DATA_ADDR,     0xFFFA
#    .equ    UART_STD_OUT_ADDR,  0xFFFB
#    .equ    UART_STD_IN_ADDR,   0xFFFC
#    .equ    LED_LO_ADDR,        0xFFFF
#    .equ    LED_HI_ADDR,        0xFFFE
#    .equ    SW_LO_ADDR,         0xFFFF
#    .equ    SW_HI_ADDR,         0xFFFE

# Basic start up code that clears the memory, initializes the stack pointer and the global
# pointer and jumps to the read_srec function - note that this function is named _start, 
# as the RISC-V GCC default linker has this symbol as its entry point.
    .align  2 # align to 4-byte spaces
    .globl  _start
    .type   _start, @function
_start:
    li a0, TEXT_START
    li a1, SP_START
clear1: 
    sd x0, 0(a0)
    bge a0, a1, clear2
    addi a0, a0, 8
    j clear1
clear2: 
    mv a0, x0
    jal write_led_hi
    jal write_led_lo
init: 
    # initialize stack pointer
    li sp, SP_START
    # load global pointer from global symbol table
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    jal read_srec
    beqz a0, final
    # ADD ERROR HANDLING
final:
    j start_exec
    .size   _start, .-_start

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
