# Declarations of functions to use
CC := riscv64-unknown-elf-gcc
objcopy := riscv64-unknown-elf-objcopy
march := -march=rv64i # compile for RV64I ISA
mabi := -mabi=lp64

# Definition of make all
.PHONY : all
all : add

# Definition of all programs to make
add : add.o
	$(objcopy) add.o --dump-section .text=add.bin 
add.o : add.c
	$(CC) $(march) $(mabi) add.c -o- -O3

# Definition of make clean
.PHONY : clean
clean : 
	rm -rf *.o
	rm -rf *.bin	

# Definition of a test command to print gcc version
.PHONY : test
test : 
	@echo CC = $(CC)