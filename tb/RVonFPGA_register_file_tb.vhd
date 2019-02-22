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
--              : This is a testbench for the register file.
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

entity register_file_tb is
end register_file_tb;

architecture rtl of register_file_tb is
    -- Clock period in ns
    constant clk_p : time := 10 ns;

    -- Random test data (see the data memory testbench)
    constant TEST_DATA : std_logic_vector(DATA_WIDTH-1 downto 0) := x"BADC0FFEE0DDF00D";

    -- Signals for interfacing the memory
    signal RegWrite, clk : std_logic := '0';
    signal rs1, rs2, rd : std_logic_vector(4 downto 0) := (others => '0');
    signal Data1, Data2, WriteData : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
begin
    dut : register_file
    port map (
        RegWrite => RegWrite,
        clk => clk,
        RegisterRs1 => rs1,
        RegisterRs2 => rs2,
        RegisterRd => rd,
        Data1 => Data1,
        Data2 => Data2,
        WriteData => WriteData
    );

    -- Testing all types of memory operations - starting with a large write
    stimuli : process is
    begin
        wait until falling_edge(clk);
        -- Storing some test values in the register file
        RegWrite <= '1';
        rd <= "01010";
        WriteData <= TEST_DATA;
        wait until falling_edge(clk);
        rd <= "10010";
        wait until falling_edge(clk);
        -- Writing to register 0 should cause no change
        rd <= "00000";
        wait until falling_edge(clk);
        -- Testing that register 0 reads out 0
        RegWrite <= '0';
        wait until falling_edge(clk);
        assert unsigned(Data1) = 0 report "Register 0 does not output 0!" severity FAILURE;
        assert unsigned(Data2) = 0 report "Register 0 does not output 0!" severity FAILURE;
        report "Write test to register 0 passed!" severity NOTE;
        -- Testing that the previously stored data is output
        rs1 <= "01010";
        rs2 <= "10010";
        wait until falling_edge(clk);
        assert Data1 = TEST_DATA report "Register outputs incorrect data!" severity FAILURE;
        assert Data2 = TEST_DATA report "Register outputs incorrect data!" severity FAILURE;
        report "Write test passed!" severity NOTE;
        -- Testing the forwarding hardware
        RegWrite <= '1';
        rd <= "00100";
        rs1 <= "00100";
        rs2 <= "00100";
        wait until falling_edge(clk);
        assert Data1 = TEST_DATA report "Forwarding is incorrect on port 1!" severity FAILURE;
        assert Data2 = TEST_DATA report "Forwarding is incorrect on port 2!" severity FAILURE;
        rd <= "00000";
        rs1 <= "00000";
        rs2 <= "00000";
        wait until falling_edge(clk);
        assert unsigned(Data1) = 0 report "Forwarding is incorrect on port 1!" severity FAILURE;
        assert unsigned(Data2) = 0 report "Forwarding is incorrect on port 2!" severity FAILURE;
        report "Forwarding test passed!" severity NOTE;

        std.env.stop(0);
    end process stimuli;

    clock : process is
    begin
        clk <= '1'; wait for clk_p/2;
        clk <= '0'; wait for clk_p/2;
    end process clock;
end architecture;