# Design Compiler synthesis script
# CHANGE STD_CELL_DB to your actual SKY130 .db file.

set DESIGN registered_adder
set RTL_DIR ../rtl
set CONSTRAINT_DIR ../constraints
set REPORT_DIR ../reports
set OUT_DIR ../syn

file mkdir $REPORT_DIR
file mkdir $OUT_DIR

set STD_CELL_DB "/path/to/sky130_library.db"

set_app_var target_library [list $STD_CELL_DB]
set_app_var link_library   [list "*" $STD_CELL_DB]

analyze -format sverilog "$RTL_DIR/registered_adder.sv"
elaborate $DESIGN
current_design $DESIGN
link

read_sdc "$CONSTRAINT_DIR/adder.sdc"

check_design > "$REPORT_DIR/check_design.rpt"
check_timing > "$REPORT_DIR/check_timing.rpt"

compile_ultra

report_area -hierarchy > "$REPORT_DIR/area.rpt"
report_timing -max_paths 10 > "$REPORT_DIR/timing.rpt"
report_power > "$REPORT_DIR/power.rpt"
report_qor > "$REPORT_DIR/qor.rpt"
report_reference > "$REPORT_DIR/reference.rpt"

write -format verilog -hierarchy -output "$OUT_DIR/${DESIGN}_syn.v"
write -format ddc -hierarchy -output "$OUT_DIR/${DESIGN}.ddc"
write_sdc "$OUT_DIR/${DESIGN}_syn.sdc"

echo "SYNTHESIS COMPLETE"
exit
