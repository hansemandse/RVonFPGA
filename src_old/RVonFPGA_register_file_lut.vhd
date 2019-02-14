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
--              : This entity represents the register file in a classic RISC-V pipeline.
--              : It has two read ports and one write port. 
--              |
-- Revision     : 1.0   (last updated February 14, 2019)
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
        DATA_WIDTH : integer := 64
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
end register_file;

architecture rtl of register_file is
    constant ARRAY_WIDTH : integer := 2 ** ADDR_WIDTH;
    type register_file_t is array(ARRAY_WIDTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    -- The following lines of code should force Vivado to implement this as distributed
    -- RAM. However, Vivado claims that the memory is too sparse and therefore, they
    -- are simply mapped to actual registers.
    --attribute ram_style : string;
    --attribute ram_style of regs : signal is "distributed";
begin
    -- Note that this implementation is synthesized to LUT-RAM by Vivado. 
    ram1 : process (all)
        variable regs : register_file_t := (others => (others => '0'));
    begin
        -- Synchronous writes
        if (rising_edge(clk)) then
            if (RegWrite = '1' and unsigned(RegisterRd) /= 0) then
                regs(to_integer(unsigned(RegisterRd))) := WriteData;
            end if;
        end if;
        -- Asynchronous reads
        if (RegisterRs1 = RegisterRd and RegWrite = '1') then
            if (unsigned(RegisterRd) /= 0) then
                Data1 <= WriteData;
            else
                Data1 <= (others => '0');
            end if;
        else
            Data1 <= regs(to_integer(unsigned(RegisterRs2)));
        end if;
    end process ram1;

    ram2 : process (all)
        variable regs : register_file_t := (others => (others => '0'));
    begin
        -- Synchronous writes
        if (rising_edge(clk)) then
            if (RegWrite = '1' and unsigned(RegisterRd) /= 0) then
                regs(to_integer(unsigned(RegisterRd))) := WriteData;
            end if;
        end if;
        -- Asynchronous reads
        if (RegisterRs2 = RegisterRd and RegWrite = '1') then
            if (unsigned(RegisterRd) /= 0) then
                Data2 <= WriteData;
            else
                Data2 <= (others => '0');
            end if;
        else
            Data2 <= regs(to_integer(unsigned(RegisterRs2)));
        end if;
    end process ram2;
end rtl;