-- *******************************************************************************************
--              |
-- Title        : Implementation and Optimization of a RISC-V Processor on a FPGA
--              |
-- Developers   : Hans Jakob Damsgaard, Technical University of Denmark
--              : s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
--              |
-- Purpose      : This file is a part of a full system implemented as part of a bachelor's
--              : thesis at DTU. The thesis is written in cooperation with the Institute
--              : of Mathematics and Computer Science.
--              : This entity represents the pipeline of the processor. It is written in the
--              : classic two-process way with one process describing all combinational
--              : circuitry (next-state, arithmetics and outputs) and one describing the
--              : registers.
--              |
-- Revision     : 2.0   (last updated April 26, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.includes.all;

entity pipeline is
    port (
        -- Input ports
        clk, reset : in std_logic;
        -- Instruction memory interface
        IMemOp : out mem_op_t;
        IReady : in std_logic;
        IAddr : out std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
        IReadData : in std_logic_vector(DATA_WIDTH-1 downto 0);
        -- Data memory interface
        DMemOp : out mem_op_t;
        DAddr : out std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
        DWriteData : out std_logic_vector(DATA_WIDTH-1 downto 0);
        DReadData : in std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end pipeline;