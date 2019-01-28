# RVonFPGA
Bachelor's project. Preliminary abstract is:

This project focuses on the implementation of a single RISC-V pipeline implementing the so-called
RV64I base instruction set on a Xilinx Artix®-7 FPGA utilizing the available resources efficiently
such that the clock frequency may be increased as much as possible. The chip is available on various
test boards including the NEXYS 4 DDR board which also has a 128 MiB external DDR2 memory.
Instructions mainly used for operating systems related topics - such as the FENCE and some of the
ECALL instructions - will be left out leading to a total of around 50 instructions to be implemented.

The system should be built such that test programs may be downloaded from a computer to the
memory on the FPGA using a UART connection over USB, and similarly, such that the register
content after execution may be uploaded from the FPGA via the same connection. Test programs
may be written directly in RISC-V assembly or in C and compiled into binary instruction files using
RISC-V gcc. Execution results may be compared to results obtained from a software simulation of the
implemented base instruction set and extensions (a working RV32I ISA simulator has already been
written in course 02155 at DTU, and it may easily be extended to support RV64I).

Possible extensions of the above description include
1. Implementation of the 32- and 64-bit M extensions
2. Implementation of a (pipelined) 
oating-point unit (either SP or DP) and the corresponding
32-bit F and 64-bit D extensions
3. Unification of the instruction and data memories in external DDR2 - potentially followed by the
implementation of a (simple) cache
4. Changing the pipeline implementation to e.g. static dual issue
