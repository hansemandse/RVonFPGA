-- ***********************************************************************
--              |
-- Title        : Implementation and Optimization of a RISC-V Processor on
--              : a FPGA
--              |
-- Developers   : Hans Jakob Damsgaard, Technical University of Denmark
--              : s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
--              |
-- Purpose      : This file is a part of a full system implemented as part
--              : of a bachelor's thesis at DTU. The thesis is written in
--              : cooperation with the Institute of Mathematics and
--              : Computer Science.
--              : This entity represents the bootloader ROM of the system.
--              |
-- Revision     : 1.0   (last updated June 29, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- ***********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity rom is
    port (
        clk, reset : in std_logic;
        -- Memory interface
        MemOp : in mem_op_t;
        Addr : in std_logic_vector(11 downto 0);
        ReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end rom;

architecture rtl of rom is
    constant ADDR_WIDTH : natural := 12;
    signal MemOp_p : mem_op_t;
    signal LowerBits : natural;

    type data_a_t is array(1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal DataArray : data_a_t;

    -- Generated constant ROM component
    component rom_gen is
        port (
            clk, reset : in std_logic;
            -- Memory interface
            Addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            ReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;
begin
    comb : process (all)
        variable Data : std_logic_vector(2*DATA_WIDTH-1 downto 0);
    begin
        Data := DataArray(1) & DataArray(0);
        case (MemOp_p) is
            when MEM_LB =>
                ReadData <= (others => Data((LowerBits + 1)*BYTE_WIDTH-1));
                ReadData(BYTE_WIDTH-1 downto 0) <= Data((LowerBits + 1)*BYTE_WIDTH-1 downto LowerBits*BYTE_WIDTH);
            when MEM_LBU =>
                ReadData <= (others => '0');
                ReadData(BYTE_WIDTH-1 downto 0) <= Data((LowerBits + 1)*BYTE_WIDTH-1 downto LowerBits*BYTE_WIDTH);
            when MEM_LH =>
                ReadData <= (others => Data((LowerBits + 2)*BYTE_WIDTH-1));
                ReadData(2*BYTE_WIDTH-1 downto 0) <= Data((LowerBits + 2)*BYTE_WIDTH-1 downto LowerBits*BYTE_WIDTH);
            when MEM_LHU =>
                ReadData <= (others => '0');
                ReadData(2*BYTE_WIDTH-1 downto 0) <= Data((LowerBits + 2)*BYTE_WIDTH-1 downto LowerBits*BYTE_WIDTH);
            when MEM_LW =>
                ReadData <= (others => Data((LowerBits + 4)*BYTE_WIDTH-1));
                ReadData(4*BYTE_WIDTH-1 downto 0) <= Data((LowerBits + 4)*BYTE_WIDTH-1 downto LowerBits*BYTE_WIDTH);
            when MEM_LWU =>
                ReadData <= (others => '0');
                ReadData(4*BYTE_WIDTH-1 downto 0) <= Data((LowerBits + 4)*BYTE_WIDTH-1 downto LowerBits*BYTE_WIDTH);
            when MEM_LD =>
                ReadData <= Data((LowerBits + 8)*BYTE_WIDTH-1 downto LowerBits*BYTE_WIDTH);
            when others =>
                ReadData <= (others => '0');
        end case;
    end process comb;

    reg : process (all)
    begin
        if (rising_edge(clk)) then
            LowerBits <= to_integer(unsigned(Addr(2 downto 0)));
            if (reset = '1') then
                MemOp_p <= MEM_NOP;
            else
                MemOp_p <= MemOp;
            end if;
        end if;
    end process reg;

    gen_roms : for i in 0 to 1 generate
        roms : rom_gen 
        port map (
            clk => clk,
            reset => reset,
            Addr => std_logic_vector(unsigned(Addr(11 downto 3)) & "000" + i*8),
            ReadData => DataArray(i)
        );
    end generate gen_roms;
end rtl;