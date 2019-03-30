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
--              : This is a testbench for the UART controller. Note that this entity must be
--              : simulated for extended periods of time (up to about 54 ms assuming a 10 ns
--              : clock period). This is due to the many states of the controller and the way
--              : it makes sure to fill out the entire instruction memory, once it starts
--              : downloading a test program.
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

entity controller_tb is
end controller_tb;

architecture rtl of controller_tb is
    -- Clock period in ns
    constant clk_p : time := 10 ns;
    -- Testing relevant constants
    constant UPLOAD_C : std_logic_vector(BYTE_WIDTH-1 downto 0) := x"72";
    constant DOWNLOAD_C : std_logic_vector(BYTE_WIDTH-1 downto 0) := x"77";
    constant RUN_C : std_logic_vector(BYTE_WIDTH-1 downto 0) := x"52";
    constant TEST_DW : std_logic_vector(DATA_WIDTH-1 downto 0) := x"0102030405060708";
    type register_file_t is array(0 to 2**RF_ADDR_WIDTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    constant TEST_RF : register_file_t := (TEST_DW, x"0101010101010101", x"0202020202020202", 
                               x"0303030303030303", x"0404040404040404", x"0505050505050505", 
                               x"0606060606060606", x"0707070707070707", x"0808080808080808", 
                               x"0909090909090909", x"0A0A0A0A0A0A0A0A", x"0B0B0B0B0B0B0B0B",
                               x"0C0C0C0C0C0C0C0C", x"0D0D0D0D0D0D0D0D", x"0E0E0E0E0E0E0E0E", 
                               x"0F0F0F0F0F0F0F0F", x"1010101010101010", x"1111111111111111",
                               x"1212121212121212", x"1313131313131313", x"1414141414141414",
                               x"1515151515151515", x"1616161616161616", x"1717171717171717",
                               x"1818181818181818", x"1919191919191919", x"1A1A1A1A1A1A1A1A",
                               x"1B1B1B1B1B1B1B1B", x"1C1C1C1C1C1C1C1C", x"1D1D1D1D1D1D1D1D",
                               x"1E1E1E1E1E1E1E1E", x"1F1F1F1F1F1F1F1F");

    -- Signals for interfacing the controller
    signal clk, reset, ImemWrite, pipcont : std_logic := '0';
    signal data_stream_out_stb, data_stream_out_ack, data_stream_in_stb : std_logic := '0';
    signal data_stream_out, data_stream_in : std_logic_vector(BYTE_WIDTH-1 downto 0) := (others => '0');
    signal RFRs : std_logic_vector(RF_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal ImemOp : imem_op_t := MEM_NOP;
    signal RFData, IWriteData : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal IWriteAddress : std_logic_vector(PC_WIDTH-1 downto 0) := (others => '0');

    -- The controller component declaration
    component controller is
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
    end component;
begin
    dut : controller
    port map (
        clk => clk,
        reset => reset,
        data_stream_out => data_stream_out,
        data_stream_out_stb => data_stream_out_stb,
        data_stream_out_ack => data_stream_out_ack,
        data_stream_in => data_stream_in,
        data_stream_in_stb => data_stream_in_stb,
        RFRs => RFRs,
        RFData => RFData,
        ImemWrite => ImemWrite,
        ImemOp => ImemOp,
        IWriteData => IWriteData,
        IWriteAddress => IWriteAddress,
        pipcont => pipcont
    );
    RFData <= TEST_RF(to_integer(unsigned(RFRs)));

    stimuli : process is
        variable expected : std_logic_vector(BYTE_WIDTH-1 downto 0);
    begin
        reset <= '1';
        wait until falling_edge(clk);
        reset <= '0';
        wait until falling_edge(clk);
        -- Controller enters the command state and it is ready to receive data

        -- Bring controller into the download state
        data_stream_in_stb <= '1';
        data_stream_in <= DOWNLOAD_C;
        wait until falling_edge(clk);
        -- Test reading in eight bytes of data and writing them to the instruction memory
        download : for i in 0 to DATA_WIDTH/BYTE_WIDTH-1 loop
            data_stream_in_stb <= '1';
            data_stream_in <= TEST_DW((i+1)*BYTE_WIDTH-1 downto i*BYTE_WIDTH);
            wait until falling_edge(clk);
            if (i /= 7) then
                for j in 0 to i loop
                    data_stream_in_stb <= '0';
                    wait until falling_edge(clk);
                end loop;
            end if;
        end loop download;
        -- Controller enters the download_store state
        assert IMemOp = MEM_SD report "Instruction memory operation incorrect!" severity FAILURE;
        assert IWriteData = TEST_DW report "Data output incorrect!" severity FAILURE;
        data_stream_in_stb <= '0';
        wait until falling_edge(clk);
        -- Controller sticks to the download state and waits for doublewords to fill out the entire
        -- instruction memory
        data_stream_in_stb <= '1';
        data_stream_in <= (others => '0');
        for i in 8 to 2**PC_WIDTH+(2**PC_WIDTH)/(DATA_WIDTH/BYTE_WIDTH)-1 loop
            wait until falling_edge(clk);
        end loop;
        -- Controller enters the command state again
        
        -- Bring controller into the upload state
        data_stream_in <= UPLOAD_C;
        wait until falling_edge(clk);
        -- Test reading out all data from the register file (here simulated as TEST_RF)
        upload : for i in 0 to 2**RF_ADDR_WIDTH-1 loop
            for j in 0 to DATA_WIDTH/BYTE_WIDTH-1 loop
                expected := TEST_RF(i)((j+1)*BYTE_WIDTH-1 downto j*BYTE_WIDTH);
                assert data_stream_out = expected report "Data output incorrect!" severity FAILURE;
                data_stream_out_ack <= '1';
                wait until falling_edge(clk);
            end loop;
            -- Skip over the upload_check state
            wait until falling_edge(clk);
        end loop upload;
        -- Controller enters the command state again

        -- Bring controller into the run state
        data_stream_in <= RUN_C;
        wait until falling_edge(clk);
        -- Test that the pipcont output is indeed '1'
        assert pipcont = '1' report "The pipeline control output is incorrect!" severity FAILURE;
        wait until falling_edge(clk);
        -- Controller enters the command state again

        std.env.stop(0);
    end process stimuli;

    clock : process is
    begin
        clk <= '1'; wait for clk_p/2;
        clk <= '0'; wait for clk_p/2;
    end process clock;
end rtl;