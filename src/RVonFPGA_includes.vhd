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
-- Revision     : 1.2   (last updated March 8, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

package includes is
    -- Relevant constants
    constant BYTE_WIDTH : natural := 8;
    constant DATA_ADDR_WIDTH : natural := 12;
    constant PC_WIDTH : natural := 12;
    constant DATA_WIDTH : natural := 64;
    constant PC_reset : std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');
    constant PCp4_reset : std_logic_vector(PC_WIDTH-1 downto 0) := (2 => '1', others => '0');
    -- Hardcoded NOP instruction (ADDI x0, x0, 0) used for branching
    constant NOP : std_logic_vector(31 downto 0) := x"00000013";

    -- Test file for the instruction memory and for simulation of the pipeline
    constant TEST_FILE : string := "../tests/s_tests/test_load.bin";

    -- Function to get number of instructions in test file
    impure function get_instr_count (f : string) return natural;

    -- Declarations for the register control signals
    type alu_op_t is (ALU_AND, ALU_OR, ALU_XOR, ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU,
                      ALU_SLL, ALU_SRL, ALU_SRA, ALU_ADDW, ALU_SUBW, ALU_SLLW, 
                      ALU_SRLW, ALU_SRAW, ALU_NOP);
    type branch_t is (BR_J, BR_JR, BR_EQ, BR_NE, BR_LT, BR_LTU, BR_GE, BR_GEU, BR_NOP);
    type mem_op_t is (MEM_LB, MEM_LBU, MEM_LH, MEM_LHU, MEM_LW, MEM_LWU, MEM_LD, MEM_SB,
                      MEM_SH, MEM_SW, MEM_SD, MEM_NOP);
    type imem_op_t is (MEM_SB, MEM_SW, MEM_SD, MEM_NOP);
    type wb_t is (WB_RES, WB_MEM, WB_PCp4);
    type op_t is (OP_IDEX, OP_EXMEM, OP_MEMWB);

    -- Signals controlling functionality in the WB stage
    type ControlWB_t is record
        RegWrite : std_logic;
        MemtoReg : wb_t;
    end record ControlWB_t;
    constant WB_reset : ControlWB_t := (RegWrite => '0', MemtoReg => WB_RES);

    -- Signals controlling functionality in the MEM stage
    type ControlM_t is record
        MemRead : std_logic;
        MemWrite : std_logic;
        MemOp : mem_op_t;
    end record ControlM_t;
    constant M_reset : ControlM_t := (MemRead | MemWrite => '0', MemOp => MEM_NOP);

    -- Signals controlling functinality in the EX stage
    type ControlEX_t is record
        Branch : branch_t;
        ALUOp : alu_op_t;
        ALUSrcA : std_logic;
        ALUSrcB : std_logic;
    end record ControlEX_t;
    constant EX_reset : ControlEX_t := (Branch => BR_NOP, ALUOp => ALU_NOP, 
                                        ALUSrcA | ALUSrcB => '0');

    -- Declarations for the IFID register
    type IFID_t is record
        SkipInstr : std_logic;
        PC : std_logic_vector(PC_WIDTH-1 downto 0);
        PCp4 : std_logic_vector(PC_WIDTH-1 downto 0);
    end record IFID_t;
    constant IFID_reset : IFID_t := (SkipInstr => '0', PC => PC_reset, PCp4 => PCp4_reset);

    -- Declarations for the IDEX register
    type IDEX_t is record
        -- Control signals
        WB : ControlWB_t;
        M : ControlM_t;
        EX : ControlEX_t;
        -- Data signals
        PC : std_logic_vector(PC_WIDTH-1 downto 0);
        PCp4 : std_logic_vector(PC_WIDTH-1 downto 0);
        Immediate : std_logic_vector(DATA_WIDTH-1 downto 0);
        Data1 : std_logic_vector(DATA_WIDTH-1 downto 0);
        Data2 : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRs1 : std_logic_vector(4 downto 0);
        RegisterRs2 : std_logic_vector(4 downto 0);
        RegisterRd : std_logic_vector(4 downto 0);
    end record IDEX_t;
    constant IDEX_reset : IDEX_t := (WB => WB_reset, M => M_reset, EX => EX_reset,
                                     PC => PC_reset, PCp4 => PCp4_reset,
                                     Immediate | Data1 | Data2 | RegisterRs1 | RegisterRs2 | 
                                     RegisterRd => (others => '0'));

    -- Declarations for the EXMEM register
    type EXMEM_t is record
        -- Control signals
        WB : ControlWB_t;
        M : ControlM_t;
        -- Data signals
        PCp4 : std_logic_vector(PC_WIDTH-1 downto 0);
        Result : std_logic_vector(DATA_WIDTH-1 downto 0);
        Data : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRd : std_logic_vector(4 downto 0);
    end record EXMEM_t;
    constant EXMEM_reset : EXMEM_t := (WB => WB_reset, M => M_reset, PCp4 => PCp4_reset,
                                       Result | Data | RegisterRd => (others => '0'));

    -- Declarations for the MEMWB register
    type MEMWB_t is record
        -- Control signals
        WB : ControlWB_t;
        -- Data signals
        PCp4 : std_logic_vector(PC_WIDTH-1 downto 0);
        Result : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRd : std_logic_vector(4 downto 0);
    end record MEMWB_t;
    constant MEMWB_reset : MEMWB_t := (WB => WB_reset, PCp4 => PCp4_reset, 
                                       Result | RegisterRd => (others => '0'));
end includes;

package body includes is
    -- Function body for the instruction counter
    impure function get_instr_count (f : string) return natural is
        file file_in : text open READ_MODE is f;
        variable c_line : line;
        variable c_buf : character;
        variable index : natural := 0;
    begin
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