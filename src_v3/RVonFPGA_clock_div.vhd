-- ***********************************************************************
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
--              : This entity represents the clock divider of the system. 
--              : It is implemented using a Xilinx PLLE2_BASE primitive.
--              |
-- Revision     : 1.0   (last updated March 15, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- ***********************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

library UNISIM;
use UNISIM.Vcomponents.all;

entity clock_divider is
    generic (
        DIV : natural := 1
    );
    port (
        clk_in, reset : in std_logic;
        clk_out : out std_logic
    );
end clock_divider;

architecture rtl of clock_divider is
    -- Multiplier for the clock divider
    constant MULT : natural := 8;
    constant DIV_S : natural := MULT * DIV;

    -- Signal for clock feedback to the PLL
    signal clk_fb : std_logic;
begin
    -- The following code is taken from Xilinx Language Templates in Vivado
    -- Please see Tools -> Language Templates -> VHDL -> Device Primitive Instantiation
    -- -> Artix-7 -> Clock Components -> MMCM / PLL -> Base Phase Locked Loop (PLLE2_BASE)
    -- Instantiation specific details are largely taken from the clock divider component
    -- by Luca Pezzarossa used in course 02203 Design of Digital Systems at DTU.

    -- PLLE2_BASE: Base Phase Locked Loop (PLL)
   --             Artix-7
   -- Xilinx HDL Language Template, version 2018.2
   PLLE2_BASE_inst : PLLE2_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
      CLKFBOUT_MULT => MULT,     -- Multiply value for all CLKOUT, (2-64)
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
      CLKIN1_PERIOD => 10.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT0_DIVIDE => DIV_S,
      CLKOUT1_DIVIDE => 1,
      CLKOUT2_DIVIDE => 1,
      CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => 0.0,
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      DIVCLK_DIVIDE => 1,        -- Master division value, (1-56)
      REF_JITTER1 => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
      STARTUP_WAIT => "FALSE"    -- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => clk_out,   -- 1-bit output: CLKOUT0
      CLKOUT1 => open,      -- 1-bit output: CLKOUT1
      CLKOUT2 => open,      -- 1-bit output: CLKOUT2
      CLKOUT3 => open,      -- 1-bit output: CLKOUT3
      CLKOUT4 => open,      -- 1-bit output: CLKOUT4
      CLKOUT5 => open,      -- 1-bit output: CLKOUT5
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => clk_fb,   -- 1-bit output: Feedback clock
      LOCKED => open,       -- 1-bit output: LOCK
      CLKIN1 => clk_in,     -- 1-bit input: Input clock
      -- Control Ports: 1-bit (each) input: PLL control ports
      PWRDWN => '0',        -- 1-bit input: Power-down
      RST => reset,         -- 1-bit input: Reset
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => clk_fb     -- 1-bit input: Feedback clock
   );
end rtl;