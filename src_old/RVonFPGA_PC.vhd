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
--              : This entity represents the PC controlling the pipeline.
--              |
-- Revision     : 1.1   (last updated February 6, 2019)
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
        -- Control inputs
        clk, reset : in std_logic;
        sel : in pc_source;
        -- Input ports
        immediate : in std_logic_vector(DATA_WIDTH-1 downto 0);
        -- Output port
        pc_out : out std_logic_vector(PC_WIDTH-1 downto 0)
    );
end pc_adder;

architecture rtl of pc_adder is
    signal pc, pc_next : std_logic_vector(PC_WIDTH-1 downto 0);
    signal imm_int, op_2 : std_logic_vector(PC_WIDTH-1 downto 0);
begin
    process (sel)
    begin
        case (sel) is
            when PC_INC =>
                op_2 <= shift_left(unsigned(immediate(PC_WIDTH-1 downto 0)), 1);
            when PC_BRC =>
                op_2 <= 4;
        end case;
    end process;

    pc_next <= pc + op_2;
    
    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                pc <= (others => '0');
            else
                pc <= pc_next;
            end if;
        end if;
    end process;
    
    pc_out <= pc;
end rtl;