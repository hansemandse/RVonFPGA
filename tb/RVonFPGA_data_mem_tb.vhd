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
--              : This is a testbench for the data memory.
--              |
-- Revision     : 1.0   (last updated February 17, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity data_mem_tb is
end data_mem_tb;

architecture rtl of data_mem_tb is
    -- Clock period in ns
    constant clk_p : time := 10 ns;
    -- Random start address for the system
    constant START_ADDR : std_logic_vector(DATA_ADDR_WIDTH-1 downto 0) 
                                       := (5 downto 0 => '1', others => '0');
    -- Random write data for the memory - taken from 
    -- https://en.wikipedia.org/wiki/Magic_number_(programming)#Magic_debug_values
    constant TEST_DATA : std_logic_vector(DATA_WIDTH-1 downto 0) := x"BADC0FFEE0DDF00D";

    -- Signals for interfacing the memory
    signal MemWrite, MemRead, clk, reset : std_logic := '0';
    signal MemOp : mem_op_t := MEM_NOP;
    signal Address : std_logic_vector(DATA_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal WriteData, ReadData : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
begin
    dut : data_mem 
    port map (
        -- Control ports
        MemWrite => MemWrite,
        MemRead => MemRead,
        clk => clk,
        reset => reset,
        MemOp => MemOp,
        -- Data ports
        Address => Address,
        WriteData => WriteData,
        ReadData => ReadData
    );

    -- Testing all types of memory operations - starting with a large write
    stimuli : process is
        variable ExpectedRes : std_logic_vector(DATA_WIDTH-1 downto 0);
    begin
        reset <= '0';
        -- Save some data in the memory
        MemWrite <= '1';
        MemRead <= '0';
        MemOp <= MEM_SD;
        Address <= START_ADDR;
        WriteData <= TEST_DATA;
        wait until rising_edge(clk);
        -- Testing the LB functionality
        MemWrite <= '0';
        MemRead <= '1';
        MemOp <= MEM_LB;
        lb : for i in 0 to 7 loop
            Address <= std_logic_vector(unsigned(START_ADDR) + to_unsigned(2*i, DATA_ADDR_WIDTH));
            ExpectedRes := (7 downto 0 => TEST_DATA((i+1)*8-1 downto i*8), others => TEST_DATA((i+1)*8-1));
            wait until rising_edge(clk);
            if (ReadData /= ExpectedRes) then
                report "LB test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
            end if;
        end loop lb;
        report "LB test passed!" severity NOTE;
        -- Testing the LBU functionality
        MemOp <= MEM_LBU;
        lbu : for i in 0 to 7 loop
            Address <= std_logic_vector(unsigned(START_ADDR) + to_unsigned(2*i, DATA_ADDR_WIDTH));
            ExpectedRes := (7 downto 0 => TEST_DATA((i+1)*8-1 downto i*8), others => '0');
            wait until rising_edge(clk);
            if (ReadData /= ExpectedRes) then
                report "LBU test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
            end if;
        end loop lbu;
        report "LBU test passed!" severity NOTE;
        -- Testing the LH functionality
        MemOp <= MEM_LH;
        lh : for i in 0 to 3 loop
            Address <= std_logic_vector(unsigned(START_ADDR) + to_unsigned(4*i, DATA_ADDR_WIDTH));
            ExpectedRes := (15 downto 0 => TEST_DATA((i+1)*16-1 downto i*16), others => TEST_DATA((i+1)*16-1));
            wait until rising_edge(clk);
            if (ReadData /= ExpectedRes) then
                report "LH test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
            end if;
        end loop lh;
        report "LH test passed!" severity NOTE;
        -- Testing the LHU functionality
        MemOp <= MEM_LHU;
        lhu : for i in 0 to 3 loop
            Address <= std_logic_vector(unsigned(START_ADDR) + to_unsigned(4*i, DATA_ADDR_WIDTH));
            ExpectedRes := (15 downto 0 => TEST_DATA((i+1)*16-1 downto i*16), others => '0');
            wait until rising_edge(clk);
            if (ReadData /= ExpectedRes) then
                report "LHU test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
            end if;
        end loop lhu;
        report "LHU test passed!" severity NOTE;
        -- Testing the LW functionality
        MemOp <= MEM_LW;
        lw : for i in 0 to 1 loop
            Address <= std_logic_vector(unsigned(START_ADDR) + to_unsigned(8*i, DATA_ADDR_WIDTH));
            ExpectedRes := (31 downto 0 => TEST_DATA((i+1)*32-1 downto i*32), others => TEST_DATA((i+1)*32-1));
            wait until rising_edge(clk);
            if (ReadData /= ExpectedRes) then
                report "LW test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
            end if;
        end loop lw;
        report "LW test passed!" severity NOTE;
        -- Testing the LWU functionality
        MemOp <= MEM_LWU;
        lwu : for i in 0 to 1 loop
            Address <= std_logic_vector(unsigned(START_ADDR) + to_unsigned(8*i, DATA_ADDR_WIDTH));
            ExpectedRes := (31 downto 0 => TEST_DATA((i+1)*32-1 downto i*32), others => '0');
            wait until rising_edge(clk);
            if (ReadData /= ExpectedRes) then
                report "LWU test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
            end if;
        end loop lwu;
        report "LWU test passed!" severity NOTE;
        -- Testing the LD functionality
        MemOp <= MEM_LD;
        Address <= START_ADDR;
        ExpectedRes := TEST_DATA;
        wait until rising_edge(clk);
        if (ReadData /= ExpectedRes) then
            report "LD test failed. Simulation stopped!" severity FAILURE;
        end if;
        report "LD test passed!" severity NOTE;

        std.env.stop(0);
    end process stimuli;

    clock : process is
    begin
        clk <= '1'; wait for clk_p/2;
        clk <= '0'; wait for clk_p/2;
    end process clock;
end architecture;