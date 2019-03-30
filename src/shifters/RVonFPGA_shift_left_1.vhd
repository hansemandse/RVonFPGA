library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity shift_left_1 is
    port (
        shamt : in std_logic_vector(5 downto 0);
        data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        result : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end shift_left_1;

architecture rtl of shift_left_1 is
begin
    result <= std_logic_vector(shift_left(unsigned(data), to_integer(unsigned(shamt))));
end rtl;