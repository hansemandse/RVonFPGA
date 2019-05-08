library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.includes.all;

entity top is
    port (
        clk, reset : in std_logic;
        result : out std_logic_vector(15 downto 0)
    );
end top;

architecture rtl of top is
    signal clk_int : std_logic;

    signal result_int : std_logic_vector(DATA_WIDTH-1 downto 0);

    -- The ALU test component
    component ALU_test
        port (
            clk, reset : in std_logic;
            result : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    -- The clock divider component
    component clock_divider
        generic (
            DIV : natural := 1
        );
        port (
            clk_in, reset : in std_logic;
            clk_out : out std_logic
        );
    end component;
begin
    result <= result_int(DATA_WIDTH-1 downto 48);
    dut : ALU_test
    port map (
        clk => clk_int,
        reset => reset,
        result => result_int
    );

    div : clock_divider
    port map (
        clk_in => clk,
        reset => reset,
        clk_out => clk_int
    );
end rtl;