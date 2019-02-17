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
    signal result_low, result_high0, result_high1 : std_logic_vector(32 downto 0);
begin
    result_low <= std_logic_vector(unsigned('0' & data1(31 downto 0)) + unsigned('0' & data2(31 downto 0)));
    result_high0 <= std_logic_vector(unsigned(data1(63 downto 32) & '0') + unsigned(data2(63 downto 32) & '1'));
    result_high1 <= std_logic_vector(unsigned(data1(63 downto 32) & '1') + unsigned(data2(63 downto 32) & '1'));
    process (all)
    begin
        if (result_low(32) = '1') then
            result <= (31 downto 0 => result_low(31 downto 0), 63 downto 32 => result_high1(32 downto 1));
        else
            result <= (31 downto 0 => result_low(31 downto 0), 63 downto 32 => result_high0(32 downto 1));
        end if;
    end process;
end rtl;