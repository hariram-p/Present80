# 100 MHz clock
create_clock -name clk \
    -period 10.0 \
    -waveform {0 5} \
    [get_ports clk]

# Clock uncertainty
set_clock_uncertainty 0.2 [get_clocks clk]

# External input timing
set_input_delay 2.0 \
    -clock clk \
    [get_ports {data_a data_b valid_i}]

# Reset is asynchronous; don't use it as a normal data path.
set_input_delay 0.0 \
    -clock clk \
    [get_ports rst_n]

# External output timing
set_output_delay 2.0 \
    -clock clk \
    [get_ports {sum valid_o}]

# Output load
set_load 0.05 [get_ports {sum valid_o}]
