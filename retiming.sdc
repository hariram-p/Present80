create_clock -name clk -period 5 [get_ports clk]
set_clock_uncertainty 0.1 [get_clocks clk]
set_clock_transition 0.1 [get_clocks clk]   ;# ideal clock, pre-CTS only

set inputs_no_clk [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay  1.0 -clock clk $inputs_no_clk
set_output_delay 1.0 -clock clk [all_outputs]
