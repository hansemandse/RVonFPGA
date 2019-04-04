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
--              : This file contains all of the type definitions required in the pipeline
--              : and in the memories.
--              |
-- Revision     : 2.0   (last updated April 4, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

package includes is
    -- Clock divider relevant constants
    constant CLOCK_F : natural := 100_000_000;
    constant CLOCK_DIV : natural := 2;
    constant CLOCK_F_INT : natural := CLOCK_F / CLOCK_DIV;

    -- Communication relevant constants
    constant BAUD_RATE : natural := 115200; -- Used in course 02203 at DTU

    -- Pipeline relevant constants
    constant RF_ADDR_WIDTH : natural := 5;
    constant BYTE_WIDTH : natural := 8;
    constant DATA_ADDR_WIDTH : natural := 12;
    constant PC_WIDTH : natural := 12;
    constant DATA_WIDTH : natural := 64;
    constant PC_reset : std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');
    constant PCp4_reset : std_logic_vector(PC_WIDTH-1 downto 0) := (2 => '1', others => '0');
    constant PC_MAX : std_logic_vector(PC_WIDTH-1 downto 0) := (others => '1');
    -- Hardcoded NOP instruction (ADDI x0, x0, 0) used for branching
    constant NOP : std_logic_vector(31 downto 0) := x"00000013";

    -- Test file for the instruction memory and for simulation of the pipeline
    constant INIT_RAM : std_logic := '1';
    constant TEST_FILE : string := "../tests/s_tests/test_add.bin";

    -- Function to get number of instructions in test file
    impure function get_instr_count (f : string) return natural;
end includes;

package body includes is
    -- Function body for the instruction counter
    impure function get_instr_count (f : string) return natural is
        file file_in : text open READ_MODE is f;
        variable c_line : line;
        variable c_buf : character;
        variable index : natural := 0;
    begin
        if (f = "") then
            return 0;
        end if;
        while (not endfile(file_in)) loop
            readline(file_in, c_line);
            while (c_line'length > 0) loop
                read(c_line, c_buf);
                index := index + 1;
            end loop;
            if (not endfile(file_in)) then 
                -- Line feed must have been found in input file
                index := index + 1;
            end if;
        end loop;
        return index/4;
    end function;
end includes;