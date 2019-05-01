-- This architecture implements a six stage pipeline
architecture rtl3 of pipeline is
    attribute max_fanout : integer;
    -- Declarations for the register control signals
    type alu_op_t is (ALU_AND, ALU_OR, ALU_XOR, ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU,
                      ALU_SLL, ALU_SRL, ALU_SRA, ALU_ADDW, ALU_SUBW, ALU_SLLW, 
                      ALU_SRLW, ALU_SRAW, ALU_NOP);
    type branch_t is (BR_J, BR_JR, BR_EQ, BR_NE, BR_LT, BR_LTU, BR_GE, BR_GEU, BR_NOP);
    type wb_t is (WB_RES, WB_MEM, WB_PCp4);
    type flush_t is (FLUSH_NONE, FLUSH_IDEX, FLUSH_BOTH);

    -- Signals controlling functionality in the WB stage
    type ControlWB_t is record
        RegWrite : std_logic;
        MemtoReg : wb_t;
    end record ControlWB_t;
    constant WB_reset : ControlWB_t := (RegWrite => '0', MemtoReg => WB_RES);

    -- Signals controlling functionality in the MEM stage
    type ControlM_t is record
        MemOp : mem_op_t;
    end record ControlM_t;
    constant M_reset : ControlM_t := (MemOp => MEM_NOP);

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
        IMemOp : mem_op_t;
        PC : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
        PCp4 : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
    end record IFID_t;
    constant IFID_reset : IFID_t := (SkipInstr => '0', IMemOp => MEM_NOP, 
                                     PC => PC_reset, PCp4 => PCp4_reset);

    -- Declarations for the IDEX register
    type IDEX_t is record
        -- Control signals
        WB : ControlWB_t;
        M : ControlM_t;
        EX : ControlEX_t;
        IMemOp : mem_op_t;
        -- Data signals
        PC : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
        PCp4 : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
        Immediate : std_logic_vector(DATA_WIDTH-1 downto 0);
        Data1 : std_logic_vector(DATA_WIDTH-1 downto 0);
        Data2 : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRs1 : std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
        RegisterRs2 : std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
        RegisterRd : std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
    end record IDEX_t;
    constant IDEX_reset : IDEX_t := (WB => WB_reset, M => M_reset, EX => EX_reset,
                                     IMemOp => MEM_NOP, PC => PC_reset, PCp4 => PCp4_reset,
                                     Immediate | Data1 | Data2 | RegisterRs1 | RegisterRs2 | 
                                     RegisterRd => (others => '0'));

    -- Declarations for the IDEX2 register
    type IDEX2_t is record
        -- Control signals
        WB : ControlWB_t;
        M : ControlM_t;
        -- Data signals
        PCp4 : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
        Result : std_logic_vector(DATA_WIDTH-1 downto 0);
        ALUOperand2m : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRd : std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
    end record IDEX2_t;
    constant IDEX2_reset : IDEX2_t := (WB => WB_reset, M => M_reset, PCp4 | Result | 
                                       ALUOperand2m | RegisterRd => (others => '0'));

    -- Declarations for the EXMEM register
    type EXMEM_t is record
        -- Control signals
        WB : ControlWB_t;
        -- Data signals
        PCp4 : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
        Result : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRd : std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
    end record EXMEM_t;
    constant EXMEM_reset : EXMEM_t := (WB => WB_reset, PCp4 => PCp4_reset,
                                       Result | RegisterRd => (others => '0'));

    -- Declarations for the MEMWB register
    type MEMWB_t is record
        -- Control signals
        WB : ControlWB_t;
        -- Data signals
        PCp4 : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
        MemData : std_logic_vector(DATA_WIDTH-1 downto 0);
        Result : std_logic_vector(DATA_WIDTH-1 downto 0);
        RegisterRd : std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
    end record MEMWB_t;
    constant MEMWB_reset : MEMWB_t := (WB => WB_reset, PCp4 => PCp4_reset, 
                                       MemData | Result | RegisterRd => (others => '0'));

    -- Declarations for the PC
    signal pc, pc_next : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
    attribute max_fanout of pc : signal is MAX_FO;

    -- Declarations for the IFID register
    signal IFID, IFID_next : IFID_t;
    attribute max_fanout of IFID : signal is MAX_FO;

    -- Declarations for the IDEX register
    signal IDEX, IDEX_next : IDEX_t;
    attribute max_fanout of IDEX : signal is MAX_FO;

    -- Declarations for the IDEX2 register
    signal IDEX2, IDEX2_next : IDEX2_t;
    attribute max_fanout of IDEX2 : signal is MAX_FO;

    -- Declarations for the EXMEM register
    signal EXMEM, EXMEM_next : EXMEM_t;
    attribute max_fanout of EXMEM : signal is MAX_FO;

    -- Declarations for the MEMWB register
    signal MEMWB, MEMWB_next : MEMWB_t;
    attribute max_fanout of MEMWB : signal is MAX_FO;

    -- Signals for the ID stage
    signal Instruction : std_logic_vector(31 downto 0);
    --attribute DONT_TOUCH : string;
    --attribute DONT_TOUCH of Instruction : signal is "true";
    signal IBuf, IBuf_next : std_logic_vector(31 downto 0);
    signal opcode, funct7 : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal rs1, rs2, rd : std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
    signal Flush : flush_t;

    -- Signals for the EX stage
    signal Zero, LessThanU, LessThan : std_logic;
    signal ALUOperand1, ALUOperand2, ALUResult, ALUOperand1m, ALUOperand2m
                                            : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Signals for the WB stage
    signal WriteData : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Register file component declaration
    component register_file is
        generic (
            ADDR_WIDTH : natural := RF_ADDR_WIDTH
        );
        port (
            -- Control ports
            RegWrite, clk : in std_logic;
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
begin
    -- Signals for the IF stage
    IAddr <= pc;

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

    -- Connecting the data memory ports
    DMemOp <= IDEX2.M.MemOp;
    DAddr <= IDEX2.Result(MEM_ADDR_WIDTH-1 downto 0);
    MEMWB_next.MemData <= DReadData;
    DWriteData <= IDEX2.ALUOperand2m;

    -- Process describing all combinational parts of the circuit
    comb: process (all)
        -- Temporary variable used in the ALU for word operations
        variable temp : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        variable pc_inc, pc_dec : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
    begin
        -- Default assignments for all register-related signals
        pc_next <= pc;
        IFID_next <= IFID;
        -- IDEX cannot be default assigned, because two of its inputs are connected
        -- to the output of the register file
        IDEX2_next <= IDEX2;
        EXMEM_next <= EXMEM;
        -- MEMWB cannot be default assigned, because one of its inputs is connected
        -- to the output of the data memory

        -- Updating values of the IFID register
        IFID_next.SkipInstr <= '0';
        IFID_next.PC <= pc;

        -- Updating values of the IDEX register
        IDEX_next.IMemOp <= IFID.IMemOp;
        IDEX_next.EX.ALUSrcA <= '0';
        IDEX_next.EX.ALUSrcB <= '0';
        IDEX_next.EX.ALUOp <= ALU_NOP;
        IDEX_next.EX.Branch <= BR_NOP;
        IDEX_next.M.MemOp <= MEM_NOP;
        IDEX_next.WB.RegWrite <= '0';
        IDEX_next.WB.MemtoReg <= WB_RES;
        IDEX_next.PC <= IFID.PC;
        IDEX_next.PCp4 <= IFID.PCp4;
        IDEX_next.RegisterRs1 <= rs1;
        IDEX_next.RegisterRs2 <= rs2;
        IDEX_next.RegisterRd <= rd;

        -- Updating values of the IDEX2 register
        IDEX2_next.M <= IDEX.M;
        IDEX2_next.WB <= IDEX.WB;
        IDEX2_next.PCp4 <= IDEX.PCp4; 
        IDEX2_next.RegisterRd <= IDEX.RegisterRd;

        -- Updating values of the EXMEM register
        EXMEM_next.WB <= IDEX2.WB;
        EXMEM_next.PCp4 <= IDEX2.PCp4;
        EXMEM_next.Result <= IDEX2.Result;
        EXMEM_next.RegisterRd <= IDEX2.RegisterRd;

        -- Updating values of the MEMWB register
        MEMWB_next.WB <= EXMEM.WB;
        MEMWB_next.PCp4 <= EXMEM.PCp4;
        MEMWB_next.Result <= EXMEM.Result;
        MEMWB_next.RegisterRd <= EXMEM.RegisterRd;

        -- Instruction fetch-related updates
        IBuf_next <= IReadData(DATA_WIDTH-1 downto DATA_WIDTH/2);
        if (IFID.IMemOp = MEM_LD and IFID.PCp4 = pc) then
            -- Memory just performed a LD operation meaning that two instructions are
            -- available in the pipeline (one to be run straight away, the other to be
            -- buffered in a register)
            IFID_next.IMemOp <= MEM_NOP;
            IMemOp <= MEM_NOP;
        elsif (IFID.PCp4 /= pc and pc(2) = '1') then
            -- Branch has been taken and the instruction fetch address is not 0-aligned
            IFID_next.IMemOp <= MEM_LW;
            IMemOp <= MEM_LW;
        else
            IFID_next.IMemOp <= MEM_LD;
            IMemOp <= MEM_LD;
        end if;
        if (IDEX.IMemOp = MEM_LD and IDEX.PCp4 = IFID.PC and IFID.SkipInstr = '0') then
            -- One cycle ago, a LD was performed; run buffered instruction if pipeline
            -- has not performed branch
            Instruction <= IBuf;
        elsif (IFID.SkipInstr = '1') then
            Instruction <= NOP;
        else
            Instruction <= IReadData(DATA_WIDTH/2-1 downto 0);
        end if;


        -- Immediate generator
        imm : case (opcode) is
            when "0110111" | "0010111" => -- LUI or AUIPC
                IDEX_next.Immediate <= (others => Instruction(31));
                IDEX_next.Immediate(11 downto 0) <= (others => '0');
                IDEX_next.Immediate(30 downto 12) <= Instruction(30 downto 12);
            when "1101111" => -- JAL
                IDEX_next.Immediate <= (others => Instruction(31));
                IDEX_next.Immediate(19 downto 0) <= Instruction(19 downto 12) & Instruction(20) 
                                                  & Instruction(30 downto 21) & '0';
            when "1100111" | "0000011" => -- JALR or load instruction
                IDEX_next.Immediate <= (others => Instruction(31));
                IDEX_next.Immediate(10 downto 0) <= Instruction(30 downto 20);
            when "1100011" => -- branch instructions
                IDEX_next.Immediate <= (others => Instruction(31));
                IDEX_next.Immediate(11 downto 0) <= Instruction(7) & Instruction(30 downto 25) 
                                                  & Instruction(11 downto 8) & '0';
            when "0010011" => -- immediate instructions
                if (funct3 = "001" or funct3 = "101") then
                    -- instruction is a shift; shamt has to be extracted
                    IDEX_next.Immediate <= (others => '0');
                    IDEX_next.Immediate(5 downto 0) <= Instruction(25 downto 20);
                else
                    -- instruction is a regular immediate instruction
                    IDEX_next.Immediate <= (others => Instruction(31));
                    IDEX_next.Immediate(10 downto 0) <= Instruction(30 downto 20);
                end if;
            when "0100011" => -- store instructions
                IDEX_next.Immediate <= (others => Instruction(31));
                IDEX_next.Immediate(10 downto 0) <= Instruction(30 downto 25) & Instruction(11 downto 7);
            when "0011011" => -- immediate word instructions
                if (funct3 = "000") then
                    -- instruction is an ADDIW
                    IDEX_next.Immediate <= (others => Instruction(31));
                    IDEX_next.Immediate(10 downto 0) <= Instruction(30 downto 20);
                else
                    -- instruction is a shift; shamt has to be extracted
                    IDEX_next.Immediate <= (others => '0');
                    IDEX_next.Immediate(4 downto 0) <= Instruction(24 downto 20);
                end if;
            when others => -- register-register instructions
                IDEX_next.Immediate <= (others => '0');
        end case imm;

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
                IDEX_next.EX.ALUOp <= ALU_ADD;
                IDEX_next.WB.RegWrite <= '1';
            when "1101111" => -- JAL
                -- JAL performs an unconditional branch
                IDEX_next.EX.ALUSrcA <= '1';
                IDEX_next.EX.ALUSrcB <= '1';
                IDEX_next.EX.ALUOp <= ALU_ADD;
                IDEX_next.EX.Branch <= BR_J;
                IDEX_next.WB.MemtoReg <= WB_PCp4;
                IDEX_next.WB.RegWrite <= '1';
            when "1100111" => -- JALR
                -- JALR performs an unconditional branch
                IDEX_next.EX.ALUSrcB <= '1';
                IDEX_next.EX.ALUOp <= ALU_ADD;
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
                IDEX_next.EX.ALUSrcB <= '1';
                case (funct3) is
                    when "000" => -- ADDIW
                        IDEX_next.EX.ALUOp <= ALU_ADDW;
                    when "001" => -- SLLIW
                        IDEX_next.EX.ALUOp <= ALU_SLLW;
                    when others => -- SRLIW or SRAIW
                        if (funct7(5) = '1') then
                            IDEX_next.EX.ALUOp <= ALU_SRAW;
                        else
                            IDEX_next.EX.ALUOp <= ALU_SRLW;
                        end if;
                end case;
                IDEX_next.WB.RegWrite <= '1';
            when "0111011" => -- register-register word instructions
                case (funct3) is
                    when "000" => -- ADDW or SUBW
                        if (funct7(5) = '1') then
                            IDEX_next.EX.ALUOp <= ALU_SUBW;
                        else
                            IDEX_next.EX.ALUOp <= ALU_ADDW;
                        end if;
                    when "001" => -- SLLW
                        IDEX_next.EX.ALUOp <= ALU_SLLW;
                    when others => -- SRLW or SRAW
                        if (funct7(5) = '1') then
                            IDEX_next.EX.ALUOp <= ALU_SRAW;
                        else
                            IDEX_next.EX.ALUOp <= ALU_SRLW;
                        end if;
                end case;
                IDEX_next.WB.RegWrite <= '1';
            when "0110011" => -- register-register instructions
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
            when others => -- Do nothing
        end case control;

        -- Forwarding unit
        fA : if (IDEX2.WB.RegWrite = '1' and unsigned(IDEX2.RegisterRd) /= 0
                                         and IDEX2.RegisterRd = IDEX.RegisterRs1) then
            ALUOperand1m <= IDEX2.Result;
        elsif (EXMEM.WB.RegWrite = '1' and unsigned(EXMEM.RegisterRd) /= 0 
                                         and EXMEM.RegisterRd = IDEX.RegisterRs1) then
            ALUOperand1m <= EXMEM.Result;
        elsif (MEMWB.WB.RegWrite = '1' and unsigned(MEMWB.RegisterRd) /= 0
                                       and MEMWB.RegisterRd = IDEX.RegisterRs1) then
            ALUOperand1m <= WriteData;
        else
            ALUOperand1m <= IDEX.Data1;
        end if fA;
        fB : if (IDEX2.WB.RegWrite = '1' and unsigned(IDEX2.RegisterRd) /= 0
                                         and IDEX2.RegisterRd = IDEX.RegisterRs2) then
            ALUOperand2m <= IDEX2.Result;
        elsif (EXMEM.WB.RegWrite = '1' and unsigned(EXMEM.RegisterRd) /= 0 
                                         and EXMEM.RegisterRd = IDEX.RegisterRs2) then
            ALUOperand2m <= EXMEM.Result;
        elsif (MEMWB.WB.RegWrite = '1' and unsigned(MEMWB.RegisterRd) /= 0
                                       and MEMWB.RegisterRd = IDEX.RegisterRs2) then
            ALUOperand2m <= WriteData;
        else
            ALUOperand2m <= IDEX.Data2;
        end if fB;
        IDEX2_next.ALUOperand2m <= ALUOperand2m;

        -- Arithmetic circuit (ALU and its multiplexors)
        -- Choosing the first operand
        if (IDEX.EX.ALUSrcA = '0') then
            ALUOperand1 <= ALUOperand1m;
        else
            ALUOperand1 <= (others => '0');
            ALUOperand1(MEM_ADDR_WIDTH-1 downto 0) <= IDEX.PC;
        end if;
        -- Choosing the second operand
        if (IDEX.EX.ALUSrcB = '0') then
            ALUOperand2 <= ALUOperand2m;
        else
            ALUOperand2 <= IDEX.Immediate;
        end if;
        -- Instantiating the actual ALU which operates on the above two operands
        -- and outputs a result determined by the control circuit in the ID stage
        temp := (others => '0');
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
            when ALU_ADDW =>
                -- Adds together two 32-bit words and sign-extends the 32-bit result to 64 bits
                temp(31 downto 0) := std_logic_vector(signed(ALUOperand1(31 downto 0)) 
                                                    + signed(ALUOperand2(31 downto 0)));
                ALUResult <= (others => temp(31));
                ALUResult(30 downto 0) <= temp(30 downto 0);
            when ALU_SUBW =>
                -- Same as above but with subtraction
                temp(31 downto 0) := std_logic_vector(signed(ALUOperand1(31 downto 0)) 
                                                    - signed(ALUOperand2(31 downto 0)));
                ALUResult <= (others => temp(31));
                ALUResult(30 downto 0) <= temp(30 downto 0);
            when ALU_SLLW =>
                -- Shifts the low 32 bits of the first operand and sign-extends the result
                temp(31 downto 0) := std_logic_vector(shift_left(unsigned(ALUOperand1(31 downto 0)),
                                                      to_integer(unsigned(ALUOperand2(4 downto 0)))));
                ALUResult <= (others => temp(31));
                ALUResult(30 downto 0) <= temp(30 downto 0);
            when ALU_SRLW =>
                temp(31 downto 0) := std_logic_vector(shift_right(unsigned(ALUOperand1(31 downto 0)),
                                                      to_integer(unsigned(ALUOperand2(4 downto 0)))));
                ALUResult <= (others => temp(31));
                ALUResult(30 downto 0) <= temp(30 downto 0);
            when ALU_SRAW =>
                temp(31 downto 0) := std_logic_vector(shift_right(signed(ALUOperand1(31 downto 0)),
                                                      to_integer(unsigned(ALUOperand2(4 downto 0)))));
                ALUResult <= (others => temp(31));
                ALUResult(30 downto 0) <= temp(30 downto 0);
            when others => -- ALU_NOP
                -- The second operand is passed through to allow LUI to work more easily
                ALUResult <= ALUOperand2;
        end case alu;
        IDEX2_next.Result <= ALUResult;
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
        
        -- Branch logic in the EX2 stage
        Flush <= FLUSH_NONE;
        pc_inc := std_logic_vector(unsigned(pc) + 4);
        pc_dec := std_logic_vector(unsigned(pc) - 4);
        IFID_next.PCp4 <= pc_inc;
        br : case (IDEX.EX.Branch) is
            when BR_J =>
                Flush <= FLUSH_IDEX;
                IFID_next.SkipInstr <= '1';
                pc_next <= ALUResult(MEM_ADDR_WIDTH-1 downto 0);
            when BR_JR =>
                Flush <= FLUSH_IDEX;
                IFID_next.SkipInstr <= '1';
                pc_next <= ALUResult(MEM_ADDR_WIDTH-1 downto 1) & '0';
            when BR_EQ =>
                if (Zero = '1') then
                    Flush <= FLUSH_BOTH;
                    IFID_next.SkipInstr <= '1';
                    pc_next <= ALUResult(MEM_ADDR_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when BR_NE =>
                if (Zero = '0') then
                    Flush <= FLUSH_BOTH;
                    IFID_next.SkipInstr <= '1';
                    pc_next <= ALUResult(MEM_ADDR_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when BR_LT =>
                if (LessThan = '1') then
                    Flush <= FLUSH_BOTH;
                    IFID_next.SkipInstr <= '1';
                    pc_next <= ALUResult(MEM_ADDR_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when BR_GE =>
                if (LessThan = '0') then
                    Flush <= FLUSH_BOTH;
                    IFID_next.SkipInstr <= '1';
                    pc_next <= ALUResult(MEM_ADDR_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when BR_LTU =>
                if (LessThanU = '1') then
                    Flush <= FLUSH_BOTH;
                    IFID_next.SkipInstr <= '1';
                    pc_next <= ALUResult(MEM_ADDR_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when BR_GEU =>
                if (LessThanU = '0') then
                    Flush <= FLUSH_BOTH;
                    IFID_next.SkipInstr <= '1';
                    pc_next <= ALUResult(MEM_ADDR_WIDTH-1 downto 0);
                else
                    pc_next <= pc_inc;
                end if;
            when others => -- NOP
                if (pc /= PC_MAX and opcode /= "1110011") then
                    if (is_read_op(IDEX.M.MemOp) and 
                       (IDEX.RegisterRd = rs1 or IDEX.RegisterRd = rs2)) then
                        -- Load-use hazard detected
                        IFID_next.SkipInstr <= '1';
                        Flush <= FLUSH_IDEX;
                        pc_next <= IDEX.PCp4;
                    elsif (is_read_op(IDEX2.M.MemOp) and 
                          (IDEX2.RegisterRd = rs1 or IDEX2.RegisterRd = rs2)) then
                        -- Load-use hazard detected
                        IFID_next.SkipInstr <= '1';
                        Flush <= FLUSH_IDEX;
                        pc_next <= IDEX.PCp4;
                    elsif (IReady = '0') then
                        -- Instruction memory is not ready, wait for a clock cycle
                        pc_next <= pc;
                        IFID_next.SkipInstr <= '1';
                    else
                        pc_next <= pc_inc;
                    end if;
                else
                    -- If an ECALL is in the ID-stage or the last memory address has
                    -- been reached, stop the execution
                    pc_next <= pc;
                end if;
        end case br;

        -- Determining the data to write back
        wb : case (MEMWB.WB.MemtoReg) is
            when WB_RES =>
                WriteData <= MEMWB.Result;
            when WB_MEM =>
                WriteData <= MEMWB.MemData;
            when others => -- WB_PCp4
                WriteData <= (others => '0');
                WriteData(MEM_ADDR_WIDTH-1 downto 0) <= MEMWB.PCp4;
        end case wb;
    end process comb;

    -- Process describing all of the registers in the circuit
    regs: process (all)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                IBuf <= NOP;
                pc <= (others => '0');
                IFID <= IFID_reset;
                IDEX <= IDEX_reset;
                IDEX2 <= IDEX2_reset;
                EXMEM <= EXMEM_reset;
                MEMWB <= MEMWB_reset;
            else
                IBuf <= IBuf_next;
                pc <= pc_next;
                IFID <= IFID_next;
                -- Update instruction buffer
                if (IFID.IMemOp = MEM_LD) then
                    IBuf <= IBuf_next;
                end if;
                -- Zero control signals in case of branch taken
                if (Flush = FLUSH_BOTH) then
                    IDEX <= IDEX_next;
                    IDEX.EX <= EX_reset;
                    IDEX.M <= M_reset;
                    IDEX.WB <= WB_reset;
                    IDEX2 <= IDEX2_next;
                    IDEX2.M <= M_reset;
                    IDEX2.WB <= WB_reset;
                elsif (Flush = FLUSH_IDEX) then
                    IDEX <= IDEX_next;
                    IDEX.EX <= EX_reset;
                    IDEX.M <= M_reset;
                    IDEX.WB <= WB_reset;
                    IDEX2 <= IDEX2_next;
                else
                    IDEX <= IDEX_next;
                    IDEX2 <= IDEX2_next;
                end if;
                EXMEM <= EXMEM_next;
                MEMWB <= MEMWB_next;
            end if;
        end if;
    end process regs;

end rtl3;