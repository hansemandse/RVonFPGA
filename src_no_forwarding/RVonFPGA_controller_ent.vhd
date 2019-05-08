-- *******************************************************************************************
--              |
-- Title        : Implementation and Optimization of a RISC-V Processor on a FPGA
--              |
-- Developers   : Hans Jakob Damsgaard, Technical University of Denmark
--              : s163915@student.dtu.dk or hansjakobdamsgaard@gmail.com
--              |
-- Purpose      : This file is a part of a full system implemented as part of a bachelor's
--              : thesis at DTU. The thesis is written in cooperation with the Institute
--              : of Mathematics and Computer Science.
--              : This entity represents the UART controller. Its design is heavily inspired
--              : by an implementation of a similar component by Luca Pezzarossa in course
--              : 02203 at DTU, see https://github.com/lucapezza/02203-serial-interface
--              |
-- Revision     : 2.1   (last updated April 25, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.includes.all;

entity controller is
    generic (
        ADDR_WIDTH : natural := MEM_ADDR_WIDTH
    );
    port (
        clk, reset : in std_logic;
        -- Interface to the UART
        data_stream_out : out std_logic_vector(BYTE_WIDTH-1 downto 0);
        data_stream_out_stb : out std_logic;
        data_stream_out_ack : in std_logic;
        data_stream_in : in std_logic_vector(BYTE_WIDTH-1 downto 0);
        data_stream_in_stb : in std_logic;
        -- Interface to the memory
        UMemOp : out mem_op_t;
        UAddr : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        UWriteData : out std_logic_vector(DATA_WIDTH-1 downto 0);
        UReadData : in std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

