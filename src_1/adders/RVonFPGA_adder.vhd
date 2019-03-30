library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity adder is
    port (
        data1, data2 : in std_logic_vector(63 downto 0);
        result : out std_logic_vector(63 downto 0)
    );
end adder;

architecture rtl of adder is
begin
    result <= std_logic_vector(unsigned(data1) + unsigned(data2));
end rtl;