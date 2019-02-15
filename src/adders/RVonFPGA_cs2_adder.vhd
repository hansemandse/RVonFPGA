library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cs2_adder is
    port (
        data1, data2 : in std_logic_vector(63 downto 0);
        result : out std_logic_vector(63 downto 0)
    );
end cs2_adder;

architecture rtl of cs2_adder is
    signal result_low : std_logic_vector(32 downto 0);
    signal result_high : std_logic_vector(31 downto 0);
begin
    result_low <= std_logic_vector(unsigned('0' & data1(31 downto 0)) + unsigned('0' & data2(31 downto 0)));
    process (all)
    begin
        if (result_low(32) = '1') then
            result_high <= std_logic_vector(unsigned(data1(63 downto 32)) + unsigned(data2(63 downto 32)) + 1);
        else
            result_high <= std_logic_vector(unsigned(data1(63 downto 32)) + unsigned(data2(63 downto 32)));
        end if;
    end process;
    result <= (31 downto 0 => result_low(31 downto 0), 63 downto 32 => result_high);
end rtl;