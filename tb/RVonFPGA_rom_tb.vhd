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
--              : This is a testbench for the ROM.
--              |
-- Revision     : 1.0   (last updated June 29, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- ***********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity rom_tb is
end rom_tb;

architecture rtl of rom_tb is
    constant clk_p : time := 10 ns;
    -- Signals for the DUT
    signal clk, reset : std_logic := '0';
    signal MemOp : mem_op_t := MEM_NOP;
    signal Addr : std_logic_vector(11 downto 0) := (others => '0');
    signal ReadData : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Component declaration of the ROM
    component rom is
        port (
            clk, reset : in std_logic;
            -- Memory interface
            MemOp : in mem_op_t;
            Addr : in std_logic_vector(11 downto 0);
            ReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
begin
    dut : rom
    port map (
        clk => clk,
        reset => reset,
        MemOp => MemOp,
        Addr => Addr,
        ReadData => ReadData
    );

    stimuli : process is
        begin
            -- Reset the system before running it
            reset <= '1';
            for i in 0 to 4 loop
                wait until falling_edge(clk);
            end loop;
            reset <= '0';
            -- Test some operations
            MemOp <= MEM_LBU;
            Addr <= x"003";
            wait until falling_edge(clk);
            assert ReadData = x"000000000000002e"
                report "LBU result incorrect"
                severity FAILURE;
            MemOp <= MEM_LB;
            Addr <= x"01C";
            wait until falling_edge(clk);
            assert ReadData = x"ffffffffffffffef"
                report "LB result incorrect"
                severity FAILURE;
            MemOp <= MEM_LHU;
            Addr <= x"000";
            wait until falling_edge(clk);
            assert ReadData = x"0000000000006556"
                report "LHU result incorrect"
                severity FAILURE;
            MemOp <= MEM_LH;
            wait until falling_edge(clk);
            assert ReadData = x"0000000000006556"
                report "LH result incorrect"
                severity FAILURE;
            MemOp <= MEM_SD;
            wait until falling_edge(clk);
            assert ReadData = x"0000000000000000"
                report "LH result incorrect"
                severity FAILURE;
            MemOp <= MEM_LWU;
            Addr <= x"00C";
            wait until falling_edge(clk);
            assert ReadData = x"0000000038322065"
                report "LWU result incorrect"
                severity FAILURE;
            MemOp <= MEM_LW;
            wait until falling_edge(clk);
            assert ReadData = x"0000000038322065"
                report "LW result incorrect"
                severity FAILURE;
            MemOp <= MEM_LD;
            Addr <= x"007";
            wait until falling_edge(clk);
            assert ReadData = x"3220656e754a2031"
                report "LD result incorrect"
                severity FAILURE;
            std.env.stop(0);
        end process stimuli;

    clock : process is
        begin
            clk <= '1'; wait for clk_p/2;
            clk <= '0'; wait for clk_p/2;
        end process clock;
end rtl;