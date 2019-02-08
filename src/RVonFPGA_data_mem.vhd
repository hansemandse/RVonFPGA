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
--              : This entity represents the data memory of the pipeline.
--              |
-- Revision     : 1.0   (last updated February 8, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity data_mem is
    generic (
        DATA_WIDTH : integer := 64;
        NB_COL : integer := DATA_WIDTH / 8;
        ADDR_WIDTH : integer := 12;
        ARRAY_WIDTH : integer := 2 ** ADDR_WIDTH
    );
    port (
        -- Control ports
        MemRead, MemWrite, clk, reset : in std_logic;
        -- Data ports
        Address : in std_logic_vector(DATA_WIDTH-1 downto 0);
        WriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
        ReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end data_mem;

architecture rtl of data_mem is
    type ram_t is array(ARRAY_WIDTH-1 downto 0) of std_logic_vector(7 downto 0);
    shared variable ram : ram_t;
    signal enable : std_logic;
    signal DataOut : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    enable <= MemRead or MemWrite;

    -- For future purposes, this signal will be needed to implement reading out
    -- differently sized data (bytes, halfwords, words and doublewords)
    ReadData <= DataOut;

    ram : process (all)
    begin
        if (rising_edge(clk)) then
            if (enable = '1') then
                -- Write the given doubleword into memory
                if (MemWrite = '1') then
                    write : for i in 0 to NB_COL-1 loop
                        
                    end loop write;
                end if;

                -- Read a doubleword out of memory
                if (MemRead = '1') then
                    read : for i in 0 to NB_COL-1 loop
                        
                    end loop read;
                end if;
            end if;
        end if;
    end process ram;
end rtl;