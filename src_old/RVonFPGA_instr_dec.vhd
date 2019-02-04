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
--              : This entity represents an instruction decoder as part of the decoding stage
--              : of the RISC-V pipeline. Its outputs are part of the control of the pipeline.
--              |
-- Revision     : 1.2   (last updated February 2, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

-- MIGHT NOT BE SUPER NECESSARY (CONTROL TAKES SOME OF ITS ROLES)
-- REDO SUCH THAT SHAMT IS ENCODED AS AN IMMEDIATE AND THIS FILE HAS MORE OF THE CONTROL'S
-- ROLE IN THE FINAL SYSTEM

-- Redo completely - make it much simpler !!!
-- Immediate generation should be possible to finish

library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

entity instr_decoder is
    port (
        -- Instruction input
        instr_in : in word;

        -- Outputs for the decoding stage
        sreg_1, sreg_2 : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        -- Outputs for the execution stage
        immediate : out doubleword;
        fct3 : out std_logic_vector(3 downto 0);
        alu_src : out 
        alu_op : out alu_op_t;
        -- Outputs for the memory stage
        mem_read, mem_write, branch : out std_logic;
        -- Outputs for the writeback stage
        reg_write, mem_to_reg : out std_logic;
        dreg : out std_logic_vector(ADDR_WIDTH-1 downto 0)
    );
end instr_decoder;

architecture rtl of instr_decoder is
    signal funct3 : std_logic_vector(2 downto 0);
    signal opcode : std_logic_vector(6 downto 0);
    signal l_type : instr_t; -- Type letter (either R, I, S, B, U or J)
begin
    -- Signal definitions
    opcode <= instr_in(6 downto 0);
    funct3 <= instr_in(14 downto 12); fct3 <= funct3;
    -- Outputs given in the instruction
    dreg <= instr_in(11 downto 7);
    sreg_1 <= instr_in(19 downto 15);
    sreg_2 <= instr_in(24 downto 20);
    -- Instruction decoding and immediate generation
    process (instr_in)
    begin
        -- Default assignments to avoid inferred latches
        l_type <= R_t;
        case (opcode) is
            when "0110111" => -- LUI
                l_type <= U_t;
            when "0010111" => -- AUIPC
                l_type <= U_t;
            when "1101111" => -- JAL
                l_type <= J_t;
            when "1100111" => -- JALR
                l_type <= I_t;
            when "1100011" => -- BEQ, BNE, BLT, BGE, BLTU and BGEU
                l_type <= B_t;
            when "0000011" => -- LB, LH, LW, LD, LBU, LHU and LWU
                l_type <= I_t;
            when "0100011" => -- SB, SH, SW and SD
                l_type <= S_t;
            when "0010011" => -- ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI and SRAI
                l_type <= I_t;
            when "0110011" => -- ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR and AND
                -- Letter type is per default R_t, zero immediate will be assigned
            when "0001111" => -- FENCE and FENCE_I
                -- These two have no letter type, assigning to R_t means zero immediate
            when "1110011" => -- ECALL, EBREAK, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI and CSRRCI
                -- These two have no letter type, assigning to R_t means zero immediate
            when "0011011" => -- ADDIW, SLLIW, SRLIW and SRAIW
                -- ADDIW is I-type, the other three hold a shamt value instead
                l_type <= I_t;
            when others => -- ADDW, SUBW, SLLW, SRLW and SRAW
                -- Letter type is per default R_t, zero immediate will be assigned
        end case;

        -- Immediate generation
        case (l_type) is
            when J_t =>
                -- J-type instructions have a very split up immediate
                immediate <= (others => instr_in(31), 31 => instr_in(31), 
                             30 downto 23 => instr_in(19 downto 12), 22 => instr_in(20),
                             21 downto 12 => instr_in(30 downto 21), 0 => '0';
            when I_t =>
                -- I-type instructions hold a small 12-bit immediate
                immediate <= (others => instr_in(31)) & instr_in(31 downto 20);
            when S_t =>
                -- S-type instructions have a split up immediate
                immediate <= (others => instr_in(31)) & instr_in(31 downto 25) 
                             & instr_in(11 downto 7);
            when B_t =>
                -- B-type instructions also have a split up immediate
                immediate <= (others => instr_in(31)) & instr_in(31) & instr_in(7)
                             & instr_in(30 downto 25) & instr_in(11 downto 8);
            when U_t =>
                -- U-type instructions have a large immediate
                immediate <= (others => instr_in(31)) & instr_in(31 downto 12) 
                             & "000000000000";
            when others =>
                -- R-type instructions do not contain an immediate
                immediate <= zero_doubleword;
        end case;
    end process;
end rtl;