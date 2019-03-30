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
--              : This is a testbench for the pipeline.
--              |
-- Revision     : 1.1   (last updated March 10, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

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

    -- Signals for interfacing the pipeline (it will likely be more interesting to
    -- look into the register file in simulation than these)
    signal clk, reset, IMemWrite, pipcont : std_logic := '0';
    signal pc_out : std_logic_vector(PC_WIDTH-1 downto 0);
    signal ImemOp : imem_op_t := MEM_NOP;
    signal IWriteData : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal IWriteAddress : std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');

    -- Pipeline component declaration
    component pipeline is
        port (
            -- Input ports
            clk, reset, pipcont : in std_logic;
            -- Output ports
            pc_out : out std_logic_vector(PC_WIDTH-1 downto 0);
            -- Inputs to the instruction memory
            IMemWrite : in std_logic;
            ImemOp : in imem_op_t;
            IWriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            IWriteAddress : in std_logic_vector(PC_WIDTH-1 downto 0);
            -- Inputs to the register file
            RFRs : in std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
            -- Outputs from the register file
            RFData : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
begin
    dut : pipeline 
    port map (
        clk => clk,
        reset => reset,
        pipcont => pipcont,
        pc_out => pc_out,
        ImemWrite => ImemWrite,
        ImemOp => ImemOp,
        IWriteData => IWriteData,
        IWriteAddress => IWriteAddress,
        RFRs => (others => '0'),
        RFData => open
    );

    stimuli : process is
    begin
        -- Reset the pipeline before running it
        reset <= '1';
        for i in 0 to 4 loop
            wait until falling_edge(clk);
        end loop;
        reset <= '0';
        -- Run through the instructions
        for i in 0 to instr_count+5 loop
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