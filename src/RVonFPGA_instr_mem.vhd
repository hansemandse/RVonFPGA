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
--              : This entity represents the instruction memory of the pipeline.
--              |
-- Revision     : 1.0   (last updated February 8, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity instr_mem is
    generic (
        ADDR_WIDTH : integer := 12;
        ARRAY_WIDTH : integer := 2 ** ADDR_WIDTH
    );
    port (
        -- Control ports
        clk, reset : in std_logic;
        -- Data port
        Address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        Instruction : out std_logic_vector(31 downto 0)
    );
end instr_mem;

architecture rtl of instr_mem is
    type ram_t is array(ARRAY_WIDTH-1 downto 0) of std_logic_vector(7 downto 0);
    signal ram : ram_t;
begin

end rtl;