# ********************************************************************************************
#				|
# Title			: Implementation and Optimization of a RISC-V processor on a FPGA
#				|
# Developers	: Hans Jakob Damsgaard, Technical University of Denmark
#				: s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
#				| 
# Purpose		: This makefile serves the purpose of making compilation of small
#				: test programs for the implemented RV64I pipeline easy.
#				|
# Revision	    : 1.0 (last updated May 1, 2019)
#				|
# Available at  : https://github.com/hansemandse/RVonFPGA
#				|	
# ********************************************************************************************

# Declarations of environment variables
march := -march=rv64i # compile for RV64I ISA
mabi := -mabi=lp64 # define long as 64 bits, int as 32 bits, short as 16 bits and char as 8 bits
CC := riscv64-unknown-elf-gcc
CFLAGS := $(march) $(mabi) -c # files are compiled but not linked (output files should be OK)
objcopy := riscv64-unknown-elf-objcopy
srec := --output-target srec

SRC := $(wildcard *.c)
OBJS := $(SRC:.c=.o)

# Definition of make all
.PHONY: all
all : comp

# Make all programs and generate .o, .s and srec files
comp : $(OBJS)
%.o : %.c
	$(CC) $(CFLAGS) $< -o $@
	$(CC) $(CFLAGS) -S $< $@ -o $(basename $<).s
	$(objcopy) $@ $(srec) $(basename $<).srec
	@echo $@ successfully created

# Definition of make clean
.PHONY : clean
clean : 
	@rm -rf *.o
	@rm -rf *.s
	@rm -rf *.srec
	@echo Removed all created .s, .o and srec files

# Definition of a test command to print gcc version
.PHONY : test
test : 
	@echo CC = $(CC)
	@echo objcopy = $(objcopy)
	@echo march = $(march)
	@echo mabi = $(mabi)