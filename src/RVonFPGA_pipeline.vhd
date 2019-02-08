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
--              : This entity represents the pipeline of the processor. It is written in the
--              : classic two-process way with one process describing all combinational
--              : circuitry (next-state, arithmetics and outputs) and one describing the
--              : registers.
--              |
-- Revision     : 1.0   (last updated February 8, 2019)
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
    signal pc, pc_next, pc_inc : std_logic_vector(PC_WIDTH-1 downto 0);

    -- Declarations for the register control signals
    type alu_op_t is (ALU_AND, ALU_OR, ALU_XOR, ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU,
                      ALU_SLL, ALU_SRL, ALU_SRA, ALU_NOP);
    type wb_t is (WB_RES, WB_MEM, WB_PCp4);
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
    signal IFID, IFID_next : IFID_t;

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
    signal IDEX, IDEX_next : IDEX_t;

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
    signal EXMEM, EXMEM_next : EXMEM_t;

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
    signal MEMWB, MEMWB_next : MEMWB_t;

    -- Signals for the ID stage

    -- Signals for the EX stage
    type op_t is (OP_IDEX, OP_EXMEM, OP_MEMWB);
    signal ForwardA, ForwardB : op_t;
    signal ALUOperand1, ALUOperand2, ALUResult : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Signals for the MEM stage
    signal PCSrc : std_logic;

    -- Signals for the WB stage
    signal WriteData : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- External pipeline components
    component register_file is
        generic (
            DATA_WIDTH : integer := 64;
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
            ADDR_WIDTH : integer := 12;
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
            DATA_WIDTH : integer := 64;
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

    rf : register_file 
    generic map (
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        RegWrite => MEMWB.WB.RegWrite,
        clk => clk,
        reset => reset,
        RegisterRs1 => rs1,
        RegisterRs2 => rs2,
        RegisterRd => MEMWB.RegisterRd,
        Data1 => ,-- FILL IN HERE
        Data2 => ,-- FILL IN HERE
        WriteData => WriteData
    );

    im : instr_mem
    generic map (
        ADDR_WIDTH => PC_WIDTH
    )
    port map (
        clk => clk,
        reset => reset,
        Address => pc,
        Instruction => -- FILL IN HERE
    );

    dm : data_mem
    generic map (
        DATA_WIDTH => DATA_WIDTH
    )
    port map (
        MemRead => EXMEM.M.MemRead,
        MemWrite => EXMEM.M.MemWrite,
        clk => clk,
        reset => reset,
        Address => EXMEM.Result,
        WriteData => EXMEM.Data,
        ReadData => -- FILL IN HERE
    );

    -- Process describing all combinational parts of the circuit
    comb: process (all)
    begin
        -- Default assignments for all register-related signals
        pc_next <= pc;
        IFID_next <= IFID;
        IDEX_next <= IDEX;
        EXMEM_next <= EXMEM;
        MEMWB_next <= MEMWB;

        -- Updating values of the IDEX register
        IDEX_next.EX.ALUSrcA <= '0';
        IDEX_next.EX.ALUSrcB <= '0';
        IDEX_next.EX.ALUOp <= ALU_NOP;
        IDEX_next.M.MemRead <= '0';
        IDEX_next.M.MemWrite <= '0';
        IDEX_next.M.Branch <= '0';
        IDEX_next.WB.RegWrite <= '0';
        IDEX_next.WB.MemtoReg <= WB_RES;
        IDEX_next.PC <= IFID.PC;
        IDEX_next.PCp4 <= IFID.PCp4;
        IDEX_next.RegisterRs1 <= rs1;
        IDEX_next.RegisterRs2 <= rs2;
        IDEX_next.RegisterRd <= rd;

        -- Updating values of the EXMEM register
        EXMEM_next.M <= IDEX.M;
        EXMEM_next.WB <= IDEX.WB;
        EXMEM_next.PCp4 <= IDEX.PCp4;
        EXMEM_next.Data <= IDEX.Data2;
        EXMEM_next.RegisterRd <= IDEX.RegisterRd;

        -- Updating values of the MEMWB register
        MEMWB_next.WB <= EXMEM.WB;
        MEMWB_next.PCp4 <= EXMEM.PCp4;
        MEMWB_next.Result <= EXMEM.Result;
        MEMWB_next.RegisterRd <= EXMEM.RegisterRd;

        -- Immediate generator
        imm : case (opcode) is
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
        end case imm;

        -- Hazard detection
        -- FILL IN HERE

        -- Control generator
        control : case (opcode) is
            when "0110111" => -- LUI
                -- FILL IN HERE
            when "0010111" => -- AUIPC
                -- AUIPC adds a large immediate to the PC
                IDEX_next.EX.ALUSrcA <= '1';
                IDEX_next.EX.ALUSrcB <= '1';
                IDEX_next.WB.RegWrite <= '1';
            when "1101111" => -- JAL
                -- JAL performs an unconditional branch
                IDEX_next.M.Branch <= '1';
                IDEX_next.WB.MemtoReg <= WB_PCp4;
                IDEX_next.WB.RegWrite <= '1';
            when "1100111" => -- JALR
                -- FILL IN HERE
            when "1100011" => -- branch instructions
                -- FILL IN HERE
            when "0000011" => -- load instructions 
                -- Loads contain an immediate which is added to a register source
                IDEX_next.EX.ALUSrcB <= '1';
                IDEX_next.EX.ALUOp <= ALU_ADD;
                IDEX_next.M.MemRead <= '1';
                IDEX_next.WB.RegWrite <= '1';
                IDEX_next.WB.MemtoReg <= WB_MEM;
            when "0010011" => -- immediate instructions
                IDEX_next.EX.ALUSrcB <= '1';
                case (funct3) is
                    when "000" => -- ADDI
                        IDEX_next.EX.ALUOp <= ALU_ADD;
                    when "001" => -- SLLI
                        IDEX_next.EX.ALUOp <= ALU_SLL;
                    when "010" => -- SLTI
                        IDEX_next.EX.ALUOp <= ALU_SLT;
                    when "011" => -- SLTIU
                        IDEX_next.EX.ALUOp <= ALU_SLTU;
                    when "100" => -- XORI
                        IDEX_next.EX.ALUOp <= ALU_XOR;
                    when "101" => -- SRLI or SRAI
                        if (funct7(5) = '1') then
                            IDEX_next.EX.ALUOp <= ALU_SRA;
                        else
                            IDEX_next.EX.ALUOp <= ALU_SRL;
                        end if;
                    when "110" => -- ORI
                        IDEX_next.EX.ALUOp <= ALU_OR;
                    when others => -- ANDI
                        IDEX_next.EX.ALUOp <= ALU_AND;
                end case;
                IDEX_next.WB.RegWrite <= '1';
            when "0100011" => -- store instructions
                -- Stores contain an immediate which is added to a register source
                IDEX_next.EX.ALUSrcB <= '1';
                IDEX_next.EX.ALUOp <= ALU_ADD;
                IDEX_next.M.MemWrite <= '1';
            when "0011011" => -- immediate word instructions
                -- FILL IN HERE
            when others => -- register-register instructions
                case (funct3) is
                    when "000" => -- ADD or SUB
                        if (funct7(5) = '1') then
                            IDEX_next.EX.ALUOp <= ALU_SUB;
                        else
                            IDEX_next.EX.ALUOp <= ALU_ADD;
                        end if;
                    when "001" => -- SLL
                        IDEX_next.EX.ALUOp <= ALU_SLL;
                    when "010" => -- SLT
                        IDEX_next.EX.ALUOp <= ALU_SLT;
                    when "011" => -- SLTU
                        IDEX_next.EX.ALUOp <= ALU_SLTU;
                    when "100" => -- XOR
                        IDEX_next.EX.ALUOp <= ALU_XOR;
                    when "101" => -- SRL or SRA
                        if (funct7(5) = '1') then
                            IDEX_next.EX.ALUOp <= ALU_SRA;
                        else
                            IDEX_next.EX.ALUOp <= ALU_SRL;
                        end if;
                    when "110" => -- OR
                        IDEX_next.EX.ALUOp <= ALU_OR;
                    when others =>
                        IDEX_next.EX.ALUOp <= ALU_AND;
                end case;
                IDEX_next.WB.RegWrite <= '1';
        end case control;

        -- Forwarding unit
        -- FILL IN HERE

        -- Arithmetic circuit (ALU and its multiplexors)
        -- Choosing the first operand
        op1 : if (IDEX.EX.ALUSrcA = '0') then
            case (ForwardA) is
                when OP_IDEX =>
                    ALUOperand1 <= IDEX.Data1;
                when OP_EXMEM =>
                    ALUOperand1 <= EXMEM.Result;
                when others =>
                    ALUOperand1 <= WriteData;
            end case;
        else
            ALUOperand1 <= (PC_WIDTH-1 downto 0 => IDEX.PC, others => '0');
        end if;
        -- Choosing the second operand (two layers of multiplexors)
        op2 : if (IDEX.EX.ALUSrcB = '0') then
            case (ForwardB) is
                when OP_IDEX =>
                    ALUOperand2 <= IDEX.Data2;
                when OP_EXMEM =>
                    ALUOperand2 <= EXMEM.Result;
                when others =>
                    ALUOperand2 <= WriteData;
            end case;
        else
            ALUOperand2 <= IDEX.Immediate;
        end if op2;
        -- Instantiating the actual ALU which operates on the above two operands
        -- and outputs a result determined by the control circuit in the ID stage
        alu : case (IDEX.EX.ALUOp) is
            when ALU_ADD =>
                ALUResult <= std_logic_vector(signed(ALUOperand1) + signed(ALUOperand2));
            when ALU_SUB =>
                ALUResult <= std_logic_vector(signed(ALUOperand1) - signed(ALUOperand2));
            when ALU_AND =>
                ALUResult <= ALUOperand1 and ALUOperand2;
            when ALU_OR =>
                ALUResult <= ALUOperand1 or ALUOperand2;
            when ALU_XOR =>
                ALUResult <= ALUOperand1 xor ALUOperand2;
            when ALU_SLT =>
                if (signed(ALUOperand1) < signed(ALUOperand2)) then
                    ALUResult <= (0 => '1', others => '0');
                else 
                    ALUResult <= (others => '0');
                end if;
            when ALU_SLTU =>
                if (unsigned(ALUOperand1) < unsigned(ALUOperand2)) then
                    ALUResult <= (0 => '1', others => '0');
                else 
                    ALUResult <= (others => '0');
                end if;
            when ALU_SLL =>
                -- For RV64I, the shamt value is 6 bits for register-register instructions and
                -- for doubleword-size immediate instructions
                ALUResult <= shift_left(ALUOperand1, to_integer(unsigned(ALUOperand2(5 downto 0))));
            when ALU_SRL =>
                ALUResult <= std_logic_vector(shift_right(unsigned(ALUOperand1), 
                                              to_integer(unsigned(ALUOperand2(5 downto 0)))));
            when ALU_SRA =>
                ALUResult <= std_logic_vector(shift_right(signed(ALUOperand1), 
                                              to_integer(unsigned(ALUOperand2(5 downto 0)))));
            when others =>
                ALUResult <= (others => '0');
        end case alu;
        EXMEM_next.Result <= ALUResult;
        -- Code for the branch detection circuitry
        if (ALUResult = 0) then
            EXMEM_next.Zero <= '1';
        else 
            EXMEM_next.Zero <= '0';
        end if;
        if (unsigned(ALUOperand1) < unsigned(ALUOperand2)) then
            EXMEM_next.LessThanU <= '1';
            EXMEM_next.GrThanEqU <= '0';
        else
            EXMEM_next.LessThanU <= '0';
            EXMEM_next.GrThanEqU <= '1';
        end if;
        if (signed(ALUOperand1) < signed(ALUOperand2)) then
            EXMEM_next.LessThan <= '1';
            EXMEM_next.GrThanEq <= '0';
        else 
            EXMEM_next.LessThan <= '0';
            EXMEM_next.GrThanEq <= '1';
        end if;

        -- Updating the PC
        pc_inc <= std_logic_vector(unsigned(pc) + 4);
        IFID_next.PCp4 <= pc_inc;
        EXMEM_next.PC <= std_logic_vector(unsigned(IDEX.PC) + unsigned(shift_left(IDEX.Immediate, 1)));
        if (PCSrc = '0') then
            pc_next <= pc_inc;
        else
            pc_next <= EXMEM.pc;
        end if;

        -- Temporary branch logic in the MEM stage (only works for BEQ)
        PCSrc <= EXMEM.M.Branch and EXMEM.Zero;

        -- Determining the data to write back
        wb : case (MemtoReg) is
            when WB_RES =>
                WriteData <= MEMWB.Result;
            when WB_MEM =>
                WriteData <= MEMWB.MemData;
            when WB_PCp4 =>
                WriteData <= MEMWB.PCp4;
        end case wb;
    end process comb;

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
    end process regs;

end rtl;