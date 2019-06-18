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
--              : This entity represents a block-RAM of variable size used
--              : in the data memory and the instruction memory of the
--              : processor
--              |
-- Revision     : 1.2   (last updated April 7, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- ***********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use std.textio.all;

library work;
use work.includes.all;

entity bram_init is
    generic (
        DATA_WIDTH : natural := BYTE_WIDTH;
        ADDR_WIDTH : natural := 13;
        TEST_FILE : string := TEST_FILE;
        NO_RAMS, RAM_NO : integer := 1
    );
    port (
        -- Control ports
        wea, web, reset, clk : in std_logic;
        -- Data ports
        addra, addrb : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        data_ina, data_inb : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_outa, data_outb : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end bram_init;

architecture rtl of bram_init is
    constant ARRAY_WIDTH : natural := 2 ** ADDR_WIDTH;
    type ram_t is array(ARRAY_WIDTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Size of the entire memory used for index checking in the read function
    constant NB_COL : natural := natural(log2(real(NO_RAMS)));
    constant MEM_SIZE : natural := ARRAY_WIDTH * NO_RAMS;

    -- Function for reading a binary file and initializing each ram position accordingly
    impure function readFile return ram_t is
        file file_in : text open READ_MODE is TEST_FILE;
        variable c_line : line;
        variable c_buf : character := NUL;
        variable index : natural := 0;
        variable res : ram_t := (others => (others => '0'));
    begin
        if (INIT_RAM = '0') then
            return res;
        end if;
        -- Read all lines of the file and convert the characters to 8-bit std_logic_vectors
        -- such that they may be stored in the memory
        while (not endfile(file_in) and index < MEM_SIZE) loop
            -- Read a single line in the file and buffer it in c_ling
            readline(file_in, c_line);
            -- Read out all characters of c_line and convert and store them
            while (c_line'length > 0 and index < MEM_SIZE) loop
                read(c_line, c_buf);
                -- Store the character only if it goes in the ith memory block
                if (to_unsigned(index, NB_COL) = RAM_NO) then
                    res(index/NO_RAMS) := std_logic_vector(to_unsigned(character'pos(c_buf), DATA_WIDTH));
                end if;
                index := index + 1;
            end loop;
            -- File contained more than one line meaning that c_line missed a LF (0x0a in ASCII)
            if (not endfile(file_in) and to_unsigned(index, NB_COL) = RAM_NO 
                                     and index < MEM_SIZE) then
                res(index/NO_RAMS) := x"0a";
            end if;
            index := index + 1;
        end loop;
        return res;
    end function;

    -- The signal representing the block RAM initialized with instructions
    shared variable ram : ram_t := readFile;
begin
    mema : process (all)
    begin
        if (rising_edge(clk)) then
            if (wea = '1') then
                ram(to_integer(unsigned(addra))) := data_ina;
            end if;
            if (reset = '1') then
                data_outa <= (others => '0');
            else
                data_outa <= ram(to_integer(unsigned(addra)));
            end if;
        end if;
    end process mema;

    memb : process (all)
    begin
        if (rising_edge(clk)) then
            if (web = '1') then
                ram(to_integer(unsigned(addrb))) := data_inb;
            end if;
            if (reset = '1') then
                data_outb <= (others => '0');
            else
                data_outb <= ram(to_integer(unsigned(addrb)));
            end if;
        end if;
    end process memb;
end rtl;