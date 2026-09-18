create_clock -name clk -period 10.0 -waveform {0 5} [get_ports clk]
set_clock_uncertainty 0.2 [get_clocks clk]

set_input_delay 2.0 -clock clk [get_ports {data_a data_b valid_i}]
set_output_delay 2.0 -clock clk [get_ports {sum valid_o}]

set_load 0.05 [get_ports {sum valid_o}]
