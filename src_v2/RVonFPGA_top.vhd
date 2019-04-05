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
-- Revision     : 1.1   (last updated April 5, 2019)
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
    signal clk_int : std_logic;
    
    signal data_stream_cu, data_stream_uc : std_logic_vector(BYTE_WIDTH-1 downto 0);
    signal data_stream_ack, data_stream_stb_uc, data_stream_stb_cu : std_logic;

    signal IMemOp : mem_op_t;
    signal IReady : std_logic;
    signal IAddr : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
    signal IReadData : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal DMemOp : mem_op_t;
    signal DAddr : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
    signal DWriteData, DReadData : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal UMemOp : mem_op_t;
    signal UAddr : std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
    signal UWriteData, UReadData : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- The pipeline component
    component pipeline
        port (
            -- Input ports
            clk, reset : in std_logic;
            -- Instruction memory interface
            IMemOp : out mem_op_t;
            IReady : in std_logic;
            IAddr : out std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
            IReadData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            -- Data memory interface
            DMemOp : out mem_op_t;
            DAddr : out std_logic_vector(MEM_ADDR_WIDTH-1 downto 0);
            DWriteData : out std_logic_vector(DATA_WIDTH-1 downto 0);
            DReadData : in std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    -- The memory component
    component memory
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
            DReadData : out std_logic_vector(DATA_WIDTH-1 downto 0);
            -- "Back door" UART interface
            UMemOp : in mem_op_t;
            UReady : out std_logic;
            UAddr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            UWriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            UReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
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
            ADDR_WIDTH : natural := MEM_ADDR_WIDTH
        );
        port (
            clk, reset : in std_logic;
            -- Interface to the UART
            data_stream_out : out std_logic_vector(BYTE_WIDTH-1 downto 0);
            data_stream_out_stb : out std_logic;
            data_stream_out_ack : in std_logic;
            data_stream_in : in std_logic_vector(BYTE_WIDTH-1 downto 0);
            data_stream_in_stb : in std_logic;
            -- Interface to the memory
            UMemOp : out mem_op_t;
            UAddr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
            UWriteData : out std_logic_vector(DATA_WIDTH-1 downto 0);
            UReadData : in std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
begin
    pip : pipeline
    port map(
        clk => clk_int,
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
        clk => clk_int,
        reset => reset,
        ImemOp => IMemOp,
        IReady => IReady,
        IAddr => IAddr,
        IWriteData => (others => '0'),
        IReadData => IReadData,
        DMemOp => DMemOp,
        DReady => open,
        DAddr => DAddr,
        DWriteData => DWriteData,
        DReadData => DReadData,
        UMemOp => UMemOp,
        UReady => open,
        UAddr => UAddr,
        UWriteData => UWriteData,
        UReadData => UReadData
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
        data_stream_in_stb => data_stream_stb_uc,
        UMemOp => UMemOp,
        UAddr => UAddr,
        UWriteData => UWriteData,
        UReadData => UReadData
    );
end rtl;