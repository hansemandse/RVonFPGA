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
--              : This entity represents a block-RAM of variable size used in the data memory
--              : and the instruction memory of the pipeline
--              |
-- Revision     : 1.0   (last updated February 10, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bram is
    generic (
        DATA_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 9
    );
    port (
        -- Control ports
        we, reset, clk : in std_logic;
        -- Data ports
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end bram;

architecture rtl of bram is
    constant ARRAY_WIDTH : integer := 2 ** ADDR_WIDTH;
    type ram_t is array(ARRAY_WIDTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    mem : process (all)
        variable ram : ram_t := (others => (others => '0'));
    begin
        if (rising_edge(clk)) then
            if (we = '1') then
                ram(to_integer(unsigned(addr))) := data_in;
            end if;
            if (reset = '1') then
                data_out <= (others => '0');
            else
                data_out <= ram(to_integer(unsigned(addr)));
            end if;
        end if;
    end process mem;
end rtl;