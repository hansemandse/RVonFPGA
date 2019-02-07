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
--              : It has two read ports and one write port. 
--              |
-- Revision     : 1.0   (last updated February 7, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_file is
    generic (
        ADDR_WIDTH : integer := 5;
        DATA_WIDTH : integer := 64;
        ARRAY_WIDTH : integer := 2 ** ADDR_WIDTH
    );
    port (
        -- Control ports
        RegWrite, clk, reset : in std_logic;
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
end register_file;

architecture rtl of register_file is
    type register_file_t is array(ARRAY_WIDTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal registers : register_file_t;
begin
    -- FILL IN HERE
end rtl;