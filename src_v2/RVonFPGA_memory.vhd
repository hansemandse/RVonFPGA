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
--              : BRAM such that data operations have priority over instruction fetches. The
--              : memory also implements a "back door" UART which is not mapped into the
--              : processor's address space.
--              |
-- Revision     : 1.0   (last updated April 5, 2019)
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
end memory;

architecture rtl of memory is
    -- Number of RAM blocks to be implemented
    constant NB_COL : integer := DATA_WIDTH / BLOCK_WIDTH;
    constant NB_LOG : natural := natural(log2(real(NB_COL)));
    -- Address width for the internal block RAMs
    constant ADDR_WIDTH_INT : natural := ADDR_WIDTH - NB_LOG;

    -- Signals for pipelining the controls
    signal IMemOp_p, DMemOp_p, UMemOp_p : mem_op_t;
    signal IAddr_p, DAddr_p, UAddr_p : std_logic_vector(NB_LOG-1 downto 0);

    -- Array for storing byte-wide write enables for the internal block RAMs
    type we_t is array(NB_COL-1 downto 0) of std_logic;
    signal WEArraya, WEArrayb : we_t;

    -- Array for storing addresses for the internal block RAMs
    type addr_a_t is array(NB_COL-1 downto 0) of std_logic_vector(ADDR_WIDTH_INT-1 downto 0);
    signal AddrArraya, AddrArrayb : addr_a_t;

    -- Array for storing individual bytes to be written to block RAM
    type data_a_t is array(NB_COL-1 downto 0) of std_logic_vector(BLOCK_WIDTH-1 downto 0);
    signal DataInArraya, DataOutArraya, DataInArrayb, DataOutArrayb : data_a_t;

    -- The block RAM component
    component bram_init
        generic (
            DATA_WIDTH : natural := BYTE_WIDTH;
            ADDR_WIDTH : natural := ADDR_WIDTH_INT;
            TEST_FILE : string := TEST_FILE;
            NO_RAMS, RAM_NO : integer
        );
        port (
            -- Control ports
            clk, reset, wea, web : in std_logic;
            -- Data ports
            addra, addrb : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            data_ina, data_inb : in std_logic_vector(DATA_WIDTH-1 downto 0);
            data_outa, data_outb : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
begin
    -- Generating the data input to the memory based on address and operation type
    gen_control : for i in 0 to NB_COL-1 generate
        -- Generating the interface to the pipeline (using port a on the RAMs)
        pip : process (all)
            variable LowerBits : natural;
            variable Addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
            variable Data : std_logic_vector(DATA_WIDTH-1 downto 0);
            variable MemOp : mem_op_t;
        begin
            -- Selecting which operation to perform first - data memory operations
            -- first and instruction memory operations third
            sel : if (DMemOP /= MEM_NOP) then
                Addr := DAddr;
                Data := DWriteData;
                MemOp := DMemOp;
            else
                Addr := IAddr;
                Data := IWriteData;
                MemOp := IMemOp;
            end if sel;
            LowerBits := to_integer(unsigned(Addr(NB_LOG-1 downto 0)));
            
            -- Delivering data to the block RAMs
            DataInArraya(i) <= Data(((to_integer(to_unsigned(i-LowerBits, NB_LOG)))+1)*BLOCK_WIDTH-1 
                             downto (to_integer(to_unsigned(i-LowerBits, NB_LOG)))*BLOCK_WIDTH);

            -- Delivering addresses to the block RAMs
            addra : if (LowerBits > i) then
                -- Address should be one higher
                AddrArraya(i) <= std_logic_vector(unsigned(Addr(ADDR_WIDTH-1 downto NB_LOG)) + 1);
            else
                -- Address is simply the given address divided by the number of columns
                AddrArraya(i) <= Addr(ADDR_WIDTH-1 downto NB_LOG);
            end if addra;

            -- Delivering write enables to the block RAMs
            we : case (MemOp) is
                when MEM_SB =>
                    -- Enable only one of the array positions
                    if (LowerBits = i) then
                        WEArraya(i) <= '1';
                    else
                        WEArraya(i) <= '0';
                    end if;
                when MEM_SH =>
                    -- Enable two of the array positions
                    if (LowerBits = i or i = to_integer(to_unsigned(LowerBits+1, NB_LOG))) then
                        WEArraya(i) <= '1';
                    else
                        WEArraya(i) <= '0';
                    end if;
                when MEM_SW =>
                    -- Enable four of the array positions
                    if (i = LowerBits or i = to_integer(to_unsigned(LowerBits+1, NB_LOG)) or 
                        i = to_integer(to_unsigned(LowerBits+2, NB_LOG)) or 
                        i = to_integer(to_unsigned(LowerBits+3, NB_LOG))) then
                        WEArraya(i) <= '1';
                    else
                        WEArraya(i) <= '0';
                    end if;
                when MEM_SD =>
                    -- Enable all the array positions
                    WEArraya(i) <= '1';
                when others => 
                    -- The memory operation must be of read type or NOP
                    WEArraya(i) <= '0';
            end case we;
        end process pip;

        -- Generating the interface to the UART (using port b on the RAMs)
        uart : process (all) 
            variable LowerBits : natural;
        begin
            LowerBits := to_integer(unsigned(UAddr(NB_LOG-1 downto 0)));

            -- Delivering data to the block RAMs
            DatainArrayb(i) <= UWriteData(((to_integer(to_unsigned(i-LowerBits, NB_LOG)))+1)*BLOCK_WIDTH-1 
                                    downto (to_integer(to_unsigned(i-LowerBits, NB_LOG)))*BLOCK_WIDTH);
            
            -- Delivering addresses to the block RAMs
            addr : if (LowerBits > i) then
                AddrArrayb(i) <= std_logic_vector(unsigned(UAddr(ADDR_WIDTH-1 downto NB_LOG)) + 1);
            else
                AddrArrayb(i) <= UAddr(ADDR_WIDTH-1 downto NB_LOG);
            end if addr;

            -- Delivering write enables to the block RAMs
            we : case (UMemOp) is
                when MEM_SB =>
                    -- Enable only one of the array positions
                    if (LowerBits = i) then
                        WEArrayb(i) <= '1';
                    else
                        WEArrayb(i) <= '0';
                    end if;
                when MEM_SH =>
                    -- Enable two of the array positions
                    if (LowerBits = i or i = to_integer(to_unsigned(LowerBits+1, NB_LOG))) then
                        WEArrayb(i) <= '1';
                    else
                        WEArrayb(i) <= '0';
                    end if;
                when MEM_SW =>
                    -- Enable four of the array positions
                    if (i = LowerBits or i = to_integer(to_unsigned(LowerBits+1, NB_LOG)) or 
                        i = to_integer(to_unsigned(LowerBits+2, NB_LOG)) or 
                        i = to_integer(to_unsigned(LowerBits+3, NB_LOG))) then
                        WEArrayb(i) <= '1';
                    else
                        WEArrayb(i) <= '0';
                    end if;
                when MEM_SD =>
                    -- Enable all the array positions
                    WEArrayb(i) <= '1';
                when others => 
                    -- The memory operation must be of read type or NOP
                    WEArrayb(i) <= '0';
            end case we;
        end process uart;
    end generate gen_control;

    -- Generating the ready signals
    IReady <= '1' when (DMemOp = MEM_NOP) else '0';
    DReady <= '1';
    UReady <= '1';

    -- Generating the data output to the pipeline or the UART based on address
    -- and operation type of the pipelined signals
    gen_out : process (all)
        variable LowerBits : natural;
        variable MemOp : mem_op_t;
        variable ReadData : std_logic_vector(DATA_WIDTH-1 downto 0);
    begin
        sel : if (DMemOp_p /= MEM_NOP) then
            LowerBits := to_integer(unsigned(DAddr_p));
            MemOp := DMemOp_p;
            IReadData <= (others => '0');
            DReadData <= ReadData;
        else
            LowerBits := to_integer(unsigned(IAddr_p));
            MemOp := IMemOp_p;
            IReadData <= ReadData;
            DReadData <= (others => '0');
        end if;
        -- Outputs to the pipeline are sign-extended
        pip : case (MemOp) is
            when MEM_LB =>
                ReadData := (others => DataOutArraya(LowerBits)(7));
                ReadData(BLOCK_WIDTH-1 downto 0) := DataOutArraya(LowerBits);
            when MEM_LBU =>
                ReadData := (others => '0');
                ReadData(BLOCK_WIDTH-1 downto 0) := DataOutArraya(LowerBits);
            when MEM_LH =>
                ReadData := (others => DataOutArraya(to_integer(to_unsigned(LowerBits+1, NB_LOG)))(7));
                ReadData(BLOCK_WIDTH-1 downto 0) := DataOutArraya(LowerBits);
                ReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
            when MEM_LHU =>
                ReadData := (others => '0');
                ReadData(BLOCK_WIDTH-1 downto 0) := DataOutArraya(LowerBits);
                ReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
            when MEM_LW =>
                ReadData := (others => DataOutArraya(to_integer(to_unsigned(LowerBits+3, NB_LOG)))(7));
                ReadData(BLOCK_WIDTH-1 downto 0) := DataOutArraya(LowerBits);
                ReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
                ReadData(3*BLOCK_WIDTH-1 downto 2*BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+2, NB_LOG)));
                ReadData(4*BLOCK_WIDTH-1 downto 3*BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+3, NB_LOG)));
            when MEM_LWU =>
                ReadData := (others => '0');
                ReadData(BLOCK_WIDTH-1 downto 0) := DataOutArraya(LowerBits);
                ReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
                ReadData(3*BLOCK_WIDTH-1 downto 2*BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+2, NB_LOG)));
                ReadData(4*BLOCK_WIDTH-1 downto 3*BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+3, NB_LOG)));
            when MEM_LD =>
                ReadData(BLOCK_WIDTH-1 downto 0) := DataOutArraya(LowerBits);
                ReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
                ReadData(3*BLOCK_WIDTH-1 downto 2*BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+2, NB_LOG)));
                ReadData(4*BLOCK_WIDTH-1 downto 3*BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+3, NB_LOG)));
                ReadData(5*BLOCK_WIDTH-1 downto 4*BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+4, NB_LOG)));
                ReadData(6*BLOCK_WIDTH-1 downto 5*BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+5, NB_LOG)));
                ReadData(7*BLOCK_WIDTH-1 downto 6*BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+6, NB_LOG)));
                ReadData(8*BLOCK_WIDTH-1 downto 7*BLOCK_WIDTH) := DataOutArraya(to_integer(to_unsigned(LowerBits+7, NB_LOG)));
            when others =>
                ReadData := (others => '0');
        end case pip;


        -- Outputs to the UART are not sign-extended
        LowerBits := to_integer(unsigned(UAddr_p));
        UReadData <= (others => '0');
        uart : case (UMemOp_p) is
            when MEM_LB | MEM_LBU =>
                UReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArrayb(LowerBits);
            when MEM_LH | MEM_LHU =>
                UReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArrayb(LowerBits);
                UReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) <= DataOutArrayb(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
            when MEM_LW | MEM_LWU =>
                UReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArrayb(LowerBits);
                UReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) <= DataOutArrayb(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
                UReadData(3*BLOCK_WIDTH-1 downto 2*BLOCK_WIDTH) <= DataOutArrayb(to_integer(to_unsigned(LowerBits+2, NB_LOG)));
                UReadData(4*BLOCK_WIDTH-1 downto 3*BLOCK_WIDTH) <= DataOutArrayb(to_integer(to_unsigned(LowerBits+3, NB_LOG)));
            when MEM_LD =>
                UReadData(BLOCK_WIDTH-1 downto 0) <= DataOutArrayb(LowerBits);
                UReadData(2*BLOCK_WIDTH-1 downto BLOCK_WIDTH) <= DataOutArrayb(to_integer(to_unsigned(LowerBits+1, NB_LOG)));
                UReadData(3*BLOCK_WIDTH-1 downto 2*BLOCK_WIDTH) <= DataOutArrayb(to_integer(to_unsigned(LowerBits+2, NB_LOG)));
                UReadData(4*BLOCK_WIDTH-1 downto 3*BLOCK_WIDTH) <= DataOutArrayb(to_integer(to_unsigned(LowerBits+3, NB_LOG)));
                UReadData(5*BLOCK_WIDTH-1 downto 4*BLOCK_WIDTH) <= DataOutArrayb(to_integer(to_unsigned(LowerBits+4, NB_LOG)));
                UReadData(6*BLOCK_WIDTH-1 downto 5*BLOCK_WIDTH) <= DataOutArrayb(to_integer(to_unsigned(LowerBits+5, NB_LOG)));
                UReadData(7*BLOCK_WIDTH-1 downto 6*BLOCK_WIDTH) <= DataOutArrayb(to_integer(to_unsigned(LowerBits+6, NB_LOG)));
                UReadData(8*BLOCK_WIDTH-1 downto 7*BLOCK_WIDTH) <= DataOutArrayb(to_integer(to_unsigned(LowerBits+7, NB_LOG)));
            when others =>
                UReadData <= (others => '0');
        end case uart;
    end process gen_out;

    -- Pipelining the control signals
    reg : process (all)
    begin
        if rising_edge(clk) then
            if (reset = '1') then
                IMemOp_p <= MEM_NOP;
                DMemOp_p <= MEM_NOP;
                UMemOp_p <= MEM_NOP;
                IAddr_p <= (others => '0');
                DAddr_p <= (others => '0');
                UAddr_p <= (others => '0');
            else
                IMemOp_p <= IMemOp;
                DMemOp_p <= DMemOp;
                UMemOp_p <= UMemOp;
                IAddr_p <= IAddr(NB_LOG-1 downto 0);
                DAddr_p <= DAddr(NB_LOG-1 downto 0);
                UAddr_p <= UAddr(NB_LOG-1 downto 0);
            end if;
        end if;
    end process;

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
            wea => WEArraya(i),
            web => WEArrayb(i),
            addra => AddrArraya(i),
            addrb => AddrArrayb(i),
            data_ina => DataInArraya(i),
            data_outa => DataOutArraya(i),
            data_inb => DataInArrayb(i),
            data_outb => DataOutArrayb(i)
        );
    end generate;
end rtl;