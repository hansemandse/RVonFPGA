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
--              : This is a testbench for the pipeline.
--              |
-- Revision     : 1.3   (last updated June 25, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- ***********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity pipeline_tb is
end pipeline_tb;

architecture rtl of pipeline_tb is
    -- Clock period in ns
    constant clk_p : time := 10 ns;

    -- Number of clock cycles to run for
    constant instr_count : natural := get_instr_count(TEST_FILE);

    -- Signals for interfacing the pipeline - it will likely be more
    -- interesting to look into the register file in simulation than these
    signal clk, reset : std_logic := '0';
    signal IReady : std_logic;
    signal IMemOp, DMemOp, UMemOp : mem_op_t;
    signal IAddr, DAddr : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal UAddr : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
    signal IReadData, DReadData, UReadData : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal DWriteData, UWriteData : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Pipeline component declaration
    component pipeline is
        port (
            -- Input ports
            clk, reset : in std_logic;
            -- Instruction memory interface
            IMemOp : out mem_op_t;
            IReady : in std_logic;
            IAddr : out std_logic_vector(DATA_WIDTH-1 downto 0);
            IReadData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            -- Data memory interface
            DMemOp : out mem_op_t;
            DAddr : out std_logic_vector(DATA_WIDTH-1 downto 0);
            DWriteData : out std_logic_vector(DATA_WIDTH-1 downto 0);
            DReadData : in std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    -- Memory component declaration
    component memory is
        generic (
            BLOCK_WIDTH : natural := BYTE_WIDTH;
            ADDR_WIDTH : natural := MEM_ADDR_WIDTH
        );
        port (
            clk, reset : in std_logic;
            -- Instruction memory interface
            IMemOp : in mem_op_t;
            IReady : out std_logic;
            IAddr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            IWriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            IReadData : out std_logic_vector(DATA_WIDTH-1 downto 0);
            -- Data memory interface
            DMemOp : in mem_op_t;
            DReady : out std_logic;
            DAddr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            DWriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            DReadData : out std_logic_vector(DATA_WIDTH-1 downto 0);
            -- "Back door" UART interface
            UMemOp : in mem_op_t;
            UReady : out std_logic;
            UAddr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            UWriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            UReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
begin
    dut : entity work.pipeline(rtl3)
    port map (
        clk => clk,
        reset => reset,
        IMemOp => IMemOp,
        IReady => IReady,
        IAddr => IAddr,
        IReadData => IReadData,
        DMemOp => DMemOp,
        DAddr => DAddr,
        DWriteData => DWriteData,
        DReadData => DReadData
    );

    mem : memory
    port map (
        clk => clk,
        reset => reset,
        IMemOp => IMemOp,
        IReady => IReady,
        IAddr => IAddr(MEM_ADDR_WIDTH-1 downto 0),
        IReadData => IReadData,
        IWriteData => (others => '0'),
        DMemOp => DMemOp,
        DReady => open,
        DAddr => DAddr(MEM_ADDR_WIDTH-1 downto 0),
        DWriteData => DWriteData,
        DReadData => DReadData,
        UMemOp => UMemOp,
        UReady => open,
        UAddr => UAddr,
        UWriteData => UWriteData,
        UReadData => UReadData
    );

    stimuli : process is
    begin
        UMemOp <= MEM_NOP;
        UAddr <= (others => '0');
        UWriteData <= (others => '0');
        -- Reset the pipeline before running it
        reset <= '1';
        for i in 0 to 4 loop
            wait until falling_edge(clk);
        end loop;
        reset <= '0';
        -- Run through the instructions
        for i in 0 to instr_count+25 loop
            wait until falling_edge(clk);
        end loop;
        wait until falling_edge(clk);

        std.env.stop(0);
    end process stimuli;

    clock : process is
    begin
        clk <= '1'; wait for clk_p/2;
        clk <= '0'; wait for clk_p/2;
    end process clock;
end rtl;