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
--              : This entity represents the pipeline register between the IF and the ID
--              : stages and it is supposed to store the PC and the instruction fetched
--              : from the instruction memory.
--              |
-- Revision     : 1.0   (last updated January 30, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

entity IFID_register is
    port (
        -- Control ports
        clk, reset : in std_logic;
        -- Data ports
        pc_in : in std_logic_vector(PC_WIDTH-1 downto 0);
        instr_in : in word;
        pc_out : out std_logic_vector(PC_WIDTH-1 downto 0);
        instr_out : out word
    );
end IFID_register;

architecture rtl of IFID_register is
begin
    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then 
                pc_out <= ZERO_PC;
                instr_out <= NOP;
            else
                pc_out <= pc_in;
                instr_out <= instr_in;
            end if;
        end if;
    end process;
end rtl;