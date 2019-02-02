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
--              : This entity represents the register file in a classic RISC-V pipeline.
--              : It has two read ports and one write port. It is falling edge triggered,
--              : such that data can be written and used within a single cycle for the
--              : rest of the, rising edge triggered, pipeline design.
--              |
-- Revision     : 1.0   (last updated January 30, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.defs.all;

entity register_file is
    generic (
        ARRAY_WIDTH : integer := 2 ** ADDR_WIDTH
    );
    port (
        -- Control ports
        reg_write, clk, reset : in std_logic;
        -- Read port 1
        read_register_1 : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        read_data_1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        -- Read port 2
        read_register_2 : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        read_data_2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        -- Write port
        write_register : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        write_data : in std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end register_file;

architecture rtl of register_file is
    type register_file_t is array(ARRAY_WIDTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal registers : register_file_t;
begin
    process (clk, reset, reg_write)
    begin
        if (falling_edge(clk)) then
            if (reset = '1') then
                -- Resets only the register pointed to by write_register
                registers(to_integer(unsigned(write_register))) <= (others => '0');
            elsif (reg_write = '1' and to_integer(unsigned(write_register)) /= 0) then
                -- Sets the value of the register pointed to by write_register to write_data
                registers(to_integer(unsigned(write_register))) <= write_data;
            end if;
            -- Outputs the data pointed to by read_register_1 and _2
            read_data_1 <= registers(to_integer(unsigned(read_register_1)));
            read_data_2 <= registers(to_integer(unsigned(read_register_2)));
        end if;
    end process;
end rtl;