-- *******************************************************************************************
--              |
-- Title        : Implementation and Optimization of a RISC-V Processor on a FPGA
--              |
-- Developers   : Hans Jakob Damsgaard, Technical University of Denmark
--              : s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
--              |
-- Purpose      : This file is a part of a full system implemented as part of a bachelor's
--              : thesis at DTU. The thesis is written in cooperation with the Institute
--              : of Math and Computer Science.
--              : This entity represents the adder the adds the immediate to the PC in the
--              : execution stage of the pipeline.
--              |
-- Revision     : 1.0   (last updated February 3, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity pc_adder is
    port (
        -- Input ports
        immediate : in std_logic_vector(DATA_WIDTH-1 downto 0);
        pc_in : in std_logic_vector(PC_WIDTH-1 downto 0);
        -- Output port
        pc_out : out std_logic_vector(PC_WIDTH-1 downto 0)
    );
end pc_adder;

architecture rtl of pc_adder is
    signal imm_int : std_logic_vector(PC_WIDTH-1 downto 0);
begin
    imm_int <= immediate(PC_WIDTH-1 downto 0);
    pc_out <= std_logic_vector(unsigned(pc_in) + shift_left(unsigned(imm_int), 1));
end rtl;