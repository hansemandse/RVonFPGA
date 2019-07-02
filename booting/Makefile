# ************************************************************************
#				|
# Title			: Implementation and Optimization of a RISC-V processor on
#				: a FPGA
#				|
# Developers	: Hans Jakob Damsgaard, Technical University of Denmark
#				: s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
#				| 
# Purpose		: This makefile serves the purpose of making the
#				: bootloader for the system along with a set of functions
#				: available to test programs.
#				|
# Revision	    : 1.0 (last updated June 28, 2019)
#				|
# Available at  : https://github.com/hansemandse/RVonFPGA
#				|	
# ************************************************************************

# Declarations of environment variables
march := -march=rv64i # compile for RV64I ISA
mabi := -mabi=lp64 # define long as 64 bits, int as 32 bits, short as 16
				   # bits and char as 8 bits
nostd := -nostdlib # do not link any standard libraries
nosu := -nostartfiles # do not add default start up code
link := -Wl,-Ttext=0x0,-Tdata=0xF00 # start the .text and .data segments
									# at these addresses
opt := -O3 # maximum optimization to minimize number of instructions
		   # resulting from compilation
CC := riscv64-unknown-elf-gcc
objcopy := riscv64-unknown-elf-objcopy
objdump := riscv64-unknown-elf-objdump
CFLAGS := $(march) $(mabi) $(nostd) $(nosu) $(link) $(opt)

SRC := RVonFPGA_boot_rom.s RVonFPGA_boot_funcs.c

# Definition of make boot and make all
.PHONY : all
all : boot
.PHONY: boot
boot :
	$(CC) $(CFLAGS) $(SRC) -o boot.o
	$(objcopy) --remove-section .comment boot.o
	$(objcopy) -O binary boot.o boot.bin
	python romgen.py
	$(objdump) -D -S -x boot.o > boot.s
	@echo $@ successfully created

# Definition of make clean
.PHONY : clean
clean : 
	@rm -rf *.o
	@rm -rf *.bin
	@echo Removed all created .o and .bin files

# Definition of a test command to print gcc version
.PHONY : test
test : 
	@echo CC = $(CC)
	@echo objcopy = $(objcopy)
	@echo march = $(march)
	@echo mabi = $(mabi)
	@echo flags = $(nostd) $(nosu) $(link) $(opt)