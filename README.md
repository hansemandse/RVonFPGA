# RVonFPGA
This project focuses on the implementation of a single RISC-V pipeline implementing the so-called
RV64I base instruction set on a Xilinx Artix®-7 FPGA utilizing the available resources efficiently
such that the clock frequency may be increased as much as possible. The chip is available on various
test boards including the NEXYS 4 DDR and the BASYS 3 boards in two different versions - both
with maximum clock frequencies well above 100 MHz and both implementing 6-input LUTs and plenty
of memory resources. Control and status register instructions and the fence instructions will not be
implemented, while the ecall instruction will be used to indicate that execution of a program has ended.
The system should be built such that test programs may be downloaded from a computer to the mem-
ory on the FPGA using a UART connection over USB, and similarly, such that the register content
after execution may be uploaded from the FPGA via the same connection. Test programs may be
written directly in RISC-V assembly or in C and compiled into binary instruction files using RISC-V
gcc. Execution results may be compared to results obtained from a software simulation of the imple-
mented base instruction set and extensions (a working RV32I ISA simulator has already been written
in 02155, and it may easily be extended to support RV64I).
