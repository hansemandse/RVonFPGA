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
--              : This entity represents the top entity interconnecting the pipeline, the
--              : clock divider and the UART controller.
--              |
-- Revision     : 1.0   (last updated March 25, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity top is
    port (
        clk, reset : in std_logic;
        -- Serial communication with a PC
        serial_tx : out std_logic;
        serial_rx : in std_logic
    );
end top;

architecture rtl of top is
    -- Signals for interconnecting the components
    signal data_stream_cu, data_stream_uc : std_logic_vector(BYTE_WIDTH-1 downto 0);
    signal data_stream_ack, data_stream_stb_uc, data_stream_stb_cu : std_logic;

    -- The pipeline component
    component pipeline
        port (
            -- Input ports
            clk, reset : in std_logic;
            -- Instruction memory interface
                -- FILL IN HERE
            -- Data memory interface
                -- FILL IN HERE
        );
    end component;

    -- The clock divider component
    component clock_divider
        generic (
            DIV : natural := CLOCK_DIV
        );
        port (
            clk_in, reset : in std_logic;
            clk_out : out std_logic
        );
    end component;

    -- The UART component
    component uart
        generic (
            baud : positive := BAUD_RATE;
            clock_frequency : positive := CLOCK_F_INT
        );
        port (
            clock, reset : in  std_logic;
            data_stream_in : in  std_logic_vector(7 downto 0);
            data_stream_in_stb : in  std_logic;
            data_stream_in_ack : out std_logic;
            data_stream_out : out std_logic_vector(7 downto 0);
            data_stream_out_stb : out std_logic;
            tx : out std_logic;
            rx : in  std_logic
        );
    end component;

    -- The UART controller
    component controller
        generic (
            IMEM_ADDR_WIDTH : natural := PC_WIDTH;
            RF_ADDR_WIDTH : natural := RF_ADDR_WIDTH
        );
        port (
            clk, reset : in std_logic;
            -- Interface to the UART
            data_stream_out : out std_logic_vector(BYTE_WIDTH-1 downto 0);
            data_stream_out_stb : out std_logic;
            data_stream_out_ack : in std_logic;
            data_stream_in : in std_logic_vector(BYTE_WIDTH-1 downto 0);
            data_stream_in_stb : in std_logic
            -- Interface to the memory
                -- FILL IN HERE
        );
    end component;
begin
    pip : pipeline
    port map(
        clk => clk_int,
        reset => reset
    );

    div : clock_divider
    port map (
        clk_in => clk,
        reset => reset,
        clk_out => clk_int
    );

    trans : UART
    port map (
        clock => clk_int,
        reset => reset,
        data_stream_in => data_stream_cu,
        data_stream_in_stb => data_stream_stb_cu,
        data_stream_in_ack => data_stream_ack,
        data_stream_out => data_stream_uc,
        data_stream_out_stb => data_stream_stb_uc,
        rx => serial_rx,
        tx => serial_tx
    );

    control : controller
    port map (
        clk => clk_int,
        reset => reset,
        data_stream_out => data_stream_cu,
        data_stream_out_stb => data_stream_stb_cu,
        data_stream_out_ack => data_stream_ack,
        data_stream_in => data_stream_uc,
        data_stream_in_stb => data_stream_stb_uc
    );
end rtl;