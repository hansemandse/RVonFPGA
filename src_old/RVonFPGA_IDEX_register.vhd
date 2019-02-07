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
-- Revision     : 1.4   (last updated February 6, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use work.types.all;

entity IDEX_register is
    port (
        clk, reset : in std_logic;
        -- Control signal inputs
            -- FILL IN HERE
        -- Data signal inputs
        sreg_1_in, sreg_2_in, dreg_in : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        data_1_in, data_2_in : in doubleword;
        imm_in : in doubleword;
        -- Control signal outputs
            -- FILL IN HERE
        -- Data signal outputs
        sreg_1_out, sreg_2_out, dreg_out : out std_logic_vector(ADDR_WIDTH-1 downto 0);
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
            else
                sreg_1_out <= sreg_1_in;
                sreg_2_out <= sreg_2_in;
                dreg_out <= dreg_in;
                data_1_out <= data_1_in;
                data_2_out <= data_2_in;
                imm_out <= imm_in;
                -- FILL CONTROL SIGNALS IN HERE
            end if;
        end if;
    end process;
end rtl;