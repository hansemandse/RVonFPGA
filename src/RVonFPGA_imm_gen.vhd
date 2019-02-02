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
--              : This entity represents an immediate generator as part of the decoding stage
--              : of the pipeline.
--              |
-- Revision     : 1.1   (last updated February 2, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

entity imm_gen is
    port (
        -- Instruction input
        instr_in : in word;
        -- Immediate output
        immediate : out doubleword
    );
end imm_gen;

architecture rtl of imm_gen is
    signal opcode : std_logic_vector(4 downto 0);
begin
    opcode <= instr_in(6 downto 2);
    process (opcode)
    begin
        case (opcode) is
            when "01101" | "00101" => -- LUI or AUIPC
                immediate <= (11 downto 0 => '0', 30 downto 12 => instr_in(30 downto 12), 
                              others => instr_in(31));
            when "11011" => -- JAL
                immediate <= (0 => '0', 10 downto 1 => instr_in(30 downto 21), 11 => instr_in(20),
                              19 downto 12 => instr_in(19 downto 12), others => instr_in(31));
            when "11001" => -- JALR
                immediate <= (10 downto 0 => instr_in(30 downto 20), others => instr_in(31));
            when "11000" => -- branch instructions
                immediate <= (0 => '0', 4 downto 1 => instr_in(11 downto 8), 
                              10 downto 5 => instr_in(30 downto 25), 11 => instr_in(7),
                              others => instr_in(31));
            when "00000" => -- load instructions 
                immediate <= (10 downto 0 => instr_in(30 downto 20), others => instr_in(31));
            when "00100" => -- immediate instructions
                if (instr_in(14 downto 12) = "001" or instr_in(14 downto 12) = "101") then
                    -- instruction is a shift, shamt has to be extracted
                    immediate <= (5 downto 0 => instr_in(25 downto 20), others => '0');
                else
                    -- instruction is a regular immediate instruction
                    immediate <= (10 downto 0 => instr_in(30 downto 20), others => instr_in(31));
                end if;
            when "01000" => -- store instructions
                immediate <= (4 downto 0 => instr_in(11 downto 7), 10 downto 5 => instr_in(30 downto 25),
                              others => instr_in(31));
            when "00110" => -- immediate word instructions
                if (instr_in(14 downto 12) = "000") then
                    -- instruction is an ADDIW
                    immediate <= (10 downto 0 => instr_in(30 downto 20), others => instr_in(31));
                else
                    -- instruction is a shift, shamt has to be extracted
                    immediate <= (4 downto 0 => instr_in(24 downto 20), others => '0');
                end if;
            when others => -- register-register instructions
                immediate <= (others => '0');
        end case;
    end process;
end rtl;