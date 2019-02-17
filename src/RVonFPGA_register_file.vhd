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
-- Revision     : 1.0   (last updated February 9, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity register_file is
    generic (
        ADDR_WIDTH : integer := 5
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
    signal regs : register_file_t;
begin
    -- Note that this implementation is synthesized to a large number of flip-flops by Vivado.
    rf : process (all)
    begin
        -- Synchronous writes and resets
        if (rising_edge(clk)) then
            if (RegWrite = '1' and unsigned(RegisterRd) /= 0) then
                -- Write data into the register file
                regs(to_integer(unsigned(RegisterRd))) <= WriteData;
            end if;
        end if;

        -- Asynchronous reads with forwarding around the register file
        if (RegisterRs1 = RegisterRd and RegWrite = '1') then
            -- Forward data around the register file
            if (unsigned(RegisterRs1) /= 0) then
                Data1 <= WriteData;
            else
                Data1 <= (others => '0');
            end if;
        else
            -- Output data from the register file
            Data1 <= regs(to_integer(unsigned(RegisterRs1)));
        end if;
        if (RegisterRs2 = RegisterRd and RegWrite = '1') then
            -- Forward data around the register file
            if (unsigned(RegisterRs2) /= 0) then
                Data2 <= WriteData;
            else
                Data2 <= (others => '0');
            end if;
        else
            -- Output data from the register file
            Data2 <= regs(to_integer(unsigned(RegisterRs2)));
        end if;
    end process rf;
end rtl;