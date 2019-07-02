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
--              : This entity represents the memory of the processor. It has a simple memory
--              : controller that connects two memory interfaces from the pipeline to the
--              : BRAM such that data operations have priority over instruction fetches. It
--              : holds a small constant bootloader as well as a few memory mapped I/O units.
--              |
-- Revision     : 2.0   (last updated June 28, 2019)
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

entity memory is
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
end memory;

architecture rtl of memory is
    -- Number of RAM blocks to be implemented
    constant NB_COL : natural := DATA_WIDTH / BLOCK_WIDTH;
    constant NB_LOG : natural := natural(log2(real(NB_COL)));
    -- Address width for the internal block RAMs
    constant ADDR_WIDTH_INT : natural := ADDR_WIDTH - NB_LOG;

    -- Signals for pipelining the controls
    signal MemOp_p : mem_op_t;
    signal Addr_p : std_logic_vector(NB_LOG-1 downto 0);

    -- Array for storing byte-wide write enables for the internal block RAMs
    type we_t is array(NB_COL-1 downto 0) of std_logic;
    signal WEArray : we_t;

    -- Array for storing addresses for the internal block RAMs
    type addr_a_t is array(NB_COL-1 downto 0) of std_logic_vector(ADDR_WIDTH_INT-1 downto 0);
    signal AddrArray : addr_a_t;

    -- Array for storing individual bytes to be written to block RAM
    type data_a_t is array(NB_COL-1 downto 0) of std_logic_vector(BLOCK_WIDTH-1 downto 0);
    signal DataInArray, DataOutArray : data_a_t;

    -- The block RAM component
    component bram
        generic (
            DATA_WIDTH : natural := BYTE_WIDTH;
            ADDR_WIDTH : natural := ADDR_WIDTH_INT;
            NO_RAMS, RAM_NO : integer
        );
        port (
            -- Control ports
            clk, reset, we : in std_logic;
            -- Data ports
            addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
begin
    -- Generating the data input to the memory based on address and operation type
    gen_control : for i in 0 to NB_COL-1 generate
        -- Generating the interface to the pipeline (using port a on the RAMs)
        pip : process (all)
            variable LowerBits : natural;
        begin
            LowerBits := to_integer(unsigned(Addr(NB_LOG-1 downto 0)));
            
            -- Delivering data to the block RAMs
            DataInArray(i) <= WriteData(((to_integer(to_unsigned(i-LowerBits, NB_LOG)))+1)*BLOCK_WIDTH-1 
                              downto (to_integer(to_unsigned(i-LowerBits, NB_LOG)))*BLOCK_WIDTH);

            -- Delivering addresses to the block RAMs
            addra : if (LowerBits > i) then
                -- Address should be one higher
                AddrArray(i) <= std_logic_vector(unsigned(Addr(ADDR_WIDTH-1 downto NB_LOG)) + 1);
            else
                -- Address is simply the given address divided by the number of columns
                AddrArray(i) <= Addr(ADDR_WIDTH-1 downto NB_LOG);
            end if addra;

            -- Delivering write enables to the block RAMs
            we : case (MemOp) is
                when MEM_SB =>
                    -- Enable only one of the array positions
                    if (LowerBits = i) then
                        WEArray(i) <= '1';
                    else
                        WEArray(i) <= '0';
                    end if;
                when MEM_SH =>
                    -- Enable two of the array positions
                    if (LowerBits = i or i = to_integer(to_unsigned(LowerBits+1, NB_LOG))) then
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
                when MEM_SD =>
                    -- Enable all the array positions
                    WEArray(i) <= '1';
                when others => 
                    -- The memory operation must be of read type or NOP
                    WEArray(i) <= '0';
            end case we;
        end process pip;
    end generate gen_control;

    -- Generating the data output to the pipeline
    gen_out : process (all)
        variable LowerBits : natural;
    begin
        LowerBits := to_integer(unsigned(Addr_p(NB_LOG-1 downto 0)));
        -- Outputs to the pipeline are sign-extended
        pip : case (MemOp_p) is
            when MEM_LB =>
                ReadData <= (others => DataOutArray(LowerBits)(7));
                ReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArray(LowerBits);
            when MEM_LBU =>
                ReadData <= (others => '0');
                ReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArray(LowerBits);
            when MEM_LH =>
                ReadData <= (others => DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)))(7));
                ReadData(2*BLOCK_WIDTH-1 downto 0) <= DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)))
                                                    & DataOutArray(LowerBits);
            when MEM_LHU =>
                ReadData <= (others => '0');
                ReadData(2*BLOCK_WIDTH-1 downto 0) <= DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG))) 
                                                    & DataOutArray(LowerBits);  
            when MEM_LW =>
                ReadData <= (others => DataOutArray(to_integer(to_unsigned(LowerBits+3, NB_LOG)))(7));
                ReadData(4*BLOCK_WIDTH-1 downto 0) <= DataOutArray(to_integer(to_unsigned(LowerBits+3, NB_LOG)))
                                                    & DataOutArray(to_integer(to_unsigned(LowerBits+2, NB_LOG)))
                                                    & DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)))
                                                    & DataOutArray(LowerBits);
            when MEM_LWU =>
                ReadData <= (others => '0');
                ReadData(4*BLOCK_WIDTH-1 downto 0) <= DataOutArray(to_integer(to_unsigned(LowerBits+3, NB_LOG)))
                                                    & DataOutArray(to_integer(to_unsigned(LowerBits+2, NB_LOG)))
                                                    & DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)))
                                                    & DataOutArray(LowerBits);
            when MEM_LD =>
                ReadData(8*BLOCK_WIDTH-1 downto 0) <= DataOutArray(to_integer(to_unsigned(LowerBits+7, NB_LOG)))
                                                    & DataOutArray(to_integer(to_unsigned(LowerBits+6, NB_LOG)))
                                                    & DataOutArray(to_integer(to_unsigned(LowerBits+5, NB_LOG)))
                                                    & DataOutArray(to_integer(to_unsigned(LowerBits+4, NB_LOG)))
                                                    & DataOutArray(to_integer(to_unsigned(LowerBits+3, NB_LOG)))
                                                    & DataOutArray(to_integer(to_unsigned(LowerBits+2, NB_LOG)))
                                                    & DataOutArray(to_integer(to_unsigned(LowerBits+1, NB_LOG)))
                                                    & DataOutArray(LowerBits);
            when others =>
                ReadData <= (others => '0');
        end case pip;
    end process gen_out;

    -- Pipelining the control signals
    reg : process (all)
    begin
        if rising_edge(clk) then
            Addr_p <= Addr(NB_LOG-1 downto 0);
            if (reset = '1') then
                MemOp_p <= MEM_NOP;
            else
                MemOp_p <= MemOp;
            end if;
        end if;
    end process;

    -- Generating the required number of block RAMs
    gen_brams : for i in 0 to NB_COL-1 generate
        brams : bram generic map (
            NO_RAMS => NB_COL,
            RAM_NO => i
        )
        port map (
            clk => clk,
            reset => reset,
            we => WEArray(i),
            addr => AddrArray(i),
            data_in => DataInArray(i),
            data_out => DataOutArray(i)
        );
    end generate gen_brams;
end rtl;