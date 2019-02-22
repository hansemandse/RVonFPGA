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
# Revision	    : 1.0 (last updated February 22, 2019)
#				|
# Available at  : https://github.com/hansemandse/RVonFPGA
#				|	
# ********************************************************************************************

# Declarations of environment variables
CC := riscv64-unknown-elf-gcc
CF := -c # files are compiled but not linked (causes a warning, but output files should be OK)
objcopy := riscv64-unknown-elf-objcopy
march := -march=rv64i # compile for RV64I ISA
mabi := -mabi=lp64 # define long as 64 bits, int as 32 bits, short as 16 bits and char as 8 bits
bin := .bin

# Definition of make all
.PHONY : all
all : add sub

# Definition of all programs to make
add : add.o
	$(objcopy) $< --dump-section .text=$@$(bin)
	@echo $@$(bin) successfully created
add.o : add.c
	$(CC) $(march) $(mabi) $(CF) $< -o $@
	$(CC) $(march) $(mabi) -S $< $@
	@echo $@ successfully created
sub : sub.o
	$(objcopy) $< --dump-section .text=$@$(bin)
	@echo $@$(bin) successfully created
sub.o : sub.c
	$(CC) $(march) $(mabi) $(CF) $< -o $@
	$(CC) $(march) $(mabi) -S $< $@
	@echo $@ successfully created

# Definition of make clean
.PHONY : clean
clean : 
	rm -rf *.s
	rm -rf *.o
	rm -rf *.bin	

# Definition of a test command to print gcc version
.PHONY : test
test : 
	@echo CC = $(CC)
	@echo objcopy = $(objcopy)
	@echo march = $(march)
	@echo mabi = $(mabi)