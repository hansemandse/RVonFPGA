## This file is a general .xdc for the Basys3 rev B board
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

set_property IOSTANDARD LVCMOS33 [get_ports *]


## Clock signal
set_property PACKAGE_PIN W5 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Switches
#set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
#set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
#set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
#set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
#set_property PACKAGE_PIN W15 [get_ports {sw[4]}]
#set_property PACKAGE_PIN V15 [get_ports {sw[5]}]
#set_property PACKAGE_PIN W14 [get_ports {sw[6]}]
#set_property PACKAGE_PIN W13 [get_ports {sw[7]}]
#set_property PACKAGE_PIN V2  [get_ports {sw[8]}]
#set_property PACKAGE_PIN T3  [get_ports {sw[9]}]
#set_property PACKAGE_PIN T2  [get_ports {sw[10]}]
#set_property PACKAGE_PIN R3  [get_ports {sw[11]}]
#set_property PACKAGE_PIN W2  [get_ports {sw[12]}]
#set_property PACKAGE_PIN U1  [get_ports {sw[13]}]
#set_property PACKAGE_PIN T1  [get_ports {sw[14]}]
#set_property PACKAGE_PIN R2  [get_ports {sw[15]}]


## LEDs
set_property PACKAGE_PIN U16 [get_ports {pc_out[0]}]
set_property PACKAGE_PIN E19 [get_ports {pc_out[1]}]
set_property PACKAGE_PIN U19 [get_ports {pc_out[2]}]
set_property PACKAGE_PIN V19 [get_ports {pc_out[3]}]
set_property PACKAGE_PIN W18 [get_ports {pc_out[4]}]
set_property PACKAGE_PIN U15 [get_ports {pc_out[5]}]
set_property PACKAGE_PIN U14 [get_ports {pc_out[6]}]
set_property PACKAGE_PIN V14 [get_ports {pc_out[7]}]
set_property PACKAGE_PIN V13 [get_ports {pc_out[8]}]
set_property PACKAGE_PIN V3 [get_ports {pc_out[9]}]
set_property PACKAGE_PIN W3 [get_ports {pc_out[10]}]
set_property PACKAGE_PIN U3 [get_ports {pc_out[11]}]
#set_property PACKAGE_PIN P3  [get_ports {led[12]}]
#set_property PACKAGE_PIN N3  [get_ports {led[13]}]
#set_property PACKAGE_PIN P1  [get_ports {led[14]}]
#set_property PACKAGE_PIN L1  [get_ports {led[15]}]


##Buttons
set_property PACKAGE_PIN U18 [get_ports reset]
#set_property PACKAGE_PIN T18 [get_ports btnU]
#set_property PACKAGE_PIN W19 [get_ports btnL]
#set_property PACKAGE_PIN T17 [get_ports btnR]
#set_property PACKAGE_PIN U17 [get_ports btnD]


##7 segment display
#set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
#set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
#set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
#set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
#set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
#set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
#set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
#set_property PACKAGE_PIN V7 [get_ports {dp}]
#set_property PACKAGE_PIN U2 [get_ports {an[0]}]
#set_property PACKAGE_PIN U4 [get_ports {an[1]}]
#set_property PACKAGE_PIN V4 [get_ports {an[2]}]
#set_property PACKAGE_PIN W4 [get_ports {an[3]}]


##VGA Connector
#set_property PACKAGE_PIN G19 [get_ports {vgaRed[0]}]
#set_property PACKAGE_PIN H19 [get_ports {vgaRed[1]}]
#set_property PACKAGE_PIN J19 [get_ports {vgaRed[2]}]
#set_property PACKAGE_PIN N19 [get_ports {vgaRed[3]}]
#set_property PACKAGE_PIN N18 [get_ports {vgaBlue[0]}]
#set_property PACKAGE_PIN L18 [get_ports {vgaBlue[1]}]
#set_property PACKAGE_PIN K18 [get_ports {vgaBlue[2]}]
#set_property PACKAGE_PIN J18 [get_ports {vgaBlue[3]}]
#set_property PACKAGE_PIN J17 [get_ports {vgaGreen[0]}]
#set_property PACKAGE_PIN H17 [get_ports {vgaGreen[1]}]
#set_property PACKAGE_PIN G17 [get_ports {vgaGreen[2]}]
#set_property PACKAGE_PIN D17 [get_ports {vgaGreen[3]}]
#set_property PACKAGE_PIN P19 [get_ports Hsync]
#set_property PACKAGE_PIN R19 [get_ports Vsync]


##USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports serial_rx]
set_property PACKAGE_PIN A18 [get_ports serial_tx]


##USB HID (PS/2)
#set_property PACKAGE_PIN C17 [get_ports PS2Clk]
#set_property PULLUP true [get_ports PS2Clk]
#set_property PACKAGE_PIN B17 [get_ports PS2Data]
#set_property PULLUP true [get_ports PS2Data]


##Pmod Header JA
#set_property PACKAGE_PIN J1 [get_ports {JA[0]}]
#set_property PACKAGE_PIN L2 [get_ports {JA[1]}]
#set_property PACKAGE_PIN J2 [get_ports {JA[2]}]
#set_property PACKAGE_PIN G2 [get_ports {JA[3]}]
#set_property PACKAGE_PIN H1 [get_ports {JA[4]}]
#set_property PACKAGE_PIN K2 [get_ports {JA[5]}]
#set_property PACKAGE_PIN H2 [get_ports {JA[6]}]
#set_property PACKAGE_PIN G3 [get_ports {JA[7]}]


##Pmod Header JB
#set_property PACKAGE_PIN A14 [get_ports {JB[0]}]
#set_property PACKAGE_PIN A16 [get_ports {JB[1]}]
#set_property PACKAGE_PIN B15 [get_ports {JB[2]}]
#set_property PACKAGE_PIN B16 [get_ports {JB[3]}]
#set_property PACKAGE_PIN A15 [get_ports {JB[4]}]
#set_property PACKAGE_PIN A17 [get_ports {JB[5]}]
#set_property PACKAGE_PIN C15 [get_ports {JB[6]}]
#set_property PACKAGE_PIN C16 [get_ports {JB[7]}]


##Pmod Header JC
#set_property PACKAGE_PIN K17 [get_ports {JC[0]}]
#set_property PACKAGE_PIN M18 [get_ports {JC[1]}]
#set_property PACKAGE_PIN N17 [get_ports {JC[2]}]
#set_property PACKAGE_PIN P18 [get_ports {JC[3]}]
#set_property PACKAGE_PIN L17 [get_ports {JC[4]}]
#set_property PACKAGE_PIN M19 [get_ports {JC[5]}]
#set_property PACKAGE_PIN P17 [get_ports {JC[6]}]
#set_property PACKAGE_PIN R18 [get_ports {JC[7]}]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 2 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 8192 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_int_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 5 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {pip/RegisterRd[0]} {pip/RegisterRd[1]} {pip/RegisterRd[2]} {pip/RegisterRd[3]} {pip/RegisterRd[4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 64 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {control/IWriteData[0]} {control/IWriteData[1]} {control/IWriteData[2]} {control/IWriteData[3]} {control/IWriteData[4]} {control/IWriteData[5]} {control/IWriteData[6]} {control/IWriteData[7]} {control/IWriteData[8]} {control/IWriteData[9]} {control/IWriteData[10]} {control/IWriteData[11]} {control/IWriteData[12]} {control/IWriteData[13]} {control/IWriteData[14]} {control/IWriteData[15]} {control/IWriteData[16]} {control/IWriteData[17]} {control/IWriteData[18]} {control/IWriteData[19]} {control/IWriteData[20]} {control/IWriteData[21]} {control/IWriteData[22]} {control/IWriteData[23]} {control/IWriteData[24]} {control/IWriteData[25]} {control/IWriteData[26]} {control/IWriteData[27]} {control/IWriteData[28]} {control/IWriteData[29]} {control/IWriteData[30]} {control/IWriteData[31]} {control/IWriteData[32]} {control/IWriteData[33]} {control/IWriteData[34]} {control/IWriteData[35]} {control/IWriteData[36]} {control/IWriteData[37]} {control/IWriteData[38]} {control/IWriteData[39]} {control/IWriteData[40]} {control/IWriteData[41]} {control/IWriteData[42]} {control/IWriteData[43]} {control/IWriteData[44]} {control/IWriteData[45]} {control/IWriteData[46]} {control/IWriteData[47]} {control/IWriteData[48]} {control/IWriteData[49]} {control/IWriteData[50]} {control/IWriteData[51]} {control/IWriteData[52]} {control/IWriteData[53]} {control/IWriteData[54]} {control/IWriteData[55]} {control/IWriteData[56]} {control/IWriteData[57]} {control/IWriteData[58]} {control/IWriteData[59]} {control/IWriteData[60]} {control/IWriteData[61]} {control/IWriteData[62]} {control/IWriteData[63]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_int_BUFG]
