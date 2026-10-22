# ---------- Setup ----------
set DESIGN   retiming
set PROJ_DIR /ve/ws_home/cg0926_hariram_4/hariram/Present80

set RTL_FILE $PROJ_DIR/retiming.sv
set SDC_FILE $PROJ_DIR/retiming.sdc
set LIB_DB   /ve/cg_home/cg0926_hariram_4/hariram/Present80/lp_adder/stdcells.db

set RPT_DIR  $PROJ_DIR/reports
set RES_DIR  $PROJ_DIR/results
set WORK_DIR $PROJ_DIR/WORK

# Create output folders (no error if they already exist)
file mkdir $RPT_DIR $RES_DIR $WORK_DIR

set target_library [list $LIB_DB]
set link_library   [list * $LIB_DB]

# ---------- Read RTL ----------
define_design_lib WORK -path $WORK_DIR
analyze -format sverilog -library WORK $RTL_FILE
elaborate $DESIGN -library WORK
current_design $DESIGN
link
check_design > $RPT_DIR/check_design_pre.rpt

# ---------- Constraints ----------
source -echo -verbose $SDC_FILE

# Optional: model input driver and output load
# set_driving_cell -lib_cell <buf_cell> -pin <out_pin> $inputs_no_clk
# set_load 0.02 [all_outputs]

check_timing > $RPT_DIR/check_timing.rpt

# ---------- Compile with retiming ----------
set_svf $RES_DIR/${DESIGN}.svf
compile_ultra -retime

# ---------- Post-compile checks ----------
change_names -rules verilog -hierarchy
check_design > $RPT_DIR/check_design_post.rpt

report_timing -max_paths 5 -delay_type max > $RPT_DIR/timing_setup.rpt
report_timing -max_paths 5 -delay_type min > $RPT_DIR/timing_hold.rpt
report_area                                  > $RPT_DIR/area.rpt
report_power                                 > $RPT_DIR/power.rpt
report_qor                                   > $RPT_DIR/qor.rpt
report_constraint -all_violators             > $RPT_DIR/violators.rpt
report_reference                             > $RPT_DIR/reference.rpt
report_register                              > $RPT_DIR/registers.rpt

# ---------- Outputs ----------
write -format verilog -hierarchy -output $RES_DIR/${DESIGN}_netlist.v
write -format ddc     -hierarchy -output $RES_DIR/${DESIGN}.ddc
write_sdc $RES_DIR/${DESIGN}_out.sdc

exit
