# ---------- Setup ----------
set DESIGN   retiming
set LIB_DB   /ve/cg_home/cg0926_hariram_4/hariram/Present80/lp_adder/stdcells.db

# Folder containing this script (falls back to the current directory)
set script_path [info script]
if {$script_path ne ""} {
    set SRC_DIR [file dirname [file normalize $script_path]]
} else {
    set SRC_DIR [pwd]
}

set RTL_FILE $SRC_DIR/retiming.sv
set SDC_FILE $SRC_DIR/retiming.sdc

set target_library [list $LIB_DB]
set link_library   [list * $LIB_DB]

file mkdir $SRC_DIR/reports $SRC_DIR/results $SRC_DIR/WORK

# ---------- Read RTL ----------
define_design_lib WORK -path $SRC_DIR/WORK
analyze -format sverilog -library WORK $RTL_FILE
elaborate $DESIGN -library WORK
current_design $DESIGN
link
check_design > $SRC_DIR/reports/check_design_pre.rpt

# ---------- Constraints ----------
source -echo -verbose $SDC_FILE

# Optional: model input driver and output load
# set_driving_cell -lib_cell <buf_cell> -pin <out_pin> $inputs_no_clk
# set_load 0.02 [all_outputs]

check_timing > $SRC_DIR/reports/check_timing.rpt

# ---------- Compile with retiming ----------
set_svf $SRC_DIR/results/${DESIGN}.svf     ;# needed later for Formality
compile_ultra -retime

# ---------- Post-compile checks ----------
change_names -rules verilog -hierarchy
check_design > $SRC_DIR/reports/check_design_post.rpt

report_timing -max_paths 5 -delay_type max > $SRC_DIR/reports/timing_setup.rpt
report_timing -max_paths 5 -delay_type min > $SRC_DIR/reports/timing_hold.rpt
report_area                                  > $SRC_DIR/reports/area.rpt
report_power                                 > $SRC_DIR/reports/power.rpt
report_qor                                   > $SRC_DIR/reports/qor.rpt
report_constraint -all_violators             > $SRC_DIR/reports/violators.rpt
report_reference                             > $SRC_DIR/reports/reference.rpt
report_register                              > $SRC_DIR/reports/registers.rpt

# ---------- Outputs ----------
write -format verilog -hierarchy -output $SRC_DIR/results/${DESIGN}_netlist.v
write -format ddc     -hierarchy -output $SRC_DIR/results/${DESIGN}.ddc
write_sdc $SRC_DIR/results/${DESIGN}_out.sdc

exit
