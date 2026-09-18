# ============================================================
# PrimeTime
# ============================================================

set DESIGN registered_adder

# CHANGE THIS to your actual SKY130 .db
set STD_CELL_DB "/path/to/sky130_library.db"

set_app_var link_path [list "*" $STD_CELL_DB]

read_verilog syn/registered_adder_syn.v

current_design $DESIGN
link

read_sdc syn/registered_adder_syn.sdc

file mkdir reports_pt

check_timing \
    > reports_pt/check_timing.rpt

report_clocks \
    > reports_pt/clocks.rpt

report_timing \
    -delay_type max \
    -max_paths 10 \
    > reports_pt/setup.rpt

report_timing \
    -delay_type min \
    -max_paths 10 \
    > reports_pt/hold.rpt

report_area \
    > reports_pt/area.rpt

report_power \
    > reports_pt/power.rpt

echo "=========================================="
echo "PRIMETIME ANALYSIS COMPLETE"
echo "=========================================="

exit
