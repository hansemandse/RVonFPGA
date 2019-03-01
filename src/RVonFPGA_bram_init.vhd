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
--              : This entity represents a block-RAM of variable size used in the data memory
--              : and the instruction memory of the pipeline
--              |
-- Revision     : 1.0   (last updated February 28, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;
use std.textio.all;

entity bram_init is
    generic (
        DATA_WIDTH : natural := 8;
        ADDR_WIDTH : natural := 9;
        TEST_FILE : string;
        NO_RAMS, RAM_NO : integer
    );
    port (
        -- Control ports
        we, reset, clk : in std_logic;
        -- Data ports
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end bram_init;

architecture rtl of bram_init is
    constant ARRAY_WIDTH : natural := 2 ** ADDR_WIDTH;
    type ram_t is array(ARRAY_WIDTH-1 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);

    -- Size of the entire memory used for index checking in the read function
    constant MEM_SIZE : natural := ARRAY_WIDTH * (2 ** natural(log2(real(NO_RAMS))));

    -- Function for reading a binary file and initializing each ram position accordingly
    type file_t is file of character;
    impure function readFile return ram_t is
        file file_in : text open READ_MODE is TEST_FILE;
        variable c_line : line;
        variable c_buf : character := NUL;
        variable index : natural := 0;
        variable res : ram_t := (others => (others => '0'));
    begin
        while (not endfile(file_in)) loop
            readline(file_in, c_line);
            while (index < MEM_SIZE) loop
                read(c_line, c_buf);
                if (to_unsigned(index, integer(log2(real(NO_RAMS)))) = RAM_NO) then
                    res(index/NO_RAMS) := std_logic_vector(to_unsigned(character'pos(c_buf), DATA_WIDTH));
                end if;
                index := index + 1;
            end loop;
        end loop;
        return res;
    end function;

    -- The signal representing the block RAM initialized with instructions
    signal ram : ram_t := readFile;
begin
    mem : process (all)
    begin
        if (rising_edge(clk)) then
            if (we = '1') then
                ram(to_integer(unsigned(addr))) <= data_in;
            end if;
            if (reset = '1') then
                data_out <= (others => '0');
            else
                data_out <= ram(to_integer(unsigned(addr)));
            end if;
        end if;
    end process mem;
end rtl;