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
--              : This entity represents the memory-mapped I/O units of
--              : the processor including switches, LEDs and UART.
--              |
-- Revision     : 1.0   (last updated June 30, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- ***********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.includes.all;

entity io is
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
end io;

architecture rtl of io is
    -- Signals for pipelining the control signals
    signal Addr_p : std_logic_vector(2 downto 0);
    signal MemOp_p : mem_op_t := MEM_NOP;

    -- Signals for the UART module
    signal uart_data_rx, uart_data_tx : std_logic_vector(BYTE_WIDTH-1 downto 0);
    signal uart_tx_stb, uart_tx_ack, uart_rx_stb : std_logic;

    -- Signals for registers
    signal uart_data_rx_reg : std_logic_vector(BYTE_WIDTH-1 downto 0) := (others => '0');
    signal uart_rx_stb_reg, uart_tx_stb_reg : std_logic := '0';
    signal led_reg : std_logic_vector(2*BYTE_WIDTH-1 downto 0) := (others => '0');

    -- The UART component declaration
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
    trans : uart
    generic map (
        baud => BAUD_RATE,
        clock_frequency => CLOCK_F_INT
    )
    port map (
        clock => clk,
        reset => reset,
        data_stream_in => uart_data_tx,
        data_stream_in_stb => uart_tx_stb,
        data_stream_in_ack => uart_tx_ack,
        data_stream_out => uart_data_rx,
        data_stream_out_stb => uart_rx_stb,
        tx => serial_tx,
        rx => serial_rx
    );

    -- Handling inputs and outputs based on memory operation and address
    comb : process (all)
    begin
        -- Output logic
        ReadData <= (others => '0');
        output : if (is_read_op(MemOp_p)) then
            case (Addr_p) is
                when "001" => -- UART data address
                    ReadData(BYTE_WIDTH-1 downto 0) <= uart_data_rx_reg;
                when "010" => -- UART tx stb address
                    ReadData(0) <= uart_tx_stb_reg;
                when "011" => -- UART rx stb address
                    ReadData(0) <= uart_rx_stb_reg;
                when "100" => -- SW low address
                    ReadData(BYTE_WIDTH-1 downto 0) <= sw(BYTE_WIDTH-1 downto 0);
                when "101" => -- SW high address
                    ReadData(BYTE_WIDTH-1 downto 0) <= sw(2*BYTE_WIDTH-1 downto BYTE_WIDTH);
                when others =>
                    -- Do nothing
            end case;
        end if output;
    end process comb;

    leds <= led_reg;
    uart_tx_stb <= uart_tx_stb_reg;

    -- Handling the registers of the design
    reg : process (all)
    begin
        if (rising_edge(clk)) then
            Addr_p <= Addr(2 downto 0);
            if (reset = '1') then
                MemOp_p <= MEM_NOP;
                uart_data_rx_reg <= (others => '0');
                uart_tx_stb_reg <= '0';
                uart_rx_stb_reg <= '0';
                led_reg <= (others => '0');
            else
                MemOp_p <= MemOp;
                -- Input logic
                input : if (is_write_op(MemOp)) then
                    case (Addr(2 downto 0)) is
                        when "001" => -- UART data address
                            uart_data_tx <= WriteData(BYTE_WIDTH-1 downto 0);
                            uart_tx_stb_reg <= '1';
                        when "100" => -- LED low address
                            led_reg(BYTE_WIDTH-1 downto 0) <= WriteData(BYTE_WIDTH-1 downto 0);
                        when "101" => -- LED high address
                            led_reg(2*BYTE_WIDTH-1 downto BYTE_WIDTH) <= WriteData(BYTE_WIDTH-1 downto 0);
                        when others =>
                            -- do nothing
                    end case;
                end if input;
                -- Reset output strobe when transfer has finished
                if (uart_tx_ack = '1') then
                    uart_tx_stb_reg <= '0';
                end if;
                -- Set input strobe and data when data is available
                if (uart_rx_stb = '1') then
                    uart_rx_stb_reg <= '1';
                    uart_data_rx_reg <= uart_data_rx;
                end if;
                -- Clear input strobe when data is read
                if (is_read_op(MemOp) and Addr(2 downto 0) = "001") then
                    uart_rx_stb_reg <= '0';
                end if;
            end if;
        end if;
    end process reg;
end rtl;