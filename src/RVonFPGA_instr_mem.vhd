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
--              : This entity represents the instruction memory of the pipeline.
--              |
-- Revision     : 1.0   (last updated March 7, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

library work;
use work.includes.all;

entity instr_mem is
    generic (
        BLOCK_WIDTH : natural := BYTE_WIDTH;
        ADDR_WIDTH : natural := PC_WIDTH;
        TEST_FILE : string := TEST_FILE
    );
    port (
        -- Control ports
        MemWrite, clk, reset : in std_logic;
        ImemOp : in imem_op_t;
        -- Read port
        ReadAddress : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        ReadData : out std_logic_vector(31 downto 0);
        -- Write port
        WriteAddress : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        WriteData : in std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end instr_mem;

architecture rtl of instr_mem is
    -- Number of RAM blocks to be implemented
    constant NB_COL : integer := DATA_WIDTH / BLOCK_WIDTH;
    constant NB_LOG : natural := natural(log2(real(NB_COL)));
    -- Address width for the internal block RAMs
    constant ADDR_WIDTH_INT : natural := ADDR_WIDTH - NB_LOG;

    -- Signal for the pipelined control
    signal Address_p : std_logic_vector(ADDR_WIDTH-1 downto 0);

    -- Array for storing byte-wide write enables for the internal block RAMs
    type we_t is array(NB_COL-1 downto 0) of std_logic;
    signal WEArray : we_t;

    -- Array for storing addresses for the internal block RAMs
    type addr_a_t is array(NB_COL-1 downto 0) of std_logic_vector(ADDR_WIDTH_INT-1 downto 0);
    signal RAddrArray, WAddrArray : addr_a_t;

    -- Array for storing individual bytes to be written to block RAM
    type data_a_t is array(NB_COL-1 downto 0) of std_logic_vector(BLOCK_WIDTH-1 downto 0);
    signal DataOutArray, DataInArray : data_a_t;

    -- The block ram component
    component bram_init
        generic (
            DATA_WIDTH : natural := BLOCK_WIDTH;
            ADDR_WIDTH : natural := ADDR_WIDTH_INT;
            TEST_FILE : string;
            NO_RAMS, RAM_NO : integer
        );
        port (
            -- Control ports
            we, clk, reset : in std_logic;
            -- Data ports
            raddr, waddr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
begin
    -- TODO: Implement smart addressing such that the RAM is not activated/given
    -- new addresses every clock cycle if accesses follow each other

    -- Generating all of the control logic running the block RAMs
   gen_control : for i in 0 to NB_COL-1 generate
        process (all)
            variable LowerBits : integer;
        begin
            -- Firstly, managing writes to the block RAMs
            LowerBits := to_integer(unsigned(WriteAddress(NB_LOG-1 downto 0)));
            -- Delivering write addresses to the block RAMs
            if (LowerBits > i) then
                WAddrArray(i) <= std_logic_vector(unsigned(WriteAddress(ADDR_WIDTH-1 downto NB_LOG)) + 1);
            else
                WAddrArray(i) <= std_logic_vector(unsigned(WriteAddress(ADDR_WIDTH-1 downto NB_LOG)));
            end if;

            -- Data is stored little endian and data in is wrapped around 
            -- Delivering data to the block RAMs
            DataInArray(i) <= WriteData(((to_integer(to_unsigned(i-LowerBits, NB_LOG)))+1)*BLOCK_WIDTH-1 
                                    downto (to_integer(to_unsigned(i-LowerBits, NB_LOG)))*BLOCK_WIDTH);

            -- Delivering write enable signals to the block RAMs
            if (MemWrite = '1') then
                case (ImemOp) is
                    when MEM_SB =>
                        -- Enable only one of the array positions
                        if (i = LowerBits) then
                            WEArray(i) <= '1';
                        else
                            WEArray(i) <= '0';
                        end if;
                    when MEM_SW =>
                        -- Enable four of the array positions
                        if (i = LowerBits or i = to_integer(to_unsigned(LowerBits+1, NB_LOG)) or 
                            i = to_integer(to_unsigned(LowerBits+2, NB_LOG)) or 
                            i = to_integer(to_unsigned(LowerBits+3, NB_LOG))) then
                            WEArray(i) <= '1';
                        else
                            WEArray(i) <= '0';
                        end if;
                    when others =>
                        -- Given that MemWrite is '1', ImemOp must be MEM_SD when entering this case
                        WEArray(i) <= '1';
                end case;
            else
                WEArray(i) <= '0';
            end if;
            
            -- Secondly, managing reads from the block RAMs
            LowerBits := to_integer(unsigned(ReadAddress(NB_LOG-1 downto 0)));
            -- Delivering read addresses to the block RAMs
            if (LowerBits > i) then
                RAddrArray(i) <= std_logic_vector(unsigned(ReadAddress(ADDR_WIDTH-1 downto NB_LOG)) + 1);
            else
                RAddrArray(i) <= ReadAddress(ADDR_WIDTH-1 downto NB_LOG);
            end if;
        end process;
    end generate gen_control;

    gen_out : process (all)
        variable LowerBits : integer;
    begin
        LowerBits := to_integer(unsigned(Address_p(NB_LOG-1 downto 0)));
        -- This memory constantly outputs a single instruction
        ReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArray(LowerBits);
        ReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
        ReadData(3*BLOCK_WIDTH-1 downto 2*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+2, NB_LOG)));
        ReadData(4*BLOCK_WIDTH-1 downto 3*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+3, NB_LOG)));
    end process gen_out;

    reg : process (all)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                Address_p <= (others => '0');
            else
                Address_p <= ReadAddress;
            end if;
        end if;
    end process reg;

    -- Generating the required number of block RAMs
    gen_brams : for i in 0 to NB_COL-1 generate
        brams : bram_init generic map (
            TEST_FILE => TEST_FILE,
            NO_RAMS => NB_COL,
            RAM_NO => i
        )
        port map (
            clk => clk,
            reset => reset,
            we => WEArray(i),
            raddr => RAddrArray(i),
            waddr => WAddrArray(i),
            data_in => DataInArray(i),
            data_out => DataOutArray(i)
        );
    end generate gen_brams;
end rtl;