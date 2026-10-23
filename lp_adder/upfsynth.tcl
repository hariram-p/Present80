# Target standard cell library containing standard, isolation, and retention cells
set search_path    [list . /tools/pdk/standard_cells/db]
set target_library [list sc_core_lvt.db sc_lp_cells.db]
set link_library   [list * sc_core_lvt.db sc_lp_cells.db dw_foundation.sldb]

# 1. Front-End Parse & Hierarchy
analyze -format sverilog retiming.sv
elaborate retiming
current_design retiming

# 2. Ingest UPF Power Intent
load_upf retiming.upf

# 3. Resolve References & Verify Power Rules
link
check_mv_design -verbose

# 4. Define Timing Constraints
create_clock -period 2.0 [get_ports clk]
set_input_delay  0.4 -clock clk [get_ports {a b resetn}]
set_output_delay 0.4 -clock clk [get_ports out]

# 5. Synthesis & Insertion of Low-Power Cells
# compile_ultra reads the loaded UPF and automatically inserts:
# - 32x Isolation cells (clamping 'out[31:0]' to 0)
# - 64x Retention flops (replacing normal DFFs for a_reg and b_reg)
# - Standard clock-gating cells (ICGs)
compile_ultra -gate_clock

# 6. Audit Inserted Low-Power Macrocells
echo "=== Isolation Cells Inserted ==="
report_isolation_cell

echo "=== Retention Registers Inserted ==="
report_retention_cell

echo "=== Power Switch Specification ==="
report_power_switch

# 7. Export Gate-Level Netlist and Updated UPF
change_names -rules verilog -hierarchy
write -format verilog -hierarchy -output retiming_mapped_lp.v
write_upf retiming_out.upf
