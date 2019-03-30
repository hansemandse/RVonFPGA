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

entity controller is
    generic (
        IMEM_ADDR_WIDTH : natural := 12;
        RF_ADDR_WIDTH : natural := 5
    );
    port (
        clk, reset : in std_logic;
        -- Interface to the UART
        data_stream_out : out std_logic_vector(BYTE_WIDTH-1 downto 0);
        data_stream_out_stb : out std_logic;
        data_stream_out_ack : in std_logic;
        data_stream_in : in std_logic_vector(BYTE_WIDTH-1 downto 0);
        data_stream_in_stb : in std_logic;
        -- Interface to the register file
        RFRs : out std_logic_vector(RF_ADDR_WIDTH-1 downto 0);
        RFData : in std_logic_vector(DATA_WIDTH-1 downto 0);
        -- Interface to the instruction memory
        ImemWrite : out std_logic;
        ImemOp : out imem_op_t;
        IWriteData : out std_logic_vector(DATA_WIDTH-1 downto 0);
        IWriteAddress : out std_logic_vector(IMEM_ADDR_WIDTH-1 downto 0);
        -- Interface to the pipeline
        pipcont : out std_logic
    );
end entity;

architecture rtl of controller is
    -- Constants for updating the states
    constant IMEM_SIZE : natural := 2 ** IMEM_ADDR_WIDTH;
    constant RF_SIZE : natural := 2 ** RF_ADDR_WIDTH;

    -- Control signal constants
    constant TEST_C : std_logic_vector(7 downto 0) := x"74"; -- Character is ASCII 't'
    constant UPLOAD_C : std_logic_vector(7 downto 0) := x"72"; -- Character is ASCII 'r'
    constant DOWNLOAD_C : std_logic_vector(7 downto 0) := x"77"; -- Character is ASCII 'w'
    constant CLEAR_C : std_logic_vector(7 downto 0) := x"63"; -- Character is ASCII 'c'
    constant RUN_C : std_logic_vector(7 downto 0) := x"52"; -- Character is ASCII 'R'
    constant REPLY_C : std_logic_vector(7 downto 0) := x"79"; -- Character is ASCII 'y'

    -- Counter for addressing the data buffer
    signal count, count_next : integer := 0;

    -- State type and related signals for the FSM
    type state_type is (start, clear, command, test, download, download_store,
                        upload, upload_check, run);
    signal State, State_next : state_type := start;

    -- Signals for addressing the instruction memory
    signal IAddr, IAddr_next : std_logic_vector(IMEM_ADDR_WIDTH-1 downto 0);
    
    -- Signals for addressing the register file
    signal RFAddr, RFAddr_next : std_logic_vector(RF_ADDR_WIDTH-1 downto 0);

    -- Signals for the data buffer (works for both instruction memory and register file)
    signal DataBuf, DataBuf_next : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    -- Connecting the output signals
    RFRs <= RFAddr;
    IWriteData <= DataBuf;
    IWriteAddress <= IAddr;

    comb : process (all)
    begin
        -- Default assignments for all register related signals
        State_next <= State;
        count_next <= count;
        IAddr_next <= IAddr;
        RFAddr_next <= RFAddr;
        DataBuf_next <= DataBuf;

        -- Default assignments for outputs
        data_stream_out <= (others => '0');
        data_stream_out_stb <= '0';
        ImemWrite <= '0';
        ImemOp <= MEM_NOP;
        pipcont <= '0';

        -- Updating buffers, outputs and register values depending on the state
        case (State) is
            when start => 
                -- Reset internal buffers such that the controller is ready
                DataBuf_next <= (others => '0');
                IAddr_next <= (others => '0');
                RFAddr_next <= (others => '0');
                State_next <= command;
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
                            State_next <= upload;
                            RFAddr_next <= (others => '0');
                            count_next <= 0;
                        when DOWNLOAD_C =>
                            -- Start download of data from the PC to the FPGA
                            State_next <= download;
                            IAddr_next <= (others => '0');
                            count_next <= 0;
                        when CLEAR_C =>
                            -- Clear the memory content
                            State_next <= clear;
                        when RUN_C =>
                            -- Reset the pipeline registers and the PC and start executing
                            State_next <= run;
                        when others =>
                            State_next <= command;
                    end case;
                end if;
            when clear => 
                -- Clear the entire instruction memory
                ImemWrite <= '1';
                ImemOp <= MEM_SD;
                if (unsigned(IAddr) = IMEM_SIZE-DATA_WIDTH/BYTE_WIDTH) then
                    -- Entire memory has been reset
                    State_next <= command;
                else
                    -- More memory addresses remain
                    IAddr_next <= std_logic_vector(unsigned(IAddr) + DATA_WIDTH/BYTE_WIDTH);
                    State_next <= clear;
                end if;
            when test => 
                -- Reply to the test signal from the PC
                data_stream_out <= REPLY_C; 
                data_stream_out_stb <= '1';
                if (data_stream_out_ack = '0') then
                    -- Character has not yet finished being transmitted
                    State_next <= test;
                else
                    -- Character has been transmitted
                    State_next <= command;
                end if;
            when download => 
                if (data_stream_in_stb = '0') then
                    -- Data is not yet available on the input bus
                    State_next <= download;
                else
                    -- Data is available and will be stored in the data buffer
                    DataBuf_next((count+1)*BYTE_WIDTH-1 downto count*BYTE_WIDTH) <= data_stream_in;
                    if (count = 7) then
                        -- All data buffer locations have been read - doubleword is ready to
                        -- be stored in memory
                        count_next <= 0;
                        State_next <= download_store;
                    else
                        -- There are remaining locations in the data buffer waiting to be filled
                        count_next <= count + 1;
                        State_next <= download;
                    end if;
                end if;
            when download_store => 
                -- Store data in memory
                ImemWrite <= '1';
                ImemOp <= MEM_SD;
                if (unsigned(IAddr) = IMEM_SIZE-DATA_WIDTH/BYTE_WIDTH) then
                    -- All memory locations have been filled
                    State_next <= command;
                else
                    -- More memory locations are available
                    IAddr_next <= std_logic_vector(unsigned(IAddr) + DATA_WIDTH/BYTE_WIDTH);
                    State_next <= download;
                end if;
            when upload => 
                -- Write data to the UART
                data_stream_out <= RFData((count+1)*BYTE_WIDTH-1 downto count*BYTE_WIDTH);
                data_stream_out_stb <= '1';
                if (data_stream_out_ack = '0') then
                    -- Data transfer has not yet completed
                    State_next <= upload;
                else
                    if (count = 7) then
                        -- All bytes of the register file entry have been uploaded
                        count_next <= 0;
                        State_next <= upload_check;
                    else
                        -- There are remaining bytes waiting to be uploaded
                        count_next <= count + 1;
                        State_next <= upload;
                    end if;
                end if;
            when upload_check =>
                if (unsigned(RFAddr) = RF_SIZE-1) then
                    State_next <= command;
                else
                    RFAddr_next <= std_logic_vector(unsigned(RFAddr) + 1);
                    State_next <= upload;
                end if;
            when others => -- run
                -- Reset the pipeline registers
                pipcont <= '1';
                State_next <= command;
        end case;
    end process comb;

    reg : process (all)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                State <= start;
                count <= 0;
                DataBuf <= (others => '0');
                IAddr <= (others => '0');
                RFAddr <= (others => '0');
            else
                State <= State_next;
                count <= count_next;
                DataBuf <= DataBuf_next;
                IAddr <= IAddr_next;
                RFAddr <= RFAddr_next;
            end if;
        end if;
    end process reg;
end rtl;