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
--              : This entity represents the memory manager.
--              |
-- Revision     : 2.0   (last updated July 2, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity mem_man is
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
end mem_man;

architecture rtl of mem_man is
    signal RAM_MemOp, ROM_MemOp, IO_MemOp : mem_op_t;
    signal RAM_ReadData, ROM_ReadData, IO_ReadData : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal Addr : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal DMemOp_p, IMemOp_p : mem_op_t;
    signal Addr_p : std_logic_vector(3 downto 0);

    -- The memory component
    component memory
        generic (
            BLOCK_WIDTH : natural := BYTE_WIDTH;
            ADDR_WIDTH : natural := MEM_ADDR_WIDTH
        );
        port (
            clk, reset : in std_logic;
            -- Memory interface
            MemOp : in mem_op_t;
            Addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            WriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
            ReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    -- The ROM component
    component rom
        port (
            clk, reset : in std_logic;
            -- Memory interface
            MemOp : in mem_op_t;
            Addr : in std_logic_vector(11 downto 0);
            ReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    -- The I/O units component
    component io
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
begin

    IReady <= '1' when (DMemOp = MEM_NOP) else '0';

    -- Managing the memory interfaces
    inp : process (all)
        variable MemOp : mem_op_t;
    begin
        -- Selecting which port to operate on
        if (DMemOp /= MEM_NOP) then -- Handle the data port
            MemOp := DMemOp;
            Addr <= DAddr;
        else -- Handle the instruction port
            MemOp := IMemOp;
            Addr <= IAddr;
        end if;

        -- Defaulting all outputs to make code more readable
        RAM_MemOp <= MEM_NOP;
        ROM_MemOp <= MEM_NOP;
        IO_MemOp <= MEM_NOP;

        -- Selecting which unit to address
        case (Addr(DATA_WIDTH-1 downto DATA_WIDTH-4)) is
            when x"0" => -- ROM
                ROM_MemOp <= MemOp;
            when x"1" => -- RAM
                RAM_MemOp <= MemOp;
            when x"8" => -- I/O
                IO_MemOp <= MemOp;
            when others => 
                -- Do nothing
        end case;
    end process inp;

    -- Output management
    outp : process (all)
    begin
        if (is_read_op(DMemOp_p)) then
            -- Output to the data port
            IReadData <= (others => '0');
            case (Addr_p) is
                when x"0" =>
                    DReadData <= ROM_ReadData;
                when x"1" =>
                    DReadData <= RAM_ReadData;
                when x"8" =>
                    DReadData <= IO_ReadData;
                when others =>
                    DReadData <= (others => '0');
            end case;
        else
            -- Output to the instruction port
            case (Addr_p) is
                when x"0" =>
                    IReadData <= ROM_ReadData;
                when x"1" =>
                    IReadData <= RAM_ReadData;
                when x"8" =>
                    IReadData <= IO_ReadData;
                when others =>
                    IReadData <= (others => '0');
            end case;
            DReadData <= (others => '0');
        end if;
    end process outp;

    -- Clocked process for pipelined control signals (as in the memories)
    reg : process (all)
    begin
        if (rising_edge(clk)) then
            Addr_p <= Addr(DATA_WIDTH-1 downto DATA_WIDTH-4);
            DMemOp_p <= DMemOp;
        end if;
    end process reg;

    ram : memory
    port map (
        clk => clk,
        reset => reset,
        MemOp => RAM_MemOp,
        Addr => Addr(MEM_ADDR_WIDTH-1 downto 0),
        WriteData => DWriteData,
        ReadData => RAM_ReadData
    );

    bootrom : rom
    port map (
        clk => clk,
        reset => reset,
        MemOp => ROM_MemOp,
        Addr => Addr(11 downto 0),
        ReadData => ROM_ReadData
    );

    iounit : io
    port map (
        clk => clk,
        reset => reset,
        MemOp => IO_MemOp,
        Addr => Addr(2 downto 0),
        WriteData => DWriteData(BYTE_WIDTH-1 downto 0),
        ReadData => IO_ReadData,
        serial_tx => serial_tx,
        serial_rx => serial_rx,
        sw => sw,
        leds => leds
    );
end rtl;