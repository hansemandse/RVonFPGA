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
--              : This is a testbench for the system.
--              |
-- Revision     : 1.0   (last updated July 2, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- ***********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity top_tb is
end top_tb;

architecture rtl of top_tb is
    constant clk_p : time := 10 ns;
    -- Signals for the DUT
    signal clk, reset : std_logic;
    signal sw, leds : std_logic_vector(2*BYTE_WIDTH-1 downto 0);
    signal serial_rx, serial_tx : std_logic;
    
    signal data_in, data_out : std_logic_vector(BYTE_WIDTH-1 downto 0);
    signal data_in_stb, data_in_ack, data_out_stb : std_logic;

    -- Component declaration of the system
    component top is
        port (
            clk, reset : in std_logic;
            -- I/O on the test board
            sw : in std_logic_vector(2*BYTE_WIDTH-1 downto 0);
            leds : out std_logic_vector(2*BYTE_WIDTH-1 downto 0);
            -- Serial communication with a PC
            serial_tx : out std_logic;
            serial_rx : in std_logic
        );
    end component;
    
    -- Component declaration of UART module
    component uart
        generic (
            baud                : positive;
            clock_frequency     : positive
        );
        port (  
            clock               :   in  std_logic;
            reset               :   in  std_logic;    
            data_stream_in      :   in  std_logic_vector(7 downto 0);
            data_stream_in_stb  :   in  std_logic;
            data_stream_in_ack  :   out std_logic;
            data_stream_out     :   out std_logic_vector(7 downto 0);
            data_stream_out_stb :   out std_logic;
            tx                  :   out std_logic;
            rx                  :   in  std_logic
        );
    end component;
begin
    dut : top
    port map (
        clk => clk,
        reset => reset,
        sw => sw,
        leds => leds,
        serial_tx => serial_tx,
        serial_rx => serial_rx
    );

    uart2 : uart
    generic map (
        baud => BAUD_RATE,
        clock_frequency => CLOCK_F_INT
    )
    port map (
        clock => clk,
        reset => reset,
        data_stream_in => data_in,
        data_stream_in_stb => data_in_stb,
        data_stream_in_ack => data_in_ack,
        data_stream_out => data_out,
        data_stream_out_stb => data_out_stb,
        tx => serial_rx,
        rx => serial_tx
    );

    stimuli : process is
    begin
        -- Defaulting signal values
        data_in_stb <= '0'; sw <= (others => '0'); data_in <= (others => '0');
        -- Reset the system before running it
        reset <= '1';
        for i in 0 to 4 loop
            wait until falling_edge(clk);
        end loop;
        reset <= '0';
        -- Run the processor for some clock cycles
        while (true) loop
            wait until falling_edge(clk);
            if (data_out_stb = '1') then
                report "Received " & integer'image(to_integer(unsigned(data_out)));
            end if;
        end loop;
        std.env.stop(0);
    end process stimuli;

    clock : process is
    begin
        clk <= '1'; wait for clk_p/2;
        clk <= '0'; wait for clk_p/2;
    end process clock;
end architecture;