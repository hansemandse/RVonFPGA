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
--              : This is a testbench for the I/O unit.
--              |
-- Revision     : 1.0   (last updated June 30, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- ***********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity io_tb is
end io_tb;

architecture rtl of io_tb is
    constant clk_p : time := 10 ns;
    -- Signals for the DUT
    signal clk, reset : std_logic;
    signal MemOp : mem_op_t;
    signal WriteData : std_logic_vector(BYTE_WIDTH-1 downto 0);
    signal ReadData : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal Addr : std_logic_vector(2 downto 0);
    signal sw, leds : std_logic_vector(2*BYTE_WIDTH-1 downto 0);
    signal serial_rx, serial_tx : std_logic;
    
    signal uart_rx_stb_reg : std_logic;
    
    signal data_in, data_out : std_logic_vector(BYTE_WIDTH-1 downto 0);
    signal data_in_stb, data_in_ack, data_out_stb : std_logic;

    -- Component declaration of the system
    component io is
        port (
            -- Control ports
            reset, clk : in std_logic;
            -- Memory interface
            MemOp : in mem_op_t;
            Addr : in std_logic_vector(2 downto 0);
            WriteData : in std_logic_vector(BYTE_WIDTH-1 downto 0);
            ReadData : out std_logic_vector(DATA_WIDTH-1 downto 0);
            -- I/O ports
            serial_tx : out std_logic;
            serial_rx : in std_logic;
            sw : in std_logic_vector(2*BYTE_WIDTH-1 downto 0);
            leds : out std_logic_vector(2*BYTE_WIDTH-1 downto 0)
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
    dut : io
    port map (
        clk => clk,
        reset => reset,
        MemOp => MemOp,
        Addr => Addr,
        WriteData => WriteData,
        ReadData => ReadData,
        serial_tx => serial_tx,
        serial_rx => serial_rx,
        sw => sw,
        leds => leds
    );
    uart_rx_stb_reg <= <<signal .io_tb.dut.uart_rx_stb_reg : std_logic>>;

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
        MemOp <= MEM_NOP; Addr <= (others => '0');
        -- Reset the system before running it
        reset <= '1';
        for i in 0 to 4 loop
            wait until falling_edge(clk);
        end loop;
        reset <= '0';
        -- Run the I/O unit for some clock cycles
        MemOp <= MEM_SB; Addr <= "001"; WriteData <= x"59";
        wait until falling_edge(clk);
        MemOp <= MEM_LB; Addr <= "010"; 
        wait until falling_edge(clk);
        assert ReadData = x"0000000000000001"
            report "ReadData tx stb incorrect"
            severity FAILURE;
        while (data_out_stb = '0') loop
            wait until falling_edge(clk);
        end loop;
        assert data_out = x"59"
            report "Received data incorrect"
            severity FAILURE;
        assert ReadData = x"0000000000000000"
            report "ReadData tx stb incorrect"
            severity FAILURE;
        MemOp <= MEM_SB; Addr <= "101"; WriteData <= x"ab";
        wait until falling_edge(clk);
        Addr <= "100"; WriteData <= x"cd";
        wait until falling_edge(clk);
        assert leds = x"abcd"
            report "LEDs are incorrect"
            severity FAILURE;
        MemOp <= MEM_NOP;
        data_in <= x"ab"; data_in_stb <= '1';
        while (uart_rx_stb_reg = '0') loop
            wait until falling_edge(clk);
        end loop;
        data_in_stb <= '0'; MemOp <= MEM_LB; Addr <= "011";
        wait until falling_edge(clk);
        assert ReadData = x"0000000000000001"
            report "ReadData rx stb incorrect"
            severity FAILURE;
        Addr <= "001";
        wait until falling_edge(clk);
        assert ReadData = x"00000000000000ab"
            report "ReadData incorrect"
            severity FAILURE;
        Addr <= "011";
        wait until falling_edge(clk);
        assert ReadData = x"0000000000000000"
            report "ReadData rx stb (after read) incorrect"
            severity FAILURE;
        std.env.stop(0);
    end process stimuli;

    clock : process is
    begin
        clk <= '1'; wait for clk_p/2;
        clk <= '0'; wait for clk_p/2;
    end process clock;
end architecture;