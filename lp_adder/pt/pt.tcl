# PrimeTime STA script
# CHANGE STD_CELL_DB and search_path to your actual SKY130 setup.

set DESIGN registered_adder
set NETLIST "../syn/${DESIGN}_syn.v"
set SDC "../syn/${DESIGN}_syn.sdc"
set REPORT_DIR "../reports/pt"

file mkdir $REPORT_DIR

set STD_CELL_DB "/path/to/sky130_library.db"
set_app_var link_path [list "*" $STD_CELL_DB]

read_verilog $NETLIST
current_design $DESIGN
link

read_sdc $SDC

check_timing > "$REPORT_DIR/check_timing.rpt"
report_clocks > "$REPORT_DIR/clocks.rpt"
report_timing -delay_type max -max_paths 10 > "$REPORT_DIR/setup.rpt"
report_timing -delay_type min -max_paths 10 > "$REPORT_DIR/hold.rpt"
report_area > "$REPORT_DIR/area.rpt"
report_power > "$REPORT_DIR/power.rpt"

echo "PRIMETIME COMPLETE"
exit
