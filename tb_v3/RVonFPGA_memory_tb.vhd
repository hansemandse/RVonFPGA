-- ***********************************************************************
--              |
-- Title        : Implementation and Optimization of a RISC-V Processor on
--              : a FPGA
--              |
-- Developers   : Hans Jakob Damsgaard, Technical University of Denmark
--              : s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
--              |
-- Purpose      : This file is a part of a full system implemented as part
--              : of a bachelor's thesis at DTU. The thesis is written in
--              : cooperation with the Institute of Mathematics and
--              : Computer Science.
--              : This is a testbench for the memory.
--              |
-- Revision     : 1.1   (last updated June 6, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- ***********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity memory_tb is
end memory_tb;

architecture rtl of memory_tb is
    -- Clock period in ns
    constant clk_p : time := 10 ns;
    -- Random start address for the system
    constant SD_ADDR : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0) 
                                       := (8 => '1', others => '0');
    constant SW_ADDR : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0)
                                       := (9 => '1', others => '0');
    constant SH_ADDR : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0)
                                       := (9 downto 8 => '1', others => '0');
    constant SB_ADDR : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0)
                                       := (8 downto 5 => '0', others => '1');
    -- Random write data for the memory - taken from 
    -- https://en.wikipedia.org/wiki/Magic_number_(programming)#Magic_debug_values
    -- resembles the phrase "Bad coffee, odd food"
    constant TEST_DATA : std_logic_vector(DATA_WIDTH-1 downto 0) := x"8ADC0FFEE0DDF00D";

    -- Signals for interfacing the memory
    signal clk, reset, IReady, DReady : std_logic;
    signal IMemOp, DMemOp : mem_op_t := MEM_NOP;
    signal IAddr, DAddr : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal IReadData : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal DWriteData, DReadData : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Register file component declaration
    component memory is
        generic (
            BLOCK_WIDTH : natural := BYTE_WIDTH;
            ADDR_WIDTH : natural := MEM_ADDR_WIDTH
        );
        port (
            clk, reset : in std_logic;
            -- Instruction memory interface
            IMemOp : in mem_op_t; -- Includes a simple enable and write-enable structure
            IReady : out std_logic;
            IAddr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            IWriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            IReadData : out std_logic_vector(DATA_WIDTH-1 downto 0);
            -- Data memory interface
            DMemOp : in mem_op_t;
            DReady : out std_logic;
            DAddr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            DWriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            DReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
begin
    dut : memory
    port map (
        clk => clk,
        reset => reset,
        IMemOp => IMemOp,
        IReady => IReady,
        IAddr => IAddr,
        IWriteData => (others => '0'),
        IReadData => IReadData,
        DMemOp => DMemOp,
        DReady => DReady,
        DAddr => DAddr,
        DWriteData => DWriteData,
        DReadData => DReadData
    );

    -- Testing all types of memory operations - starting with a large write
    stimuli : process is
        variable ExpectedRes : std_logic_vector(DATA_WIDTH-1 downto 0);
    begin
        wait until falling_edge(clk);
        DWriteData <= (others => '0');
        reset <= '0';
        IMemOp <= MEM_LW;
        wait until falling_edge(clk);

        -- Testing the instruction memory port
        assert IReadData = x"0000_0000_0009_2537" 
            report "IReadData is incorrect" 
            severity FAILURE;

        -- Storing some data in the memory
        DAddr <= SD_ADDR;
        DMemOp <= MEM_SD;
        DWriteData <= TEST_DATA;
        wait until falling_edge(clk);
        
        -- Testing a SD instruction        
        report "Testing SD functionality" severity NOTE;
        -- Testing the LB functionality
        DMemOp <= MEM_LB;
        sd_lb : for i in 0 to 7 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!"
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*8-1));
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LB test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;
        end loop sd_lb;
        report "LB test passed!" severity NOTE;
        -- Testing the LBU functionality
        DMemOp <= MEM_LBU;
        sd_lbu : for i in 0 to 7 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!"
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LBU test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;
        end loop sd_lbu;
        report "LBU test passed!" severity NOTE;
        -- Testing the LH functionality
        DMemOp <= MEM_LH;
        sd_lh : for i in 0 to 3 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!"
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(2*i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*16-1));
            ExpectedRes(15 downto 0) := TEST_DATA((i+1)*16-1 downto i*16);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LH test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;
        end loop sd_lh;
        report "LH test passed!" severity NOTE;
        -- Testing the LHU functionality
        DMemOp <= MEM_LHU;
        sd_lhu : for i in 0 to 3 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!"
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(2*i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(15 downto 0) := TEST_DATA((i+1)*16-1 downto i*16);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LHU test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;
        end loop sd_lhu;
        report "LHU test passed!" severity NOTE;
        -- Testing the LW functionality
        DMemOp <= MEM_LW;
        sd_lw : for i in 0 to 1 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!"
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(4*i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*32-1));
            ExpectedRes(31 downto 0) := TEST_DATA((i+1)*32-1 downto i*32);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LW test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;
        end loop sd_lw;
        report "LW test passed!" severity NOTE;
        -- Testing the LWU functionality
        DMemOp <= MEM_LWU;
        sd_lwu : for i in 0 to 1 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!"
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SD_ADDR) + to_unsigned(4*i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(31 downto 0) := TEST_DATA((i+1)*32-1 downto i*32);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LWU test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;
        end loop sd_lwu;
        report "LWU test passed!" severity NOTE;
        -- Testing the LD functionality
        DMemOp <= MEM_LD;
        assert IReady = '0' 
            report "Instruction memory ready incorrect. Simulation stopped!"
            severity FAILURE;
        DAddr <= SD_ADDR;
        ExpectedRes := TEST_DATA;
        wait until falling_edge(clk);
        assert DReadData = ExpectedRes 
            report "Data - LD test failed. Simulation stopped!" 
            severity FAILURE;
        report "LD test passed!" severity NOTE;

        -- Testing instead a SW instruction
        DMemOp <= MEM_SW;
        DAddr <= SW_ADDR;
        wait until falling_edge(clk);
        report "Testing SW functionality" severity NOTE;
        -- Testing the LB functionality
        DMemOp <= MEM_LB;
        sw_lb : for i in 0 to 3 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!" 
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SW_ADDR) + to_unsigned(i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*8-1));
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LB test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;        
        end loop sw_lb;
        report "LB test passed!" severity NOTE;
        -- Testing the LBU functionality
        DMemOp <= MEM_LBU;
        sw_lbu : for i in 0 to 3 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!"
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SW_ADDR) + to_unsigned(i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LBU test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;
        end loop sw_lbu;
        report "LBU test passed!" severity NOTE;
        -- Testing the LH functionality
        DMemOp <= MEM_LH;
        sw_lh : for i in 0 to 1 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!"
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SW_ADDR) + to_unsigned(2*i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*16-1));
            ExpectedRes(15 downto 0) := TEST_DATA((i+1)*16-1 downto i*16);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LH test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;
        end loop sw_lh;
        report "LH test passed!" severity NOTE;
        -- Testing the LHU functionality
        DMemOp <= MEM_LHU;
        sw_lhu : for i in 0 to 1 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!"
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SW_ADDR) + to_unsigned(2*i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(15 downto 0) := TEST_DATA((i+1)*16-1 downto i*16);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LHU test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;
        end loop sw_lhu;
        report "LHU test passed!" severity NOTE;
        -- Testing the LW functionality
        DMemOp <= MEM_LW;
        assert IReady = '0' 
            report "Instruction memory ready incorrect. Simulation stopped!"
            severity FAILURE;
        DAddr <= SW_ADDR;
        ExpectedRes := (others => TEST_DATA(31));
        ExpectedRes(31 downto 0) := TEST_DATA(31 downto 0);
        wait until falling_edge(clk);
        assert DReadData = ExpectedRes 
            report "Data - LW test failed. Simulation stopped!" 
            severity FAILURE;
        report "LW test passed!" severity NOTE;
        -- Testing the LWU functionality
        DMemOp <= MEM_LWU;
        assert IReady = '0' 
            report "Instruction memory ready incorrect. Simulation stopped!" 
            severity FAILURE;
        DAddr <= SW_ADDR;
        ExpectedRes := (others => '0');
        ExpectedRes(31 downto 0) := TEST_DATA(31 downto 0);
        wait until falling_edge(clk);
        assert DReadData = ExpectedRes 
            report "Data - LWU test failed. Simulation stopped!" 
            severity FAILURE;
        report "LWU test passed!" severity NOTE;

        -- Testing instead a SH instruction
        DMemOp <= MEM_SH;
        DAddr <= SH_ADDR;
        wait until falling_edge(clk);
        report "Testing SH functionality" severity NOTE;
        -- Testing the LB functionality
        DMemOp <= MEM_LB;
        sh_lb : for i in 0 to 1 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!" 
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SH_ADDR) + to_unsigned(i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => TEST_DATA((i+1)*8-1));
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LB test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;
        end loop sh_lb;
        report "LB test passed!" severity NOTE;
        -- Testing the LBU functionality
        DMemOp <= MEM_LBU;
        sh_lbu : for i in 0 to 1 loop
            assert IReady = '0' 
                report "Instruction memory ready incorrect. Simulation stopped!"
                severity FAILURE;
            DAddr <= std_logic_vector(unsigned(SH_ADDR) + to_unsigned(i, MEM_ADDR_WIDTH));
            ExpectedRes := (others => '0');
            ExpectedRes(7 downto 0) := TEST_DATA((i+1)*8-1 downto i*8);
            wait until falling_edge(clk);
            assert DReadData = ExpectedRes 
                report "Data - LBU test " & integer'image(i) & " failed. Simulation stopped!"
                severity FAILURE;
        end loop sh_lbu;
        report "LBU test passed!" severity NOTE;
        -- Testing the LH functionality
        DMemOp <= MEM_LH;
        assert IReady = '0' 
            report "Instruction memory ready incorrect. Simulation stopped!"
            severity FAILURE;
        DAddr <= SH_ADDR;
        ExpectedRes := (others => TEST_DATA(15));
        ExpectedRes(15 downto 0) := TEST_DATA(15 downto 0);
        wait until falling_edge(clk);
        assert DReadData = ExpectedRes 
            report "Data - LH test failed. Simulation stopped!" 
            severity FAILURE;
        report "LH test passed!" severity NOTE;
        -- Testing the LHU functionality
        DMemOp <= MEM_LHU;
        assert IReady = '0' 
            report "Instruction memory ready incorrect. Simulation stopped!" 
            severity FAILURE;
        DAddr <= SH_ADDR;
        ExpectedRes := (others => '0');
        ExpectedRes(15 downto 0) := TEST_DATA(15 downto 0);
        wait until falling_edge(clk);
        assert DReadData = ExpectedRes 
            report "Data - LHU test failed. Simulation stopped!"
            severity FAILURE;
        report "LHU test passed!" severity NOTE;

        -- Testing instead a SB instruction
        DMemOp <= MEM_SB;
        DAddr <= SB_ADDR;
        wait until falling_edge(clk);
        report "Testing SB functionality" severity NOTE;
        -- Testing the LB functionality
        DMemOp <= MEM_LB;
        assert IReady = '0' 
            report "Instruction memory ready incorrect. Simulation stopped!"
            severity FAILURE;
        ExpectedRes := (others => TEST_DATA(7));
        ExpectedRes(7 downto 0) := TEST_DATA(7 downto 0);
        wait until falling_edge(clk);
        assert DReadData = ExpectedRes 
            report "Data - LB test failed. Simulation stopped!" 
            severity FAILURE;
        report "LB test passed!" severity NOTE;
        -- Testing the LBU functionality
        DMemOp <= MEM_LBU;
        assert IReady = '0' 
            report "Instruction memory ready incorrect. Simulation stopped!" 
            severity FAILURE;
        ExpectedRes := (others => '0');
        ExpectedRes(7 downto 0) := TEST_DATA(7 downto 0);
        wait until falling_edge(clk);
        assert DReadData = ExpectedRes 
            report "Data - LBU test failed. Simulation stopped!" 
            severity FAILURE;
        report "LBU test passed!" severity NOTE;

        std.env.stop(0);
    end process stimuli;

    clock : process is
    begin
        clk <= '1'; wait for clk_p/2;
        clk <= '0'; wait for clk_p/2;
    end process clock;
end architecture;