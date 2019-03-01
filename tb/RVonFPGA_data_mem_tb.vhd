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
-- Revision     : 1.0   (last updated February 22, 2019)
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
    constant SD_ADDR : std_logic_vector(DATA_ADDR_WIDTH-1 downto 0) 
                                       := (5 downto 0 => '1', others => '0');
    constant SW_ADDR : std_logic_vector(DATA_ADDR_WIDTH-1 downto 0)
                                       := (11 downto 7 => '1', others => '0');
    constant SH_ADDR : std_logic_vector(DATA_ADDR_WIDTH-1 downto 0)
                                       := (8 downto 9 => '1', others => '0');
    constant SB_ADDR : std_logic_vector(DATA_ADDR_WIDTH-1 downto 0)
                                       := (5 downto 3 => '0', others => '1');
    -- Random write data for the memory - taken from 
    -- https://en.wikipedia.org/wiki/Magic_number_(programming)#Magic_debug_values
    -- resembles the phrase "Bad coffee, odd food"
    constant TEST_DATA : std_logic_vector(DATA_WIDTH-1 downto 0) := x"8ADC0FFEE0DDF00D";

    -- Signals for interfacing the memory
    signal MemWrite, MemRead, clk, reset : std_logic := '0';
    signal MemOp : mem_op_t := MEM_NOP;
    signal Address : std_logic_vector(DATA_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal WriteData, ReadData : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

    -- Data memory component declaration
    component data_mem is
        generic (
            BLOCK_WIDTH : natural := 8;
            ADDR_WIDTH : natural := DATA_ADDR_WIDTH
        );
        port (
            -- Control ports
            MemRead, MemWrite, clk, reset : in std_logic;
            MemOp : in mem_op_t;
            -- Data ports
            Address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            WriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            ReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
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
        wait until falling_edge(clk);
        reset <= '0';
        -- Save some data in the memory
        MemWrite <= '1';
        MemRead <= '0';
        MemOp <= MEM_SD;
        Address <= SD_ADDR;
        WriteData <= TEST_DATA;
        wait until falling_edge(clk);
        report "Testing SD functionality" severity NOTE;
        -- Testing the LB functionality
        MemWrite <= '0';
        MemRead <= '1';
        MemOp <= MEM_LB;
        sd_lb : for i in 0 to 7 loop
            Address <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*8-1));
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LB test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sd_lb;
        report "LB test passed!" severity NOTE;
        -- Testing the LBU functionality
        MemOp <= MEM_LBU;
        sd_lbu : for i in 0 to 7 loop
            Address <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LBU test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sd_lbu;
        report "LBU test passed!" severity NOTE;
        -- Testing the LH functionality
        MemOp <= MEM_LH;
        sd_lh : for i in 0 to 3 loop
            Address <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(2*i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*16-1));
            ExpectedRes(15 downto 0) := TEST_DATA((i+1)*16-1 downto i*16);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LH test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sd_lh;
        report "LH test passed!" severity NOTE;
        -- Testing the LHU functionality
        MemOp <= MEM_LHU;
        sd_lhu : for i in 0 to 3 loop
            Address <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(2*i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(15 downto 0) := TEST_DATA((i+1)*16-1 downto i*16);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LHU test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sd_lhu;
        report "LHU test passed!" severity NOTE;
        -- Testing the LW functionality
        MemOp <= MEM_LW;
        sd_lw : for i in 0 to 1 loop
            Address <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(4*i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*32-1));
            ExpectedRes(31 downto 0) := TEST_DATA((i+1)*32-1 downto i*32);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LW test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sd_lw;
        report "LW test passed!" severity NOTE;
        -- Testing the LWU functionality
        MemOp <= MEM_LWU;
        sd_lwu : for i in 0 to 1 loop
            Address <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(4*i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(31 downto 0) := TEST_DATA((i+1)*32-1 downto i*32);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LWU test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sd_lwu;
        report "LWU test passed!" severity NOTE;
        -- Testing the LD functionality
        MemOp <= MEM_LD;
        Address <= SD_ADDR;
        ExpectedRes := TEST_DATA;
        wait until falling_edge(clk);
        assert ReadData = ExpectedRes report "LD test failed. Simulation stopped!" severity FAILURE;
        report "LD test passed!" severity NOTE;

        -- Testing instead a SW instruction
        MemWrite <= '1';
        MemRead <= '0';
        MemOp <= MEM_SW;
        Address <= SW_ADDR;
        wait until falling_edge(clk);
        report "Testing SW functionality" severity NOTE;
        -- Testing the LB functionality
        MemWrite <= '0';
        MemRead <= '1';
        MemOp <= MEM_LB;
        sw_lb : for i in 0 to 3 loop
            Address <= std_logic_vector(unsigned(SW_ADDR) + to_unsigned(i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*8-1));
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LB test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sw_lb;
        report "LB test passed!" severity NOTE;
        -- Testing the LBU functionality
        MemOp <= MEM_LBU;
        sw_lbu : for i in 0 to 3 loop
            Address <= std_logic_vector(unsigned(SW_ADDR) + to_unsigned(i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LBU test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sw_lbu;
        report "LBU test passed!" severity NOTE;
        -- Testing the LH functionality
        MemOp <= MEM_LH;
        sw_lh : for i in 0 to 1 loop
            Address <= std_logic_vector(unsigned(SW_ADDR) + to_unsigned(2*i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*16-1));
            ExpectedRes(15 downto 0) := TEST_DATA((i+1)*16-1 downto i*16);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LH test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sw_lh;
        report "LH test passed!" severity NOTE;
        -- Testing the LHU functionality
        MemOp <= MEM_LHU;
        sw_lhu : for i in 0 to 1 loop
            Address <= std_logic_vector(unsigned(SW_ADDR) + to_unsigned(2*i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(15 downto 0) := TEST_DATA((i+1)*16-1 downto i*16);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LHU test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sw_lhu;
        report "LHU test passed!" severity NOTE;
        -- Testing the LW functionality
        MemOp <= MEM_LW;
        Address <= SW_ADDR;
        ExpectedRes := (others => TEST_DATA(31));
        ExpectedRes(31 downto 0) := TEST_DATA(31 downto 0);
        wait until falling_edge(clk);
        assert ReadData = ExpectedRes report "LW test failed. Simulation stopped!" severity FAILURE;
        report "LW test passed!" severity NOTE;
        -- Testing the LWU functionality
        MemOp <= MEM_LWU;
        Address <= SW_ADDR;
        ExpectedRes := (others => '0');
        ExpectedRes(31 downto 0) := TEST_DATA(31 downto 0);
        wait until falling_edge(clk);
        assert ReadData = ExpectedRes report "LWU test failed. Simulation stopped!" severity FAILURE;
        report "LW test passed!" severity NOTE;

        -- Testing instead a SH instruction
        MemWrite <= '1';
        MemRead <= '0';
        MemOp <= MEM_SH;
        Address <= SH_ADDR;
        wait until falling_edge(clk);
        report "Testing SH functionality" severity NOTE;
        -- Testing the LB functionality
        MemWrite <= '0';
        MemRead <= '1';
        MemOp <= MEM_LB;
        sh_lb : for i in 0 to 1 loop
            Address <= std_logic_vector(unsigned(SH_ADDR) + to_unsigned(i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*8-1));
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LB test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sh_lb;
        report "LB test passed!" severity NOTE;
        -- Testing the LBU functionality
        MemOp <= MEM_LBU;
        sh_lbu : for i in 0 to 1 loop
            Address <= std_logic_vector(unsigned(SH_ADDR) + to_unsigned(i, DATA_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert ReadData = ExpectedRes report "LBU test " & integer'image(i) & " failed. Simulation stopped!" severity FAILURE;
        end loop sh_lbu;
        report "LBU test passed!" severity NOTE;
        -- Testing the LH functionality
        MemOp <= MEM_LH;
        Address <= SH_ADDR;
        ExpectedRes := (others => TEST_DATA(15));
        ExpectedRes(15 downto 0) := TEST_DATA(15 downto 0);
        wait until falling_edge(clk);
        assert ReadData = ExpectedRes report "LH test failed. Simulation stopped!" severity FAILURE;
        report "LH test passed!" severity NOTE;
        -- Testing the LHU functionality
        MemOp <= MEM_LHU;
        Address <= SH_ADDR;
        ExpectedRes := (others => '0');
        ExpectedRes(15 downto 0) := TEST_DATA(15 downto 0);
        wait until falling_edge(clk);
        assert ReadData = ExpectedRes report "LHU test failed. Simulation stopped!" severity FAILURE;
        report "LHU test passed!" severity NOTE;

        -- Testing instead a SB instruction
        MemWrite <= '1';
        MemRead <= '0';
        MemOp <= MEM_SB;
        Address <= SB_ADDR;
        wait until falling_edge(clk);
        report "Testing SB functionality" severity NOTE;
        -- Testing the LB functionality
        MemWrite <= '0';
        MemRead <= '1';
        MemOp <= MEM_LB;
        ExpectedRes := (others => TEST_DATA(7));
        ExpectedRes(7 downto 0) := TEST_DATA(7 downto 0);
        wait until falling_edge(clk);
        assert ReadData = ExpectedRes report "LB test failed. Simulation stopped!" severity FAILURE;
        report "LB test passed!" severity NOTE;
        -- Testing the LBU functionality
        MemOp <= MEM_LBU;
        ExpectedRes := (others => '0');
        ExpectedRes(7 downto 0) := TEST_DATA(7 downto 0);
        wait until falling_edge(clk);
        assert ReadData = ExpectedRes report "LBU test failed. Simulation stopped!" severity FAILURE;
        report "LBU test passed!" severity NOTE;

        std.env.stop(0);
    end process stimuli;

    clock : process is
    begin
        clk <= '1'; wait for clk_p/2;
        clk <= '0'; wait for clk_p/2;
    end process clock;
end architecture;