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
--              : This entity represents the ALU of the execution stage in the pipeline.
--              |
-- Revision     : 1.1   (last updated February 2, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.types.all;

entity ALU is
    port (
        -- Input operands
        a, b : in std_logic_vector(DATA_WIDTH-1 downto 0);
        alu_op : in alu_op_t;
        -- Outputs
        result : out std_logic_vector(DATA_WIDTH-1 downto 0);
        zero : out std_logic
    );
end ALU;

architecture rtl of ALU is
    signal w_result_int : std_logic_vector(WORD_WIDTH-1 downto 0);
    signal result_int : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    process (alu_op)
    begin
        w_result_int <= (others => '0');
        result_int <= (others => '0');
        case (alu_op) is
            when ALU_AND =>
                result_int <= a and b;
            when ALU_OR =>
                result_int <= a or b;
            when ALU_XOR =>
                result_int <= a xor b;
            when ALU_ADD =>
                result_int <= std_logic_vector(unsigned(a) + unsigned(b));
            when ALU_SUB =>
                result_int <= std_logic_vector(unsigned(a) - unsigned(b));
            when ALU_SLT =>
                if (signed(a) < signed(b)) then
                    result_int <= (0 => '1', others => '0');
                else
                    result_int <= (others => '0');
                end if;
            when ALU_SLTU =>
                if (unsigned(a) < unsigned(b)) then
                    result_int <= (0 => '1', others => '0');
                else
                    result_int <= (others => '0');
                end if;
            when ALU_SLL =>
                result_int <= std_logic_vector(shift_left(unsigned(a), 
                                                          to_integer(unsigned(b(5 downto 0)))));
            when ALU_SRL =>
                result_int <= std_logic_vector(shift_right(unsigned(a), 
                                                           to_integer(unsigned(b(5 downto 0)))));
            when ALU_SRA =>
                result_int <= std_logic_vector(shift_right(signed(a), 
                                                           to_integer(unsigned(b(5 downto 0)))));
            when ALU_ADDW =>
                w_result_int <= std_logic_vector(unsigned(a(31 downto 0)) + unsigned(b(31 downto 0)));
                result_int <= (30 downto 0 => w_result_int(30 downto 0), others => w_result_int(31));
            when ALU_SUBW =>
                w_result_int <= std_logic_vector(unsigned(a(31 downto 0)) - unsigned(b(31 downto 0)));
                result_int <= (30 downto 0 => w_result_int(30 downto 0), others => w_result_int(31));
            when ALU_SLLW =>
                w_result_int <= std_logic_vector(shift_left(unsigned(a(31 downto 0)), 
                                                            to_integer(unsigned(b(4 downto 0)))));
                result_int <= (31 downto 0 => w_result_int, others => '0'); -- CHECK FOR SIGN-EXTENSION
            when ALU_SRLW =>
                w_result_int <= std_logic_vector(shift_right(unsigned(a(31 downto 0)),
                                                            to_integer(unsigned(b(4 downto 0)))));
                result_int <= (31 downto 0 => w_result_int, others => '0'); -- CHECK FOR SIGN-EXTENSION
            when ALU_SRAW =>
                w_result_int <= std_logic_vector(shift_right(signed(a(31 downto 0)),
                                                 to_integer(unsigned(b(4 downto 0)))));
                result_int <= (31 downto 0 => w_result_int, others => '0'); -- CHECK FOR SIGN-EXTENSION
            when others => -- NOP
        end case;
        if (result_int = zero_doubleword) then
            zero <= '1';
        else
            zero <= '0';
        end if;
    end process;
    -- Outputting the result
    result <= result_int;
end rtl;
