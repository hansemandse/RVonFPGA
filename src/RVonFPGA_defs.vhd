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
--              : This package contains useful definitions that may be used within other
--              : components. std_logic_vectors are used along with local type conversions
--              : whenever necessary.
--              |
-- Revision     : 1.3   (last updated February 2, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

package defs is
    -- Data definitions
    constant BYTE_WIDTH : integer := 8;
    constant HALFWORD_WIDTH : integer := 16;
    constant WORD_WIDTH : integer := 32;
    constant DOUBLEWORD_WIDTH : integer := 64;

    subtype byte is std_logic_vector(7 downto 0);
    subtype halfword is std_logic_vector(15 downto 0);
    subtype word is std_logic_vector(31 downto 0);
    subtype doubleword is std_logic_vector(63 downto 0);

    constant zero_byte : byte := "00000000";
    constant zero_halfword : halfword := zero_byte & zero_byte;
    constant zero_word : word := zero_halfword & zero_halfword;
    constant zero_doubleword : doubleword := zero_word & zero_word;

    constant one_byte : byte := "11111111";
    constant one_halfword : halfword := one_byte & one_byte;
    constant one_word : word := one_halfword & one_halfword;
    constant one_doubleword : doubleword := one_word & one_word;

    -- RISC-V-related definitions
    constant DATA_WIDTH : integer := 64;
    constant ADDR_WIDTH : integer := 5;
    
    constant PC_WIDTH : integer := 32;
    constant ZERO_PC : std_logic_vector(PC_WIDTH-1 downto 0) := 0;
    
    constant INSTR_WIDTH : integer := 32;

    constant NOP : std_logic_vector(INSTR_WIDTH-1 downto 0) := 0;-- INSERT NOP HERE

    -- Operation types carried out by the ALU
    type alu_op_t is (ALU_AND, ALU_OR, ALU_XOR, ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU,
                      ALU_SLL, ALU_SRL, ALU_SRA, ALU_NOP, ALU_ADDW, ALU_SUBW, ALU_SLLW, 
                      ALU_SRLW, ALU_SRAW);
end defs;

package body defs is
end defs;