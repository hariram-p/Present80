# ============================================================
# Design Compiler
# ============================================================

set DESIGN registered_adder

# CHANGE THIS to your actual SKY130 .db
set STD_CELL_DB "/path/to/sky130_library.db"

set_app_var target_library [list $STD_CELL_DB]
set_app_var link_library   [list "*" $STD_CELL_DB]

file mkdir reports
file mkdir syn

analyze -format sverilog registered_adder.sv
elaborate $DESIGN

current_design $DESIGN
link

read_sdc adder.sdc

check_design > reports/dc_check_design.rpt
check_timing > reports/dc_check_timing.rpt

compile_ultra

report_area \
    > reports/dc_area.rpt

report_timing \
    -max_paths 10 \
    > reports/dc_timing.rpt

report_power \
    > reports/dc_power.rpt

report_qor \
    > reports/dc_qor.rpt

report_reference \
    > reports/dc_reference.rpt

write -format verilog \
    -hierarchy \
    -output syn/registered_adder_syn.v

write -format ddc \
    -hierarchy \
    -output syn/registered_adder.ddc

write_sdc \
    syn/registered_adder_syn.sdc

echo "=========================================="
echo "DESIGN COMPILER SYNTHESIS COMPLETE"
echo "=========================================="

exit
