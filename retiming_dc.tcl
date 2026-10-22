# ---------- Setup ----------
set DESIGN   retiming
set LIB_DB   /ve/cg_home/cg0926_hariram_4/hariram/Present80/lp_adder/stdcells.db

set target_library [list $LIB_DB]
set link_library   [list * $LIB_DB]

file mkdir reports results

# ---------- Read RTL ----------
define_design_lib WORK -path ./WORK
analyze -format sverilog -library WORK retiming.sv
elaborate $DESIGN -library WORK
current_design $DESIGN
link
check_design > reports/check_design_pre.rpt

# ---------- Constraints ----------
source -echo -verbose retiming.sdc

# Optional: model input driver and output load (see earlier discussion)
# set_driving_cell -lib_cell <buf_cell> -pin <out_pin> $inputs_no_clk
# set_load 0.02 [all_outputs]

check_timing > reports/check_timing.rpt

# ---------- Compile with retiming ----------
compile_ultra -retime

# ---------- Post-compile checks ----------
change_names -rules verilog -hierarchy
check_design > reports/check_design_post.rpt

report_timing -max_paths 5 -delay_type max > reports/timing_setup.rpt
report_timing -max_paths 5 -delay_type min > reports/timing_hold.rpt
report_area                                  > reports/area.rpt
report_power                                 > reports/power.rpt
report_qor                                   > reports/qor.rpt
report_constraint -all_violators             > reports/violators.rpt
report_reference                             > reports/reference.rpt
report_register                              > reports/registers.rpt

# ---------- Outputs ----------
write -format verilog -hierarchy -output results/${DESIGN}_netlist.v
write -format ddc     -hierarchy -output results/${DESIGN}.ddc
write_sdc results/${DESIGN}_out.sdc

exit
