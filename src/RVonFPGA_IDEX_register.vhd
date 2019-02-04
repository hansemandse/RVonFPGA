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
--              : This package contains useful definitions that may be used within other
--              : components. std_logic_vectors are used along with local type conversions
--              : whenever necessary.
--              |
-- Revision     : 1.3   (last updated February 2, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

entity IDEX_register is
    port (
        clk, reset, flush : in std_logic;
        -- Control signal inputs
            -- FILL IN HERE
        -- Data signal inputs
        pc_in : in std_logic_vector(PC_WIDTH-1 downto 0);
        data_1_in, data_2_in : in doubleword;
        imm_in : in doubleword;
        -- Control signal outputs
            -- FILL IN HERE
        -- Data signal outputs
        pc_out : out std_logic_vector(PC_WIDTH-1 downto 0);
        data_1_out, data_2_out : out doubleword;
        imm_out : out doubleword
    );
end IDEX_register;

architecture rtl of IDEX_register is

begin
    process (clk, reset)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                -- FILL IN HERE
            elsif (flush = '1') then
                -- INSERT NOP HERE
            else
                pc_out <= pc_in;
                data_1_out <= data_1_in;
                data_2_out <= data_2_in;
                imm_out <= imm_in;
                -- FILL CONTROL SIGNALS IN HERE
            end if;
        end if;
    end process;
end rtl;