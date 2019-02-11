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
-- Revision     : 1.0   (last updated February 9, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package includes is
    -- Relevant constants
    constant PC_WIDTH : integer := 12;
    constant DATA_WIDTH : integer := 64;

    -- Declarations for the register control signals
    type alu_op_t is (ALU_AND, ALU_OR, ALU_XOR, ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU,
                      ALU_SLL, ALU_SRL, ALU_SRA, ALU_NOP);
    type branch_t is (BR_J, BR_JR, BR_EQ, BR_NE, BR_LT, BR_LTU, BR_GE, BR_GEU, BR_NOP);
    type mem_op_t is (MEM_LB, MEM_LBU, MEM_LH, MEM_LHU, MEM_LW, MEM_LWU, MEM_LD, MEM_SB,
                      MEM_SH, MEM_SW, MEM_SD, MEM_NOP);
    type wb_t is (WB_RES, WB_MEM, WB_PCp4);
    type op_t is (OP_IDEX, OP_EXMEM, OP_MEMWB);
    -- Signals controlling functionality in the WB stage
    type ControlWB_t is record
        RegWrite : std_logic;
        MemtoReg : wb_t;
    end record ControlWB_t;
    -- Signals controlling functionality in the MEM stage
    type ControlM_t is record
        Branch : std_logic;
        MemRead : std_logic;
        MemWrite : std_logic;
    end record ControlM_t;
    -- Signals controlling functinality in the EX stage
    type ControlEX_t is record
        ALUOp : alu_op_t;
        ALUSrcA : std_logic;
        ALUSrcB : std_logic;
    end record ControlEX_t;

    -- Declarations for the IFID register
    type IFID_t is record
        PC : std_logic_vector(PC_WIDTH-1 downto 0);
        PCp4 : std_logic_vector(PC_WIDTH-1 downto 0);
        Instruction : std_logic_vector(31 downto 0);
    end record IFID_t;

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

    -- Declarations for the EXMEM register
    type EXMEM_t is record
        -- Control signals
        WB : ControlWB_t;
        M : ControlM_t;
        Zero : std_logic;
        LessThan : std_logic;
        LessThanU : std_logic;
        GrThanEq : std_logic;
        GrThanEqU : std_logic;
        -- Data signals
        PC : std_logic_vector(PC_WIDTH-1 downto 0);
        PCp4 : std_logic_vector(PC_WIDTH-1 downto 0);
        Result : std_logic_vector(DATA_WIDTH-1 downto 0);
        Data : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRd : std_logic_vector(4 downto 0);
    end record EXMEM_t;

    -- Declarations for the MEMWB register
    type MEMWB_t is record
        -- Control signals
        WB : ControlWB_t;
        -- Data signals
        PCp4 : std_logic_vector(PC_WIDTH-1 downto 0);
        MemData : std_logic_vector(DATA_WIDTH-1 downto 0);
        Result : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRd : std_logic_vector(4 downto 0);
    end record MEMWB_t;
end includes;

package body includes is
end includes;