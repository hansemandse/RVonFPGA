# ************************************************************************
#              |
# Title        : Implementation and Optimization of a RISC-V Processor on
#              : a FPGA
#              |
# Developers   : Hans Jakob Damsgaard, Technical University of Denmark
#              : s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
#              |
# Purpose      : This file is a part of a full system implemented as part
#              : of a bachelor's thesis at DTU. The thesis is written in
#              : cooperation with the Institute of Mathematics and
#              : Computer Science.
#              : This piece of code represents a minimal bootloader used
#              : on the RISC-V processor. It initializes the system after
#              : a reset and provides basic IO and program loading-related
#              : functionality.
#              |
# Revision     : 1.0   (last updated July 2, 2019)
#              |
# Available at : https://github.com/hansemandse/RVonFPGA
#              |
# ************************************************************************

# File identifier, option disabling position-independent code generation,
# and indication of the start of the .text segment
    .file   "boot_rom.s"
    .option nopic
    .text
    # Marking the text section as being allocatable and executable
    .section    .text.startup,"ax",@progbits

# Constant definitions (addresses for UART, switches and LEDs and so on)
    .equ    MEM_START,          0x1000000000000000
    .equ    SP_START,           0x100000000000F000

# Basic start up code that initializes the stack pointer and the global
# pointer and jumps to the read_srec function - note that this function
# is named _start, as the RISC-V GCC default linker has this symbol as
# its entry point.
    .align  2 # align to 4-byte spaces
    .globl  _start
    .type   _start, @function
_start:
    mv a0, zero
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
    jal led_sw_test
    li a1, MEM_START
    or a0, a0, a1
final:
    jr a0
    .size   _start, .-_start
