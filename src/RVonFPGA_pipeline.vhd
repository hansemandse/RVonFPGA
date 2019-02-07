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
--              : This entity represents the pipeline of the processor. It is written in the
--              : classic two-process way with one process describing all combinational
--              : circuitry (next-state, arithmetics and outputs) and one describing the
--              : registers.
--              |
-- Revision     : 1.0   (last updated February 7, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pipeline is
    generic (
        PC_WIDTH : integer := 12; -- 2^12 is 4 kB
        DATA_WIDTH : integer := 64
    );
    port (
        -- Input ports
        clk, reset : in std_logic;
        -- FILL IN HERE
        -- Output ports
        -- FILL IN HERE
    );
end pipeline;

architecture rtl of pipeline is
    -- Declarations for the PC
    signal pc, pc_next : std_logic_vector(PC_WIDTH-1 downto 0);

    -- Declarations for the register control signals
    -- Signals controlling functionality in the WB stage
    type ControlWB_t is record
        RegWrite : std_logic;
        MemtoReg : std_logic;
    end record ControlWB_t;
    -- Signals controlling functionality in the MEM stage
    type ControlM_t is record
        Branch : std_logic;
        MemRead : std_logic;
        MemWrite : std_logic;
    end record ControlM_t;
    -- Signals controlling functinality in the EX stage
    type ControlEX_t is record
        ALUOp : 
        ALUSrc : 
    end record ControlEX_t;

    -- Declarations for the IFID register
    type IFID_t is record
        PC : std_logic_vector(PC_WIDTH-1 downto 0);
        Instruction : std_logic_vector(31 downto 0);
    end record IFID_t;
    signal IFID, IFID_next : IFID_t;

    -- Declarations for the IDEX register
    type IDEX_t is record
        -- Control signals
        WB : ControlWB_t;
        M : ControlM_t;
        EX : ControlEX_t;
        -- Data signals
        pc : std_logic_vector(PC_WIDTH-1 downto 0);
        Immediate : std_logic_vector(DATA_WIDTH-1 downto 0);
        Data1 : std_logic_vector(DATA_WIDTH-1 downto 0);
        Data2 : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRd : std_logic_vector(4 downto 0);
    end record IDEX_t;
    signal IDEX, IDEX_next : IDEX_t;

    -- Declarations for the EXMEM register
    type EXMEM_t is record
        -- Control signals
        WB : ControlWB_t;
        M : ControlM_t;
        Zero : std_logic;
        -- Data signals
        pc : std_logic_vector(PC_WIDTH-1 downto 0);
        Result : std_logic_vector(DATA_WIDTH-1 downto 0);
        Data2 : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRd : std_logic_vector(4 downto 0);
    end record EXMEM_t;
    signal EXMEM, EXMEM_next : EXMEM_t;

    -- Declarations for the MEMWB register
    type MEMWB_t is record
        -- Control signals
        WB : ControlWB_t;
        -- Data signals
        MemData : std_logic_vector(DATA_WIDTH-1 downto 0);
        Result : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRd : std_logic_vector(4 downto 0);
    end record MEMWB_t;
    signal MEMWB, MEMWB_next : MEMWB_t;

    -- Signals for the IF stage

    -- Signals for the ID stage

    -- Signals for the EX stage

    -- Signals for the MEM stage

    -- Signals for the WB stage
    signal WriteData : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- External pipeline components
    component register_file is
        generic (
            DATA_WIDTH : integer := DATA_WIDTH;
            ADDR_WIDTH : integer := 5;
            ARRAY_WIDTH : integer := 2 ** ADDR_WIDTH
        );
        port (
            -- Control ports
            RegWrite, clk, reset : in std_logic;
            -- Read port 1
            RegisterRs1 : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            Data1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
            -- Read port 2
            RegisterRs2 : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            Data2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
            -- Write port
            RegisterRd : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            WriteData : in std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component instr_mem is
        generic (
            ADDR_WIDTH : integer := PC_WIDTH;
            ARRAY_WIDTH : integer := 2 ** ADDR_WIDTH
        );
        port (
            -- Control ports
            clk, reset : in std_logic;
            -- Data port
            Address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            Instruction : out std_logic_vector(31 downto 0)
        );
    end component;

    component data_mem is
        generic (
            ADDR_WIDTH : integer := 12; -- Might need to be changed
            ARRAY_WIDTH : integer := 2 ** ADDR_WIDTH
        );
        port (
            -- Control ports
            MemRead, MemWrite, clk, reset : in std_logic;
            -- Data ports
            Address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            WriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            ReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

begin
    -- Aliases for the ID stage
    alias opcode : std_logic_vector(6 downto 0) is IFID.Instruction(6 downto 0);
    alias rd : std_logic_vector(4 downto 0) is IFID.Instruction(11 downto 7);
    alias funct3 : std_logic_vector(2 downto 0) is IFID.Instruction(14 downto 12);
    alias rs1 : std_logic_vector(4 downto 0) is IFID.Instruction(19 downto 15);
    alias rs2 : std_logic_vector(4 downto 0) is IFID.Instruction(24 downto 20);
    alias funct7 : std_logic_vector(6 downto 0) is IFID.Instruction(31 downto 25);

    PCSrc <= EXMEM.M.Branch and EXMEM.Zero;

    -- Process describing all combinational parts of the circuit
    comb: process (all)
    begin
        -- Default assignments for all register-related signals
        pc_next <= pc;
        IFID_next <= IFID;
        IDEX_next <= IDEX;
        EXMEM_next <= EXMEM;
        MEMWB_next <= MEMWB;

        -- Updating the PC
        if (PCSrc = '0') then
            pc_next <= std_logic_vector(unsigned(pc) + 4);
        else
            pc_next <= EXMEM.pc;
        end if;
        
        -- Immediate generator
        -- The two least significant are "11" in all of the cases. Vivado should notice this 
        -- and synthesize the circuit such that the two bits are not used. They are only 
        -- written here for completeness.
        case (opcode) is
            when "0110111" | "0010111" => -- LUI or AUIPC
                IDEX_next.Immediate <= (11 downto 0 => '0', 30 downto 12 => IFID.Instruction(30 downto 12), 
                                        others => IFID.Instruction(31));
            when "1101111" => -- JAL
                IDEX_next.Immediate <= (0 => '0', 10 downto 1 => IFID.Instruction(30 downto 21), 
                                        11 => IFID.Instruction(20), 19 downto 12 => IFID.Instruction(19 downto 12), 
                                        others => IFID.Instruction(31));
            when "1100111" => -- JALR
                IDEX_next.Immediate <= (10 downto 0 => IFID.Instruction(30 downto 20), 
                                        others => IFID.Instruction(31));
            when "1100011" => -- branch instructions
                IDEX_next.Immediate <= (0 => '0', 4 downto 1 => IFID.Instruction(11 downto 8), 
                                        10 downto 5 => IFID.Instruction(30 downto 25), 11 => IFID.Instruction(7),
                                        others => IFID.Instruction(31));
            when "0000011" => -- load instructions 
                IDEX_next.Immediate <= (10 downto 0 => IFID.Instruction(30 downto 20), 
                                        others => IFID.Instruction(31));
            when "0010011" => -- immediate instructions
                if (IFID.Instruction(14 downto 12) = "001" or IFID.Instruction(14 downto 12) = "101") then
                    -- instruction is a shift, shamt has to be extracted
                    IDEX_next.Immediate <= (5 downto 0 => IFID.Instruction(25 downto 20), others => '0');
                else
                    -- instruction is a regular immediate instruction
                    IDEX_next.Immediate <= (10 downto 0 => IFID.Instruction(30 downto 20), 
                                            others => IFID.Instruction(31));
                end if;
            when "0100011" => -- store instructions
                IDEX_next.Immediate <= (4 downto 0 => IFID.Instruction(11 downto 7), 
                                        10 downto 5 => IFID.Instruction(30 downto 25), others => IFID.Instruction(31));
            when "0011011" => -- immediate word instructions
                if (IFID.Instruction(14 downto 12) = "000") then
                    -- instruction is an ADDIW
                    IDEX_next.Immediate <= (10 downto 0 => IFID.Instruction(30 downto 20), others => IFID.Instruction(31));
                else
                    -- instruction is a shift, shamt has to be extracted
                    IDEX_next.Immediate <= (4 downto 0 => IFID.Instruction(24 downto 20), others => '0');
                end if;
            when others => -- register-register instructions
                IDEX_next.Immediate <= (others => '0');
        end case;

        -- Determining the data to write back
        if (MemtoReg = '0') then
            WriteData <= MEMWB.Result;
        else
            WriteData <= MEMWB.MemData;
        end if;
    end process;

    -- Process describing all of the registers in the circuit
    regs: process (all)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                pc <= (others => '0');
                -- FILL IN HERE
            else
                pc <= pc_next;
                IFID <= IFID_next;
                IDEX <= IDEX_next;
                EXMEM <= EXMEM_next;
                MEMWB <= MEMWB_next;
            end if;
        end if;
    end process;

end rtl;