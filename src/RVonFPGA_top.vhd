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
--              : This entity represents the top entity interconnecting
--              : the pipeline, the memories and the clock divider.
--              |
-- Revision     : 2.0   (last updated July 11, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- ***********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity top is
    port (
        clk, reset : in std_logic;
        -- I/O on the test board
        sw : in std_logic_vector(2*BYTE_WIDTH-1 downto 0);
        leds : out std_logic_vector(2*BYTE_WIDTH-1 downto 0);
        -- Serial communication with a PC
        serial_tx : out std_logic;
        serial_rx : in std_logic
    );
end top;

architecture rtl of top is
    -- Signals for interconnecting the components
    signal clk_int : std_logic;
    signal IReady : std_logic;

    signal IMemOp : mem_op_t;
    signal IAddr : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal IReadData : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal DMemOp : mem_op_t;
    signal DAddr : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal DWriteData, DReadData : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- The pipeline component
    component pipeline
        port (
            -- Input ports
            clk, reset : in std_logic;
            -- Instruction memory interface
            IReady : in std_logic;
            IMemOp : out mem_op_t;
            IAddr : out std_logic_vector(DATA_WIDTH-1 downto 0);
            IReadData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            -- Data memory interface
            DMemOp : out mem_op_t;
            DAddr : out std_logic_vector(DATA_WIDTH-1 downto 0);
            DWriteData : out std_logic_vector(DATA_WIDTH-1 downto 0);
            DReadData : in std_logic_vector(DATA_WIDTH-1 downto 0)
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

    -- The memory management component
    component mem_man
        port (
            clk, reset : in std_logic;
            -- Instruction memory interface
            IReady : out std_logic;
            IMemOp : in mem_op_t;
            IAddr : in std_logic_vector(DATA_WIDTH-1 downto 0);
            IReadData : out std_logic_vector(DATA_WIDTH-1 downto 0);
            -- Data memory interface
            DMemOp : in mem_op_t;
            DAddr : in std_logic_vector(DATA_WIDTH-1 downto 0);
            DWriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            DReadData : out std_logic_vector(DATA_WIDTH-1 downto 0);
            -- I/O interfaces
            sw : in std_logic_vector(2*BYTE_WIDTH-1 downto 0);
            leds : out std_logic_vector(2*BYTE_WIDTH-1 downto 0);
            serial_tx : out std_logic;
            serial_rx : in std_logic
        );
    end component;
begin
    pip : pipeline
    port map(
        clk => clk_int,
        reset => reset,
        IReady => IReady,
        IMemOp => IMemOp,
        IAddr => IAddr,
        IReadData => IReadData,
        DMemOp => DMemOp,
        DAddr => DAddr,
        DWriteData => DWriteData,
        DReadData => DReadData
    );

    div : clock_divider
    port map (
        clk_in => clk,
        reset => reset,
        clk_out => clk_int
    );

    man : mem_man
    port map (
        clk => clk_int,
        reset => reset,
        IReady => IReady,
        IAddr => IAddr,
        IMemOp => IMemOp,
        IReadData => IReadData,
        DMemOp => DMemOp,
        DAddr => DAddr,
        DWriteData => DWriteData,
        DReadData => DReadData,
        sw => sw,
        leds => leds,
        serial_tx => serial_tx,
        serial_rx => serial_rx
    );
end rtl;