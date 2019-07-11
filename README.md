# RVonFPGA
This project focuses on the implementation of a single RISC-V pipeline implementing the so-called RV64I base instruction set on a Xilinx Artix®-7 FPGA utilizing the available resources efficiently such that the clock frequency may be increased as much as possible. The chip is available on various test boards including the NEXYS 4 DDR and the Basys 3 boards in two different versions - both with maximum clock frequencies of 100 MHz and both implementing 6-input LUTs and plenty of memory resources. The system does not implement the CSR instructions and their related hardware, the FENCE instructions and the ECALL and EBREAK instructions.

The system included in this repository implements a 6-stage RISC-V pipeline with the above specifications equipped with a 4 KB bootloader ROM, a 64 KB RAM (allowing 1-cycle misaligned access) and a small I/O unit including both LEDs, switches and a UART. The pipeline implementation is outlined in the following figure.
![alt text](https://raw.githubusercontent.com/hansemandse/RVonFPGA/master/PipelineData_v3.png)

A report describing the design and implementation is available [here](https://www.dropbox.com/s/m0x23xepmjrkr4g/Bachelor%20s163915.pdf?dl=0).