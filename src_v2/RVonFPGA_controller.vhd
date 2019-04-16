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
--              : This entity represents the UART controller. Its design is heavily inspired
--              : by an implementation of a similar component by Luca Pezzarossa in course
--              : 02203 at DTU, see https://github.com/lucapezza/02203-serial-interface
--              |
-- Revision     : 2.0   (last updated April 11, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity controller is
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
end entity;

architecture rtl of controller is
    -- Constants for updating the states
    constant MEM_SIZE : natural := 2**MEM_ADDR_WIDTH;

    -- Control signal constants
    constant TEST_C : std_logic_vector(7 downto 0) := x"74"; -- Character is ASCII 't'
    constant UPLOAD_C : std_logic_vector(7 downto 0) := x"72"; -- Character is ASCII 'r'
    constant DOWNLOAD_C : std_logic_vector(7 downto 0) := x"77"; -- Character is ASCII 'w'
    constant CLEAR_C : std_logic_vector(7 downto 0) := x"63"; -- Character is ASCII 'c'
    constant REPLY_C : std_logic_vector(7 downto 0) := x"79"; -- Character is ASCII 'y'

    -- State type and related signals for the FSM
    type state_type is (start, clear, command, test, download_b0, download_b1, download_b2,
                        download_b3, download_b4, download_b5, download_b6, download_b7, download_store, 
                        upload_wait, upload_b0, upload_b1, upload_b2, upload_b3, upload_b4, upload_b5,
                        upload_b6, upload_b7, upload_check);
    signal State, State_next : state_type := start;

    -- Signals for addressing the memory
    signal Addr, Addr_next : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');

    -- Signals for the data buffer (works for both instruction memory and register file)
    signal DataBuf, DataBuf_next : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    --attribute DONT_TOUCH : string;
    --attribute DONT_TOUCH of DataBuf : signal is "true";
begin
    -- Connecting the output ports
    UAddr <= Addr;
    UWriteData <= DataBuf;

    comb : process (all)
    begin
        -- Default assignments for all register related signals
        State_next <= State;
        Addr_next <= Addr;
        DataBuf_next <= DataBuf;

        -- Default assignments for outputs
        data_stream_out <= (others => '0');
        data_stream_out_stb <= '0';
        UMemOp <= MEM_NOP;

        -- Updating buffers, outputs and register values depending on the state
        case (State) is
            when start => 
                -- Reset internal buffers such that the controller is ready
                DataBuf_next <= (others => '0');
                Addr_next <= (others => '0');
                State_next <= command;
            -- Command state that controls the operation type performed by the UART controller
            when command =>
                if (data_stream_in_stb = '0') then
                    -- No data to read, standby
                    State_next <= command;
                else
                    -- The following code is based on control characters sent by the
                    -- controller program on the PC. Read the character and take action
                    case (data_stream_in) is
                        when TEST_C =>
                            -- Test the connection to the UART
                            State_next <= test;
                        when UPLOAD_C =>
                            -- Start upload of data from the FPGA to the PC
                            State_next <= upload_wait;
                            Addr_next <= (others => '0');
                        when DOWNLOAD_C =>
                            -- Start download of data from the PC to the FPGA
                            State_next <= download_b0;
                            Addr_next <= (others => '0');
                            DataBuf_next <= (others => '0');
                        when CLEAR_C =>
                            -- Clear the memory content
                            State_next <= clear;
                            Addr_next <= (others => '0');
                            DataBuf_next <= (others => '0');
                        when others =>
                            State_next <= command;
                    end case;
                end if;

            -- Clear the entire memory
            when clear => 
                if (unsigned(Addr) = MEM_SIZE - DATA_WIDTH/BYTE_WIDTH) then
                    -- Entire memory has been reset
                    State_next <= command;
                else
                    -- More memory addresses remain
                    Addr_next <= std_logic_vector(unsigned(Addr) + DATA_WIDTH/BYTE_WIDTH);
                    UMemOp <= MEM_SD;
                    State_next <= clear;
                end if;

            -- Reply to a test signal from the PC
            when test =>
                data_stream_out <= REPLY_C; 
                data_stream_out_stb <= '1';
                if (data_stream_out_ack = '0') then
                    -- Character has not yet finished being transmitted
                    State_next <= test;
                else
                    -- Character has been transmitted
                    State_next <= command;
                end if;

            when download_b0 => 
                -- If data is ready, store it in the internal data buffer
                if data_stream_in_stb = '0' then
                    State_next <= download_b0;
                else
                    DataBuf_next(7 downto 0) <= data_stream_in;
                    State_next <= download_b1;
                end if;
            when download_b1 => 
                -- If data is ready, store it in the internal data buffer
                if data_stream_in_stb = '0' then
                    State_next <= download_b1;
                else
                    DataBuf_next(15 downto 8) <= data_stream_in;
                    State_next <= download_b2;
                end if;
            when download_b2 => 
                -- If data is ready, store it in the internal data buffer
                if data_stream_in_stb = '0' then
                    State_next <= download_b2;
                else
                    DataBuf_next(23 downto 16) <= data_stream_in;
                    State_next <= download_b3;
                end if;
            when download_b3 => 
                -- If data is ready, store it in the internal data buffer
                if data_stream_in_stb = '0' then
                    State_next <= download_b3;
                else
                    DataBuf_next(31 downto 24) <= data_stream_in;
                    State_next <= download_b4;
                end if;
            when download_b4 => 
                -- If data is ready, store it in the internal data buffer
                if data_stream_in_stb = '0' then
                    State_next <= download_b4;
                else
                    DataBuf_next(39 downto 32) <= data_stream_in;
                    State_next <= download_b5;
                end if;
            when download_b5 => 
                -- If data is ready, store it in the internal data buffer
                if data_stream_in_stb = '0' then
                    State_next <= download_b5;
                else
                    DataBuf_next(47 downto 40) <= data_stream_in;
                    State_next <= download_b6;
                end if;
            when download_b6 => 
                -- If data is ready, store it in the internal data buffer
                if data_stream_in_stb = '0' then
                    State_next <= download_b6;
                else
                    DataBuf_next(55 downto 48) <= data_stream_in;
                    State_next <= download_b7;
                end if;
            when download_b7 => 
                -- If data is ready, store it in the internal data buffer
                if data_stream_in_stb = '0' then
                    State_next <= download_b7;
                else
                    DataBuf_next(63 downto 56) <= data_stream_in;
                    State_next <= download_store;
                end if;
            when download_store => 
                -- Store data in memory
                UMemOp <= MEM_SD;
                if (unsigned(Addr) = MEM_SIZE - DATA_WIDTH/BYTE_WIDTH) then
                    -- Entire memory has been filled
                    State_next <= command;
                else
                    -- More memory addresses remain
                    State_next <= download_b0;
                    Addr_next <= std_logic_vector(unsigned(Addr) + DATA_WIDTH/BYTE_WIDTH);
                end if;

            when upload_wait =>
                UMemOp <= MEM_LD;
                State_next <= upload_b0;
            when upload_b0 =>
                UMemOp <= MEM_LD;
                data_stream_out <= UReadData(7 downto 0);
                data_stream_out_stb <= '1';
                -- If data has been transmitted, transmit next byte
                if (data_stream_out_ack = '0') then
                    State_next <= upload_b0;
                else
                    State_next <= upload_b1;
                end if;
            when upload_b1 =>
                UMemOp <= MEM_LD;
                data_stream_out <= UReadData(15 downto 8);
                data_stream_out_stb <= '1';
                -- If data has been transmitted, transmit next byte
                if (data_stream_out_ack = '0') then
                    State_next <= upload_b1;
                else
                    State_next <= upload_b2;
                end if;
            when upload_b2 =>
                UMemOp <= MEM_LD;
                data_stream_out <= UReadData(23 downto 16);
                data_stream_out_stb <= '1';
                -- If data has been transmitted, transmit next byte
                if (data_stream_out_ack = '0') then
                    State_next <= upload_b2;
                else
                    State_next <= upload_b3;
                end if;
            when upload_b3 =>
                UMemOp <= MEM_LD;
                data_stream_out <= UReadData(31 downto 24);
                data_stream_out_stb <= '1';
                -- If data has been transmitted, transmit next byte
                if (data_stream_out_ack = '0') then
                    State_next <= upload_b3;
                else
                    State_next <= upload_b4;
                end if;
            when upload_b4 =>
                UMemOp <= MEM_LD;
                data_stream_out <= UReadData(39 downto 32);
                data_stream_out_stb <= '1';
                -- If data has been transmitted, transmit next byte
                if (data_stream_out_ack = '0') then
                    State_next <= upload_b4;
                else
                    State_next <= upload_b5;
                end if;
            when upload_b5 =>
                UMemOp <= MEM_LD;
                data_stream_out <= UReadData(47 downto 40);
                data_stream_out_stb <= '1';
                -- If data has been transmitted, transmit next byte
                if (data_stream_out_ack = '0') then
                    State_next <= upload_b5;
                else
                    State_next <= upload_b6;
                end if;
            when upload_b6 =>
                UMemOp <= MEM_LD;
                data_stream_out <= UReadData(55 downto 48);
                data_stream_out_stb <= '1';
                -- If data has been transmitted, transmit next byte
                if (data_stream_out_ack = '0') then
                    State_next <= upload_b6;
                else
                    State_next <= upload_b7;
                end if;
            when upload_b7 =>
                UMemOp <= MEM_LD;
                data_stream_out <= UReadData(63 downto 56);
                data_stream_out_stb <= '1';
                -- If data has been transmitted, transmit next byte
                if (data_stream_out_ack = '0') then
                    State_next <= upload_b7;
                else
                    State_next <= upload_check;
                end if;
            when others => -- upload_check
                if (unsigned(Addr) = MEM_SIZE - DATA_WIDTH/BYTE_WIDTH) then
                    State_next <= command;
                else
                    Addr_next <= std_logic_vector(unsigned(Addr) + DATA_WIDTH/BYTE_WIDTH);
                    State_next <= upload_wait;
                end if;
        end case;
    end process comb;

    reg : process (all)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                State <= start;             
                DataBuf <= (others => '0');
                Addr <= (others => '0');
            else
                State <= State_next;
                DataBuf <= DataBuf_next;
                Addr <= Addr_next;
            end if;
        end if;
    end process reg;
end rtl;