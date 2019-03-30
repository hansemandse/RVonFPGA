library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity shift_left_3 is
    port (
        shamt : in std_logic_vector(5 downto 0);
        data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        result : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end shift_left_3;

architecture rtl of shift_left_3 is
    signal temp1, temp2 : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    temp1 <= std_logic_vector(shift_left(unsigned(data), to_integer(unsigned(shamt(5 downto 4)))));
    temp2 <= std_logic_vector(shift_left(unsigned(temp1), to_integer(unsigned(shamt(3 downto 2)))));
    result <= std_logic_vector(shift_left(unsigned(temp2), to_integer(unsigned(shamt(1 downto 0)))));
end rtl;