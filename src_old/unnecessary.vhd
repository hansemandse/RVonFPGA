type instr_t is (LUI, AUIPC, JAL, JALR, BEQ, BNE, BLT, BGE, BLTU, BGEU, LB, LH, LW,
                     LBU, LHU, SB, SH, SW, ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI,
                     SRAI, ADD, SUB, SLL_T, SLT, SLTU, XOR_T, SRL_T, SRA_T, OR_T, AND_T,
                     FENCE, FENCE_I, ECALL, EBREAK, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, 
                     CSRRCI, LWU, LD, SD, SLLI, SRLI, SRAI, ADDIW, SLLIW, SRLIW, SRAIW, 
                     ADDW, SUBW, SLLW, SRAW);


instr_type : out instr_t -- Instruction type (either LUI, AUIPC, JAL ...)

-- Instruction decoding and immediate generation
process (instr_in)
begin
    -- Default assignments to avoid inferred latches
    l_type <= R_t; shamt <= (others => '0'); instr_type <= ADDI;
    case (opcode) is
        when "0110111" => -- LUI
            instr_type <= LUI;
            l_type <= U_t;
        when "0010111" => -- AUIPC
            instr_type <= AUIPC;
            l_type <= U_t;
        when "1101111" => -- JAL
            instr_type <= JAL;
            l_type <= J_t;
        when "1100111" => -- JALR
            instr_type <= JALR;
            l_type <= I_t;
        when "1100011" => -- BEQ, BNE, BLT, BGE, BLTU and BGEU
            case (funct3) is
                when "000" => -- BEQ
                    instr_type <= BEQ;
                when "001" => -- BNE
                    instr_type <= BNE;
                when "100" => -- BLT
                    instr_type <= BLT;
                when "101" => -- BGE
                    instr_type <= BGE;
                when "110" => -- BLTU
                    instr_type <= BLTU;
                when others => -- BGEU
                    instr_type <= BGEU;
            end case;
            l_type <= B_t;
        when "0000011" => -- LB, LH, LW, LD, LBU, LHU and LWU
            case (funct3) is
                when "000" => -- LB
                    instr_type <= LB;
                when "001" => -- LH
                    instr_type <= LH;
                when "010" => -- LW
                    instr_type <= LW;
                when "011" => -- LD
                    instr_type <= LD;
                when "100" => -- LBU
                    instr_type <= LBU;
                when "101" => -- LHU
                    instr_type <= LHU;
                when others => -- LWU
                    instr_type <= LWU;
            end case;
            l_type <= I_t;
        when "0100011" => -- SB, SH, SW and SD
            case (funct3) is
                when "000" => -- SB
                    instr_type <= SB;
                when "001" => -- SH
                    instr_type <= SH;
                when "010" => -- SW
                    instr_type <= SW;
                when others => -- SD
                    instr_type <= SD;
            end case;
            l_type <= S_t;
        when "0010011" => -- ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI and SRAI
            case (funct3) is
                when "000" => -- ADDI
                    instr_type <= ADDI;
                when "001" => -- SLLI
                    instr_type <= SLLI;
                when "010" => -- SLTI
                    instr_type <= SLTI;
                when "011" => -- SLTIU
                    instr_type <= SLTIU;
                when "100" => -- XORI
                    instr_type <= XORI;
                when "101" => -- SRLI or SRAI
                    if (instr_in(30) = '1') then
                        instr_type <= SRAI;
                    else 
                        instr_type <= SRLI;
                    end if;
                when "110" => -- ORI
                    instr_type <= ORI;
                when others => -- ANDI
                    instr_type <= ANDI;
            end case;
            -- The value of shamt
            shamt <= instr_in(25 downto 20);
            -- SLLI, SRLI and SRAI make use of a shamt value rather than an immediate
            l_type <= I_t;
        when "0110011" => -- ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR and AND
            case (funct3) is
                when "000" => -- ADD or SUB
                    if (instr_in(30) = '1') then
                        instr_type <= SUB;
                    else
                        instr_type <= ADD;
                    end if;
                when "001" => -- SLL
                    instr_type <= SLL_T;
                when "010" => -- SLT
                    instr_type <= SLT;
                when "011" => -- SLTU
                    instr_type <= SLTU;
                when "100" => -- XOR
                    instr_type <= XOR_T;
                when "101" => -- SRL or SRA
                    if (instr_in(30) = '1') then
                        instr_type <= SRA_T;
                    else
                        instr_type <= SRL_T;
                    end if;
                when "110" => -- OR
                    instr_type <= OR_T;
                when others => -- AND
                    instr_type <= AND_T;
            end case;
            -- Letter type is per default R_t, zero immediate will be assigned
        when "0001111" => -- FENCE and FENCE_I
            case (funct3) is
                when "000" =>
                    instr_type <= FENCE;
                when others => 
                    instr_type <= FENCE_I;
            end case;
            -- These two have no letter type, assigning to R_t means zero immediate
        when "1110011" => -- ECALL, EBREAK, CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI and CSRRCI
            -- These two have no letter type, assigning to R_t means zero immediate
        when "0011011" => -- ADDIW, SLLIW, SRLIW and SRAIW
            case (funct3) is
                when "000" => -- ADDIW
                    instr_type <= ADDIW;
                when "001" => -- SLLIW
                    instr_type <= SLLIW;
                when others => -- SRLIW or SRAIW
                    if (instr_in(30) = '1') then
                        instr_type <= SRAIW;
                    else
                        instr_type <= SRLIW;
                    end if;
            end case;
            -- The value of shamt
            shamt <= '0' & instr_in(24 downto 20);
            -- ADDIW is I-type, the other three hold a shamt value instead
            l_type <= I_t;
        when others => -- ADDW, SUBW, SLLW, SRLW and SRAW
            case (funct3) is
                when "000" => -- ADDW or SUBW
                    instr_type <= ADDW;
                when "001" => -- SLLW
                    instr_type <= SLLW;
                when others => -- SRLW or SRAW
                    if (instr_in(30) = '1') then
                        instr_type <= SRAW;
                    else
                        instr_type <= SRLW;
                    end if;
            end case;
            -- Letter type is per default R_t, zero immediate will be assigned
    end case;

    -- Immediate generation
    case (l_type) is
        when J_t =>
            -- J-type instructions have a very split up immediate
            immediate <= (others => instr_in(31)) & instr_in(31) & instr_in(19 downto 12)
                         & instr_in(20) & instr_in(30 downto 21) & '0';
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