sourceFile = "boot.bin"
resultFile = "../src_v3/RVonFPGA_rom_gen.vhd"

header = """-- ***********************************************************************
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
--              : This entity is a generated ROM containing the bootloader
--              : from the compiler.
--              |
-- Revision     : 1.0   (last updated June 28, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- ***********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.includes.all;

entity rom_gen is
    port (
        clk, reset : in std_logic;
        -- Memory interface
        Addr : in std_logic_vector(11 downto 0);
        ReadData : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end rom_gen;

architecture rtl of rom_gen is
begin
    process (all)
    begin
        if (rising_edge(clk)) then
            if (reset = '1') then
                ReadData <= (others => '0');
            else
                case (Addr) is
"""

endoffile = """
                end case;
            end if;
        end if;
    end process;
end rtl;
"""

try:
    with open(resultFile, 'w') as f:
        f.write(header)
        with open(sourceFile, 'rb') as f1:
            fileContent = bytearray(f1.read())
            diff = 4096 - len(fileContent)
            fileContent.extend(bytearray(diff))
            index = range(0, 4096, 8)
            for i in index:
                hexString = 'x\"{:03x}\"'.format(i)
                if (i < 4088):
                    f.write("\t\t\t\t\twhen ")
                    f.write(hexString)
                    f.write(" => ReadData <= x\"")
                    index2 = range(7, -1, -1)
                    for i2 in index2:
                        f.write('{:02x}'.format(fileContent[i+i2]))
                    f.write("\";\n")
                else:
                    f.write("\t\t\t\t\twhen others => ReadData <= x\"")
                    index2 = range(7, -1, -1)
                    for i2 in index2:
                        f.write('{:02x}'.format(fileContent[i+i2]))
                    f.write("\";")
            #, 'x\"{:03x}\"'.format(i),
        f.write(endoffile)
except Exception:
    print("Error")
