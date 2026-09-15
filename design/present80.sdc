########################################################
# COUNTER CONSTRAINTS (SDC)
########################################################

# -----------------------------------
# Basic variables
# -----------------------------------
set CLK_NAME clk
set CLK_PERIOD 10.0
set CLK_LATENCY 1.5
set CLK_UNCERTAINTY 0.30
set CLK_TRANSITION 0.40

set INPUT_DELAY  1.0
set OUTPUT_DELAY 1.0
set MIN_IO_DELAY 0.5

set MAX_TRANSITION 0.5
set MAX_FANOUT 10

# -----------------------------------
# Create main clock
# -----------------------------------
create_clock -name $CLK_NAME -period $CLK_PERIOD [get_ports clk]

set_clock_latency     $CLK_LATENCY     [get_clocks $CLK_NAME]
set_clock_uncertainty $CLK_UNCERTAINTY [get_clocks $CLK_NAME]
set_clock_transition  $CLK_TRANSITION  [get_clocks $CLK_NAME]

# -----------------------------------
# Define input & output ports
# -----------------------------------
set INPUT_PORTS  [remove_from_collection [all_inputs] [get_ports clk]]
set OUTPUT_PORTS [all_outputs]

# -----------------------------------
# Input delays
# -----------------------------------
set_input_delay  -clock $CLK_NAME -max $INPUT_DELAY  $INPUT_PORTS
set_input_delay  -clock $CLK_NAME -min $MIN_IO_DELAY $INPUT_PORTS

# -----------------------------------
# Output delays
# -----------------------------------
set_output_delay -clock $CLK_NAME -max $OUTPUT_DELAY  $OUTPUT_PORTS
set_output_delay -clock $CLK_NAME -min $MIN_IO_DELAY $OUTPUT_PORTS

# -----------------------------------
# Drive & Load modeling
# -----------------------------------
set_driving_cell -lib_cell INVX1 -pin Z $INPUT_PORTS
set_load 0.05 $OUTPUT_PORTS

# -----------------------------------
# Design rule constraints
# -----------------------------------
set_max_transition $MAX_TRANSITION [current_design]
set_max_fanout     $MAX_FANOUT     [current_design]

# -----------------------------------
# Prevent DC from optimizing clock tree
# -----------------------------------
set_dont_touch_network [get_ports clk]

# -----------------------------------
# Optional: false path for async reset (if exists)
# -----------------------------------
# set_false_path -from [get_ports rst_n]

########################################################
# END
########################################################

