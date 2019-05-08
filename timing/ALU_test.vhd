library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity ALU_test is
    port (
        clk, reset : in std_logic;
        result : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end ALU_test;

architecture rtl of ALU_test is
    type alu_op_t is (ALU_AND, ALU_OR, ALU_XOR, ALU_ADD, ALU_SUB, ALU_SLT, ALU_SLTU,
                      ALU_SLL, ALU_SRL, ALU_SRA, ALU_ADDW, ALU_SUBW, ALU_SLLW, 
                      ALU_SRLW, ALU_SRAW, ALU_NOP);
    signal state, state_next : alu_op_t;
    attribute max_fanout : integer;
    attribute max_fanout of state : signal is 100;

    signal ALUResult, ALUOperand1_next, ALUOperand2_next, 
           ALUOperand1, ALUOperand2 : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    result <= ALUResult;

    comb : process (all)
        variable temp : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    begin
        ALUOperand1_next <= ALUOperand1;
        ALUOperand2_next <= ALUOperand2;
        state_next <= state;

        -- Calculating next state
        case (state) is
            when ALU_ADD =>
                ALUOperand1_next <= ALUResult;
                state_next <= ALU_SUB;
            when ALU_SUB =>
                ALUOperand2_next <= ALUResult;
                state_next <= ALU_AND;
            when ALU_AND =>
                ALUOperand1_next <= ALUResult;
                state_next <= ALU_OR;
            when ALU_OR =>
                ALUOperand2_next <= ALUResult;
                state_next <= ALU_XOR;
            when ALU_XOR =>
                ALUOperand1_next <= ALUResult;
                state_next <= ALU_SLT;
            when ALU_SLT =>
                ALUOperand2_next <= ALUResult;
                state_next <= ALU_SLTU;
            when ALU_SLTU =>
                ALUOperand1_next <= ALUResult;
                state_next <= ALU_SLL;
            when ALU_SLL =>
                ALUOperand2_next <= ALUResult;
                state_next <= ALU_SRL;
            when ALU_SRL =>
                ALUOperand1_next <= ALUResult;
                state_next <= ALU_SRA;
            when ALU_SRA =>
                ALUOperand2_next <= ALUResult;
                state_next <= ALU_ADDW;
            when ALU_ADDW =>
                ALUOperand1_next <= ALUResult;
                state_next <= ALU_SUBW;
            when ALU_SUBW =>
                ALUOperand2_next <= ALUResult;
                state_next <= ALU_SLLW;
            when ALU_SLLW =>
                ALUOperand1_next <= ALUResult;
                state_next <= ALU_SRLW;
            when ALU_SRLW =>
                ALUOperand2_next <= ALUResult;
                state_next <= ALU_SRAW;
            when ALU_SRAW =>
                ALUOperand1_next <= ALUResult;
                state_next <= ALU_NOP;
            when others =>
                ALUOperand2_next <= ALUResult;
                state_next <= ALU_ADD;
        end case;

        -- Performing ALU operations
        temp := (others => '0');
        alu : case (state) is
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
    end process comb;

    reg : process (all)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                ALUOperand1 <= (0 => '1', others => '0');
                ALUOperand2 <= (1 => '1', others => '0');
                state <= ALU_ADD;
            else
                ALUOperand1 <= ALUOperand1_next;
                ALUOperand2 <= ALUOperand2_next;
                state <= state_next;
            end if;
        end if;
    end process reg;
end rtl;