-- This architecture makes use of a counter for downloading and uploading instead
-- of using separate states
architecture rtl2 of controller is
    -- Constants for updating the states
    constant MEM_SIZE : natural := 2**MEM_ADDR_WIDTH;

    -- Control signal constants
    constant TEST_C : std_logic_vector(7 downto 0) := x"74"; -- Character is ASCII 't'
    constant UPLOAD_C : std_logic_vector(7 downto 0) := x"72"; -- Character is ASCII 'r'
    constant DOWNLOAD_C : std_logic_vector(7 downto 0) := x"77"; -- Character is ASCII 'w'
    constant CLEAR_C : std_logic_vector(7 downto 0) := x"63"; -- Character is ASCII 'c'
    constant REPLY_C : std_logic_vector(7 downto 0) := x"79"; -- Character is ASCII 'y'

    -- Counter for addressing the data buffer
    signal count, count_next : integer := 0;

    -- State type and related signals for the FSM
    type state_type is (start, clear, command, test, download, download_store,
                        upload_wait, upload, upload_check);
    signal State, State_next : state_type := start;

    -- Signals for addressing the memory
    signal Addr, Addr_next : std_logic_vector(ADDR_WIDTH-1 downto 0);

    -- Signals for the data buffer (works for both instruction memory and register file)
    type databuf_t is array(DATA_WIDTH/BYTE_WIDTH-1 downto 0) of std_logic_vector(BYTE_WIDTH-1 downto 0);
    signal DataBuf, DataBuf_next : databuf_t;
begin
    -- Connecting the output ports
    UAddr <= Addr;
    UWriteData <= DataBuf(7) & DataBuf(6) & DataBuf(5) & DataBuf(4)
                & DataBuf(3) & DataBuf(2) & DataBuf(1) & DataBuf(0);

    comb : process (all)
    begin
        -- Default assignments for all register related signals
        State_next <= State;
        count_next <= count;
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
                DataBuf_next <= (others => (others => '0'));
                Addr_next <= (others => '0');
                count_next <= 0;
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
                            State_next <= upload_wait;
                            Addr_next <= (others => '0');
                            count_next <= 0;
                        when DOWNLOAD_C =>
                            -- Start download of data from the PC to the FPGA
                            State_next <= download;
                            Addr_next <= (others => '0');
                            count_next <= 0;
                        when CLEAR_C =>
                            -- Clear the memory content
                            State_next <= clear;
                            Addr_next <= (others => '0');
                            DataBuf_next <= (others => (others => '0'));
                        when others =>
                            State_next <= command;
                    end case;
                end if;

            when clear => 
                -- Clear the entire instruction memory
                UMemOp <= MEM_SD;
                if (unsigned(Addr) = MEM_SIZE - DATA_WIDTH/BYTE_WIDTH) then
                    -- Entire memory has been reset
                    State_next <= command;
                else
                    -- More memory addresses remain
                    Addr_next <= std_logic_vector(unsigned(Addr) + DATA_WIDTH/BYTE_WIDTH);
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
                    DataBuf_next(count) <= data_stream_in;
                    if (count = DATA_WIDTH/BYTE_WIDTH-1) then
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
                UMemOp <= MEM_SD;
                if (unsigned(Addr) = MEM_SIZE - DATA_WIDTH/BYTE_WIDTH) then
                    -- All memory locations have been filled
                    State_next <= command;
                else
                    -- More memory locations are available
                    Addr_next <= std_logic_vector(unsigned(Addr) + DATA_WIDTH/BYTE_WIDTH);
                    State_next <= download;
                end if;
            
            when upload_wait => 
                -- Read data from the memory
                UMemOp <= MEM_LD;
                State_next <= upload;
            when upload => 
                -- Write data to the UART
                data_stream_out <= UReadData((count+1)*BYTE_WIDTH-1 downto count*BYTE_WIDTH);
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
                        UMemOp <= MEM_LD;
                        State_next <= upload;
                    end if;
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
                count <= 0;
                DataBuf <= (others => (others => '0'));
                Addr <= (others => '0');
            else
                State <= State_next;
                count <= count_next;
                DataBuf <= DataBuf_next;
                Addr <= Addr_next;
            end if;
        end if;
    end process reg;
end rtl2;
