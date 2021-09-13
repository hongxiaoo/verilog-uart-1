# IO Constraint

##############################
# Clock
##############################
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

##############################
# Reset
##############################
set_property PACKAGE_PIN C2 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

##############################
# Uart 0
##############################
set_property PACKAGE_PIN A9 [get_ports uart_rx]
set_property PACKAGE_PIN D10 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]
