library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity shift_left_6 is
    port (
        shamt : in std_logic_vector(5 downto 0);
        data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        result : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end shift_left_6;

architecture rtl of shift_left_6 is
    type temp_a is array(5 downto 0) of std_logic_vector(DATA_WIDTH-1 downto 0);
begin
    gen : process (all)
        variable temp : temp_a;
    begin
        for i in 0 to 5 loop
            if (shamt(i) = '1') then
                if (i = 0) then
                    temp(i) := std_logic_vector(shift_left(unsigned(data), 1));
                else
                    temp(i) := std_logic_vector(shift_left(unsigned(temp(i-1)), i**2));
                end if;
            else
                if (i = 0) then
                    temp(i) := data;
                else
                    temp(i) := temp(i-1);
                end if;
            end if;
        end loop;
        result <= temp(5);
    end process gen;
end rtl;