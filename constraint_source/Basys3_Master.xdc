# primary Clock - 50MHz target
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} [get_ports clk]
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# reset
set_property PACKAGE_PIN U18 [get_ports rst_n] 
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

# LEDs - show key debug info only (16 LEDs available)
set_property PACKAGE_PIN U16 [get_ports {debug_pc[0]}]
set_property PACKAGE_PIN E19 [get_ports {debug_pc[1]}] 
set_property PACKAGE_PIN U19 [get_ports {debug_pc[2]}]
set_property PACKAGE_PIN V19 [get_ports {debug_pc[3]}]
set_property PACKAGE_PIN W18 [get_ports {debug_pc[4]}]
set_property PACKAGE_PIN U15 [get_ports {debug_pc[5]}]
set_property PACKAGE_PIN U14 [get_ports {debug_pc[6]}]
set_property PACKAGE_PIN V14 [get_ports {debug_pc[7]}]
set_property PACKAGE_PIN V13 [get_ports {debug_reg_we}]
set_property PACKAGE_PIN V3  [get_ports {debug_reg_addr[0]}]
set_property PACKAGE_PIN W3  [get_ports {debug_reg_addr[1]}]
set_property PACKAGE_PIN U3  [get_ports {debug_reg_addr[2]}]
set_property PACKAGE_PIN P3  [get_ports {debug_reg_addr[3]}]
set_property PACKAGE_PIN N3  [get_ports {debug_reg_addr[4]}]
set_property PACKAGE_PIN P1  [get_ports {debug_instr[0]}]
set_property PACKAGE_PIN L1  [get_ports {debug_instr[1]}]

# set all LED iostandards
set_property IOSTANDARD LVCMOS33 [get_ports {debug_pc[7:0]}]
set_property IOSTANDARD LVCMOS33 [get_ports debug_reg_we]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_reg_addr[4:0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {debug_instr[1:0]}]

# 7-segment display - show PC upper bits
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6:0]}]

set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[3:0]}]

# timing constraints
set_input_delay -clock [get_clocks sys_clk_pin] -min 2.000 [get_ports rst_n]
set_input_delay -clock [get_clocks sys_clk_pin] -max 5.000 [get_ports rst_n]
set_false_path -from [get_ports rst_n] -to [all_registers]

# configuration
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
