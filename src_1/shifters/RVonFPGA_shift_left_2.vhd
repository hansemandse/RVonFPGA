library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity shift_left_2 is
    port (
        shamt : in std_logic_vector(5 downto 0);
        data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        result : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end shift_left_2;

architecture rtl of shift_left_2 is
    signal temp : std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    temp <= std_logic_vector(shift_left(unsigned(data), to_integer(unsigned(shamt(5 downto 3)))));
    result <= std_logic_vector(shift_left(unsigned(temp), to_integer(unsigned(shamt(2 downto 0)))));
end rtl;