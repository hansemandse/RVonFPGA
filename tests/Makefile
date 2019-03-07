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
# Revision	    : 1.0 (last updated March 7, 2019)
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
bin := .bin

SRC := $(wildcard c_tests/*.c) 
OBJS := $(SRC:.c=.o)
BINS := $(OBJS:.o=.bin)

SSRC := $(wildcard s_tests/*.s)
SOBJS := $(SSRC:.s=.o)
SBINS := $(SOBJS:.o=.bin)

# Definition of make all
.PHONY : all
all : comp binary scomp sbinary

# Definition of all C programs to make
comp : $(OBJS)
%.o : %.c
	$(CC) $(CFLAGS) $< -o $@
	$(CC) $(CFLAGS) -S $< $@ -o $(basename $<).s
	@echo $@ successfully created

binary : $(BINS)
%.bin : %.o
	$(objcopy) $< --dump-section .text=$@
	@echo $@ successfully created

# Definition of all assembly programs to make
scomp : $(SOBJS)
%.o : %.s
	$(CC) $(CFLAGS) $< -o $@
	@echo $@ successfully created

sbinary : $(SBINS)
%.bin : %.o
	$(objcopy) $< --dump-section .text=$@
	@echo $@ successfully created

# Definition of make clean
.PHONY : clean
clean : 
	@rm -rf c_tests/*.s
	@rm -rf c_tests/*.o
	@rm -rf c_tests/*.bin
	@rm -rf s_tests/*.o
	@rm -rf s_tests/*.bin
	@echo Removed all created .s, .o and .bin files

# Definition of a test command to print gcc version
.PHONY : test
test : 
	@echo CC = $(CC)
	@echo objcopy = $(objcopy)
	@echo march = $(march)
	@echo mabi = $(mabi)