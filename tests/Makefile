# ************************************************************************
#				|
# Title			: Implementation and Optimization of a RISC-V processor on
#				: a FPGA
#				|
# Developers	: Hans Jakob Damsgaard, Technical University of Denmark
#				: s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
#				| 
# Purpose		: This makefile serves the purpose of making compilation
#				: of small test programs for the implemented RV64I
#				: pipeline easy.
#				|
# Revision	    : 1.2 (last updated May 8, 2019)
#				|
# Available at  : https://github.com/hansemandse/RVonFPGA
#				|	
# ************************************************************************

# Declarations of environment variables
march := -march=rv64i # compile for RV64I ISA
mabi := -mabi=lp64 # define long as 64 bits, int as 32 bits, short as 16 bits and char as 8 bits
CC := riscv64-unknown-elf-gcc
CFLAGS := $(march) $(mabi) -c
objcopy := riscv64-unknown-elf-objcopy
srec_ot := --output-target srec

SRC := $(wildcard elf_tests/*.c)
OBJS := $(SRC:.c=.o)
SRECOBJS := $(OBJS:.o=.srec)

SSRC := $(wildcard s_tests/*.s) $(wildcard s_tests_no_f/*.s)
SOBJS := $(SSRC:.s=.o)
SBINS := $(SOBJS:.o=.bin)

# Definition of make all
.PHONY : all
all : scomp sbinary comp srec

# Definition of all assembly programs to make
comp : $(OBJS)
%.o : %.c
	$(CC) $(CFLAGS) -fpic -O3 $< -o $@
	$(CC) $(CFLAGS) -D -S $< $@ -o $(basename $<).s
	@echo $@ successfully created

srec : $(SRECOBJS)
%.srec : %.o
	$(objcopy) $< $(srec_ot) $@
	@echo $@ successfully created

scomp : $(SOBJS)
%.o : %.s
	$(CC) $(CFLAGS) -c $< -o $@
	@echo $@ successfully created

sbinary : $(SBINS)
%.bin : %.o
	$(objcopy) $< --dump-section .text=$@
	@echo $@ successfully created

# Definition of make clean
.PHONY : clean
clean : 
	@rm -rf elf_tests/*.o
	@rm -rf elf_tests/*.s
	@rm -rf elf_tests/*.bin
	@rm -rf elf_tests/*.srec
	@rm -rf s_tests_no_f/*.o
	@rm -rf s_tests_no_f/*.bin
	@rm -rf s_tests/*.o
	@rm -rf s_tests/*.bin
	@echo Removed all created .s, .o, .bin and .srec files

# Definition of a test command to print gcc version
.PHONY : test
test : 
	@echo CC = $(CC)
	@echo objcopy = $(objcopy)
	@echo march = $(march)
	@echo mabi = $(mabi)