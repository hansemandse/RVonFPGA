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
--              : This is a testbench for the instruction memory;
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

entity instr_mem_tb is
end instr_mem_tb;

architecture rtl of instr_mem_tb is
    -- Clock period in ns
    constant clk_p : time := 10 ns;

    -- Random start address for the system
    constant SD_ADDR : std_logic_vector(PC_WIDTH-1 downto 0) 
                                       := (PC_WIDTH-1 => '1', others => '0');
    constant SW_ADDR : std_logic_vector(PC_WIDTH-1 downto 0) 
                                       := (1 => '1', PC_WIDTH-1 downto 7 => '1', others => '0');
    constant SB_ADDR : std_logic_vector(PC_WIDTH-1 downto 0) 
                                       := (1 => '1', 8 downto 7 => '1', others => '0');         

    constant TEST_DATA : std_logic_vector(DATA_WIDTH-1 downto 0) := x"0102030405060708";

    -- Signals for interfacing the memory
    signal MemWrite, clk, reset : std_logic := '0';
    signal ImemOp : imem_op_t := MEM_NOP;
    signal Address : std_logic_vector(DATA_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal ReadData : std_logic_vector(31 downto 0);
    signal WriteData : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

    -- Instruction memory component declaration
    component instr_mem is
        generic (
            BLOCK_WIDTH : natural := 8;
            ADDR_WIDTH : natural := PC_WIDTH;
            TEST_FILE : string := "../tests/add.bin"
        );
        port (
            -- Control ports
            MemWrite, clk, reset : in std_logic;
            ImemOp : in imem_op_t;
            -- Data port
            Address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            WriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            ReadData : out std_logic_vector(31 downto 0)
        );
    end component;
begin
    dut : instr_mem
    port map (
        -- Control ports
        MemWrite => MemWrite,
        clk => clk,
        reset => reset,
        ImemOp => ImemOp,
        -- Data ports
        Address => Address,
        ReadData => ReadData,
        WriteData => WriteData
    );

    -- Testing all types of memory operations - starting with a large write
    stimuli : process is
        variable ExpectedRes : std_logic_vector(31 downto 0);
    begin
        wait until falling_edge(clk);
        -- Running through all of the relevant array positions to read all instructions
        for i in 0 to 20 loop
            Address <= std_logic_vector(to_unsigned(i*4, PC_WIDTH));
            wait until falling_edge(clk);
        end loop;

        -- Testing the SD functionality
        MemWrite <= '1';
        ImemOp <= MEM_SD;
        Address <= SD_ADDR;
        WriteData <= TEST_DATA;
        wait until falling_edge(clk);
        MemWrite <= '0';
        ImemOp <= MEM_NOP;
        wait until falling_edge(clk);
        assert ReadData = TEST_DATA(31 downto 0) 
            report "Read data after SD is incorrect" severity FAILURE;
        Address <= std_logic_vector(unsigned(SD_ADDR)+4);
        wait until falling_edge(clk);
        assert ReadData = TEST_DATA(63 downto 32) 
            report "Read data after SD is incorrect" severity FAILURE;
        report "SD test passed!" severity NOTE;

        -- Testing the SW functionality
        MemWrite <= '1';
        ImemOp <= MEM_SW;
        Address <= SW_ADDR;
        wait until falling_edge(clk);
        MemWrite <= '0';
        ImemOp <= MEM_NOP;
        wait until falling_edge(clk);
        assert ReadData = TEST_DATA(31 downto 0) 
            report "Read data after SW is incorrect" severity FAILURE;
        report "SW test passed!" severity NOTE;

        -- Testing the SB functionality
        MemWrite <= '1';
        ImemOp <= MEM_SB;
        Address <= SB_ADDR;
        wait until falling_edge(clk);
        MemWrite <= '0';
        ImemOp <= MEM_NOP;
        wait until falling_edge(clk);
        assert ReadData = x"00000000" & TEST_DATA(7 downto 0) 
            report "Read data after SW is incorrect" severity FAILURE;
        report "SB test passed!" severity NOTE;

        std.env.stop(0);
    end process stimuli;

    clock : process is
    begin
        clk <= '1'; wait for clk_p/2;
        clk <= '0'; wait for clk_p/2;
    end process clock;
end architecture;