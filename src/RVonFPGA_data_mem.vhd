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
--              : This entity represents the data memory of the pipeline.
--              |
-- Revision     : 1.1   (last updated February 25, 2019)
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

entity data_mem is
    generic (
        BLOCK_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 12
    );
    port (
        -- Control ports
        MemRead, MemWrite, clk, reset : in std_logic;
        MemOp : in mem_op_t;
        -- Data ports
        Address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        WriteData : in std_logic_vector(DATA_WIDTH-1 downto 0);
        ReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end data_mem;

architecture rtl of data_mem is
    -- Number of RAM blocks to be implemented
    constant NB_COL : integer := DATA_WIDTH / BLOCK_WIDTH;
    constant NB_LOG : integer := integer(log2(real(NB_COL)));
    -- Address width for the internal block RAMs
    constant ADDR_WIDTH_INT : integer := ADDR_WIDTH - NB_LOG;

    -- Signals for the pipelined control
    signal MemRead_p : std_logic;
    signal MemOp_p : mem_op_t;
    signal Address_p : std_logic_vector(NB_LOG-1 downto 0);

    -- Array for storing byte-wide write enables for the internal block RAMs
    type we_t is array(NB_COL-1 downto 0) of std_logic;
    signal WEArray : we_t;

    -- Array for storing addresses for the internal block RAMs
    type addr_a_t is array(NB_COL-1 downto 0) of std_logic_vector(ADDR_WIDTH_INT-1 downto 0);
    signal AddrArray : addr_a_t;

    -- Array for storing individual bytes to be written to block RAM
    type data_a_t is array(NB_COL-1 downto 0) of std_logic_vector(BLOCK_WIDTH-1 downto 0);
    signal DataInArray, DataOutArray : data_a_t;

    -- The block ram component
    component bram
        generic (
            DATA_WIDTH : integer := BLOCK_WIDTH;
            ADDR_WIDTH : integer := ADDR_WIDTH_INT
        );
        port (
            -- Control ports
            we, clk, reset : in std_logic;
            -- Data ports
            addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
begin
    -- Generating all of the control logic running the block RAMs
   gen_control : for i in 0 to NB_COL-1 generate
        process (all)
            variable LowerBits : integer;
        begin
            LowerBits := to_integer(unsigned(Address(NB_LOG-1 downto 0)));
            -- Delivering addresses to the block RAMs
            if (LowerBits > i) then
                -- Address should be one higher
                AddrArray(i) <= std_logic_vector(unsigned(Address(ADDR_WIDTH-1 downto NB_LOG)) + 1);
            else
                -- Address is simply the given address divived by number of columns
                AddrArray(i) <= Address(ADDR_WIDTH-1 downto NB_LOG);
            end if;

            -- Data is stored little endian and data in is wrapped around 
            -- Delivering data to the block RAMs
            DataInArray(i) <= WriteData(((to_integer(to_unsigned(i-LowerBits, NB_LOG)))+1)*BLOCK_WIDTH-1 
                                    downto (to_integer(to_unsigned(i-LowerBits, NB_LOG)))*BLOCK_WIDTH);

            -- Delivering write enables to the block RAMs
            if (MemWrite = '1') then
                case (MemOp) is
                    when MEM_SB =>
                        -- Enable only one of the array positions
                        if (i = LowerBits) then
                            WEArray(i) <= '1';
                        else
                            WEArray(i) <= '0';
                        end if;
                    when MEM_SH =>
                        -- Enable only two of the array positions
                        if (i = LowerBits or i = to_integer(to_unsigned(LowerBits+1, NB_LOG))) then
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
                        -- Reaching this point means that MemOp must be MEM_SD as MemWrite = '1'
                        -- and MemOp is none of the above
                        -- Enable all array positions
                        WEArray(i) <= '1';
                end case;
            else
                WEArray(i) <= '0';
            end if;
        end process;
    end generate gen_control;

    gen_out : process (all)
        variable LowerBits : integer;
    begin
        -- Generating the output data from the results
        -- The following code may not look as pretty as it would be to have it be written in
        -- std_logic_vectors (such as (BLOCK_WIDTH-1 downto 0 => DataOutArray(i))), but that
        -- implementation unfortunately does not work when indexing several array positions
        -- within a single assignment
        LowerBits := to_integer(unsigned(Address_p));
        if (MemRead_p = '1') then
            case (MemOp_p) is
                when MEM_LB =>
                    ReadData <= (others => DataOutArray(LowerBits)(7));
                    ReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArray(LowerBits);
                when MEM_LBU =>
                    ReadData <= (others => '0');
                    ReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArray(LowerBits);
                when MEM_LH =>
                    ReadData <= (others => DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)))(7));
                    ReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArray(LowerBits);
                    ReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
                when MEM_LHU =>
                    ReadData <= (others => '0');
                    ReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArray(LowerBits);
                    ReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
                when MEM_LW =>
                    ReadData <= (others => DataOutArray(to_integer(to_unsigned(LowerBits+3, NB_LOG)))(7));
                    ReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArray(LowerBits);
                    ReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
                    ReadData(3*BLOCK_WIDTH-1 downto 2*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+2, NB_LOG)));
                    ReadData(4*BLOCK_WIDTH-1 downto 3*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+3, NB_LOG)));
                when MEM_LWU =>
                    ReadData <= (others => '0');
                    ReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArray(LowerBits);
                    ReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
                    ReadData(3*BLOCK_WIDTH-1 downto 2*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+2, NB_LOG)));
                    ReadData(4*BLOCK_WIDTH-1 downto 3*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+3, NB_LOG)));
                when others =>
                    -- Reaching this point means that MemOp_p must be MEM_LD as MemRead = '1'
                    -- and MemOp_p is none of the above
                    ReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArray(LowerBits);
                    ReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
                    ReadData(3*BLOCK_WIDTH-1 downto 2*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+2, NB_LOG)));
                    ReadData(4*BLOCK_WIDTH-1 downto 3*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+3, NB_LOG)));
                    ReadData(5*BLOCK_WIDTH-1 downto 4*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+4, NB_LOG)));
                    ReadData(6*BLOCK_WIDTH-1 downto 5*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+5, NB_LOG)));
                    ReadData(7*BLOCK_WIDTH-1 downto 6*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+6, NB_LOG)));
                    ReadData(8*BLOCK_WIDTH-1 downto 7*BLOCK_WIDTH) <= DataOutArray(to_integer(to_unsigned(LowerBits+7, NB_LOG)));
            end case;
        else
            ReadData <= (others => '0');
        end if;
    end process gen_out;
    
    -- Pipelining the address to ensure correct read outs of data as the block RAM
    -- performs synchronous reads
    reg : process (all)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                MemRead_p <= '0';
                MemOp_p <= MEM_NOP;
                Address_p <= (others => '0');
            else
                MemRead_p <= MemRead;
                MemOp_p <= MemOp;
                Address_p <= Address(NB_LOG-1 downto 0);
            end if;
        end if;
    end process reg;

    -- Generating the required number of block RAMs
    gen_brams : for i in 0 to NB_COL-1 generate
        brams : bram port map (
            clk => clk,
            reset => reset,
            we => WEArray(i),
            addr => AddrArray(i),
            data_in => DataInArray(i),
            data_out => DataOutArray(i)
        );
    end generate gen_brams;
end rtl;