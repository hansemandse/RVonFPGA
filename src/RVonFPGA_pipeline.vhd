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
-- Revision     : 1.0   (last updated February 12, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity pipeline is
    port (
        -- Input ports
        clk, reset : in std_logic
        -- FILL IN HERE
        -- Output ports
        -- FILL IN HERE
    );
end pipeline;

architecture rtl of pipeline is
    -- Declarations for the PC
    signal pc, pc_next, pc_inc : std_logic_vector(PC_WIDTH-1 downto 0);

    -- Declarations for the IFID register
    signal IFID, IFID_next : IFID_t;

    -- Declarations for the IDEX register
    signal IDEX, IDEX_next : IDEX_t;

    -- Declarations for the EXMEM register
    signal EXMEM, EXMEM_next : EXMEM_t;

    -- Declarations for the MEMWB register
    signal MEMWB, MEMWB_next : MEMWB_t;

    -- Signals for the ID stage
    signal Instruction : std_logic_vector(31 downto 0);
    signal opcode, funct7 : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal rs1, rs2, rd : std_logic_vector(4 downto 0);
    signal IFIDWrite, PCWrite, InsertNOP : std_logic;

    -- Signals for the EX stage
    signal Zero, LessThanU, LessThan : std_logic;
    signal ForwardA, ForwardB : op_t;
    signal ALUOperand1, ALUOperand2, ALUResult, ALUOperand1m, ALUOperand2m
                                            : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Signals for the MEM stage
    signal PCSrc : std_logic;

    -- Signals for the WB stage
    signal WriteData, MemData : std_logic_vector(DATA_WIDTH-1 downto 0);
    
begin
    -- Signals for the ID stage
    opcode <= Instruction(6 downto 0);
    rd <= Instruction(11 downto 7);
    funct3 <= Instruction(14 downto 12);
    rs1 <= Instruction(19 downto 15);
    rs2 <= Instruction(24 downto 20);
    funct7 <= Instruction(31 downto 25);

    rf : register_file
    port map (
        RegWrite => MEMWB.WB.RegWrite,
        clk => clk,
        RegisterRs1 => rs1,
        RegisterRs2 => rs2,
        RegisterRd => MEMWB.RegisterRd,
        Data1 => IDEX_next.Data1,
        Data2 => IDEX_next.Data2,
        WriteData => WriteData
    );

    im : instr_mem
    port map (
        MemWrite => , -- FILL IN HERE
        clk => clk,
        reset => reset,
        Address => pc,
        Instruction => -- FILL IN HERE
    );

    dm : data_mem
    port map (
        MemRead => EXMEM.M.MemRead,
        MemWrite => EXMEM.M.MemWrite,
        MemOp => EXMEM.M.MemOp,
        clk => clk,
        reset => reset,
        Address => EXMEM.Result(DATA_ADDR_WIDTH-1 downto 0),
        WriteData => EXMEM.Data,
        ReadData => MemData
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
        IDEX_next.EX.Branch <= BR_NOP;
        IDEX_next.M.MemRead <= '0';
        IDEX_next.M.MemWrite <= '0';
        IDEX_next.M.MemOp <= MEM_NOP;
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
        EXMEM_next.Data <= ALUOperand2m;
        EXMEM_next.RegisterRd <= IDEX.RegisterRd;

        -- Updating values of the MEMWB register
        MEMWB_next.WB <= EXMEM.WB;
        MEMWB_next.PCp4 <= EXMEM.PCp4;
        MEMWB_next.Result <= EXMEM.Result;
        MEMWB_next.RegisterRd <= EXMEM.RegisterRd;

        -- Immediate generator
        imm : case (opcode) is
            when "0110111" | "0010111" => -- LUI or AUIPC
                IDEX_next.Immediate <= (11 downto 0 => '0', 30 downto 12 => Instruction(30 downto 12), 
                                        others => Instruction(31));
            when "1101111" => -- JAL
                IDEX_next.Immediate <= (0 => '0', 10 downto 1 => Instruction(30 downto 21), 
                                        11 => Instruction(20), 19 downto 12 => Instruction(19 downto 12), 
                                        others => Instruction(31));
            when "1100111" => -- JALR
                IDEX_next.Immediate <= (10 downto 0 => Instruction(30 downto 20), 
                                        others => Instruction(31));
            when "1100011" => -- branch instructions
                IDEX_next.Immediate <= (0 => '0', 4 downto 1 => Instruction(11 downto 8), 
                                        10 downto 5 => Instruction(30 downto 25), 11 => Instruction(7),
                                        others => Instruction(31));
            when "0000011" => -- load instructions 
                IDEX_next.Immediate <= (10 downto 0 => Instruction(30 downto 20), 
                                        others => Instruction(31));
            when "0010011" => -- immediate instructions
                if (funct3 = "001" or funct3 = "101") then
                    -- instruction is a shift, shamt has to be extracted
                    IDEX_next.Immediate <= (5 downto 0 => Instruction(25 downto 20), others => '0');
                else
                    -- instruction is a regular immediate instruction
                    IDEX_next.Immediate <= (10 downto 0 => Instruction(30 downto 20), 
                                            others => Instruction(31));
                end if;
            when "0100011" => -- store instructions
                IDEX_next.Immediate <= (4 downto 0 => Instruction(11 downto 7), 
                                        10 downto 5 => Instruction(30 downto 25), others => Instruction(31));
            when "0011011" => -- immediate word instructions
                if (funct3 = "000") then
                    -- instruction is an ADDIW
                    IDEX_next.Immediate <= (10 downto 0 => Instruction(30 downto 20), others => Instruction(31));
                else
                    -- instruction is a shift, shamt has to be extracted
                    IDEX_next.Immediate <= (4 downto 0 => Instruction(24 downto 20), others => '0');
                end if;
            when others => -- register-register instructions
                IDEX_next.Immediate <= (others => '0');
        end case imm;

        -- Hazard detection
        if (IDEX.M.MemRead = '1' and (IDEX.RegisterRd = rs1 or IDEX.RegisterRd = rs2)) then
            PCWrite <= '0';
            IFIDWrite <= '0';
            InsertNOP <= '1';
        else
            PCWrite <= '1';
            IFIDWrite <= '1';
            InsertNOP <= '0';
        end if;

        -- Control generator
        control : case (opcode) is
            when "0110111" => -- LUI
                -- LUI places a sign-extended immediate in the destination register
                IDEX_next.EX.ALUSrcB <= '1';
                IDEX_next.WB.RegWrite <= '1';
            when "0010111" => -- AUIPC
                -- AUIPC adds a large immediate to the PC
                IDEX_next.EX.ALUSrcA <= '1';
                IDEX_next.EX.ALUSrcB <= '1';
                IDEX_next.WB.RegWrite <= '1';
            when "1101111" => -- JAL
                -- JAL performs an unconditional branch
                IDEX_next.EX.ALUSrcA <= '1';
                IDEX_next.EX.ALUSrcB <= '1';
                IDEX_next.EX.Branch <= BR_J;
                IDEX_next.WB.MemtoReg <= WB_PCp4;
                IDEX_next.WB.RegWrite <= '1';
            when "1100111" => -- JALR
                -- JALR performs an unconditional branch
                IDEX_next.EX.ALUSrcB <= '1';
                IDEX_next.EX.Branch <= BR_JR;
                IDEX_next.WB.MemtoReg <= WB_PCp4;
                IDEX_next.WB.RegWrite <= '1';
            when "1100011" => -- branch instructions
                -- Branch instructions require comparison between two register values
                -- (the two register values are taken in between the two operand multiplexors
                -- on each of the ALU's inputs)
                IDEX_next.EX.ALUSrcA <= '1';
                IDEX_next.EX.ALUSrcB <= '1';
                IDEX_next.EX.ALUOp <= ALU_ADD;
                case (funct3) is 
                    when "000" => -- BEQ
                        IDEX_next.EX.Branch <= BR_EQ;
                    when "001" => -- BNE
                        IDEX_next.EX.Branch <= BR_NE;
                    when "100" => -- BLT
                        IDEX_next.EX.Branch <= BR_LT;
                    when "101" => -- BGE
                        IDEX_next.EX.Branch <= BR_GE;
                    when "110" => -- BGEU
                        IDEX_next.EX.Branch <= BR_GEU;
                    when others => -- BLTU
                        IDEX_next.EX.Branch <= BR_LTU;
                end case;
            when "0000011" => -- load instructions 
                -- Loads contain an immediate which is added to a register source
                IDEX_next.EX.ALUSrcB <= '1';
                IDEX_next.EX.ALUOp <= ALU_ADD;
                IDEX_next.M.MemRead <= '1';
                case (funct3) is
                    when "000" => -- LB
                        IDEX_next.M.MemOp <= MEM_LB;
                    when "001" => -- LH
                        IDEX_next.M.MemOp <= MEM_LH;
                    when "010" => -- LW
                        IDEX_next.M.MemOp <= MEM_LW;
                    when "011" => -- LD
                        IDEX_next.M.MemOp <= MEM_LD;
                    when "100" => -- LBU
                        IDEX_next.M.MemOp <= MEM_LBU;
                    when "101" => -- LHU
                        IDEX_next.M.MemOp <= MEM_LHU;
                    when others => -- LWU
                        IDEX_next.M.MemOp <= MEM_LWU;
                end case;
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
                case (funct3) is
                    when "000" => -- SB
                        IDEX_next.M.MemOp <= MEM_SB;
                    when "001" => -- SH
                        IDEX_next.M.MemOp <= MEM_SH;
                    when "010" => -- SW
                        IDEX_next.M.MemOp <= MEM_SW;
                    when others => -- SD
                        IDEX_next.M.MemOp <= MEM_SD;
                end case;
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
        fA : if (EXMEM.WB.RegWrite = '1' and unsigned(EXMEM.RegisterRd) /= 0 
                                         and EXMEM.RegisterRd = IDEX.RegisterRs1) then
            ForwardA <= OP_EXMEM;
        elsif (MEMWB.WB.RegWrite = '1' and unsigned(MEMWB.RegisterRd) /= 0
                                       and MEMWB.RegisterRd = IDEX.RegisterRs1) then
            ForwardA <= OP_MEMWB;
        else
            ForwardA <= OP_IDEX;
        end if;

        fB : if (EXMEM.WB.RegWrite = '1' and unsigned(EXMEM.RegisterRd) /= 0 
                                         and EXMEM.RegisterRd = IDEX.RegisterRs2) then
            ForwardB <= OP_EXMEM;
        elsif (MEMWB.WB.RegWrite = '1' and unsigned(MEMWB.RegisterRd) /= 0
                                       and MEMWB.RegisterRd = IDEX.RegisterRs2) then
            ForwardB <= OP_MEMWB;
        else
            ForwardB <= OP_IDEX;
        end if;

        -- Arithmetic circuit (ALU and its multiplexors)
        -- Choosing the first operand
        case (ForwardA) is
            when OP_IDEX =>
                ALUOperand1m <= IDEX.Data1;
            when OP_EXMEM =>
                ALUOperand1m <= EXMEM.Result;
            when others => -- OP_MEMWB
                ALUOperand1m <= WriteData;
        end case;
        op1 : if (IDEX.EX.ALUSrcA = '0') then
            ALUOperand1 <= ALUOperand1m;
        else
            ALUOperand1 <= (PC_WIDTH-1 downto 0 => IDEX.PC, others => '0');
        end if;
        -- Choosing the second operand (two layers of multiplexors)
        case (ForwardB) is
            when OP_IDEX =>
                ALUOperand2m <= IDEX.Data2;
            when OP_EXMEM =>
                ALUOperand2m <= EXMEM.Result;
            when others => -- OP_MEMWB
                ALUOperand2m <= WriteData;
        end case;
        op2 : if (IDEX.EX.ALUSrcB = '0') then
            ALUOperand2 <= ALUOperand2m;
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
                ALUResult <= std_logic_vector(shift_left(unsigned(ALUOperand1), 
                                              to_integer(unsigned(ALUOperand2(5 downto 0)))));
            when ALU_SRL =>
                ALUResult <= std_logic_vector(shift_right(unsigned(ALUOperand1), 
                                              to_integer(unsigned(ALUOperand2(5 downto 0)))));
            when ALU_SRA =>
                ALUResult <= std_logic_vector(shift_right(signed(ALUOperand1), 
                                              to_integer(unsigned(ALUOperand2(5 downto 0)))));
            when others =>
                -- The second operand is passed through to allow LUI to work more easily
                ALUResult <= ALUOperand2;
        end case alu;
        EXMEM_next.Result <= ALUResult;
        -- Code for the branch detection circuitry
        if (unsigned(ALUOperand1m) = unsigned(ALUOperand2m)) then
            Zero <= '1';
        else
            Zero <= '0';
        end if;
        if (unsigned(ALUOperand1m) < unsigned(ALUOperand2m)) then
            LessThanU <= '1';
        else
            LessThanU <= '0';
        end if;
        if (signed(ALUOperand1m) < signed(ALUOperand2m)) then
            LessThan <= '1';
        else 
            LessThan <= '0';
        end if;
        
        -- Branch logic in the EX stage
        pc_inc <= std_logic_vector(unsigned(pc) + 4);
        IFID_next.PCp4 <= pc_inc;
        br : case (IDEX.EX.Branch) is
            when BR_J =>
                pc_next <= ALUResult(PC_WIDTH-1 downto 0);
            when BR_JR =>
                pc_next <= ALUResult(PC_WIDTH-1 downto 1) & '0';
            when BR_EQ =>
                if (Zero = '1') then
                    pc_next <= ALUResult(PC_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when BR_NE =>
                if (Zero = '0') then
                    pc_next <= ALUResult(PC_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when BR_LT =>
                if (LessThan = '1') then
                    pc_next <= ALUResult(PC_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when BR_GE =>
                if (LessThan = '0') then
                    pc_next <= ALUResult(PC_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when BR_LTU =>
                if (LessThanU = '1') then
                    pc_next <= ALUResult(PC_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when BR_GEU =>
                if (LessThanU = '0') then
                    pc_next <= ALUResult(PC_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when others => -- NOP
                pc_next <= pc_inc;
        end case br;

        -- Determining the data to write back
        wb : case (MEMWB.WB.MemtoReg) is
            when WB_RES =>
                WriteData <= MEMWB.Result;
            when WB_MEM =>
                WriteData <= MemData;
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
                IFID <= IFID_reset;
                IDEX <= IDEX_reset;
                EXMEM <= EXMEM_reset;
                MEMWB <= MEMWB_reset;
            else
                if (PCWrite = '1') then
                    pc <= pc_next;
                else
                    pc <= pc;
                end if;
                if (IFIDWrite = '1') then
                    IFID <= IFID_next;
                else
                    IFID <= IFID;
                end if;
                if (InsertNOP = '1') then
                    IDEX <= IDEX_reset;
                else
                    IDEX <= IDEX_next;
                end if;
                EXMEM <= EXMEM_next;
                MEMWB <= MEMWB_next;
            end if;
        end if;
    end process regs;

end rtl;