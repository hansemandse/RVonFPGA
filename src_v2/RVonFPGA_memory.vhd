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
--              : This entity represents the memory of the processor. It has a simple memory
--              : controller that connects two memory interfaces from the pipeline to the
--              : BRAM such that data operations have priority over instruction fetches. The
--              : memory also implements a "back door" UART which is not mapped into the
--              : processor's address space.
--              |
-- Revision     : 1.0   (last updated April 4, 2019)
--              |
-- Available at : https://github.com/hansemandse/RVonFPGA
--              |
-- *******************************************************************************************

entity memory is
    generic (

    );
    port (

    );
end memory;

architecture rtl of memory is

begin


end rtl;