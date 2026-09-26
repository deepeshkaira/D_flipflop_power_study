file mkdir work_gated_15nm
define_design_lib WORK -path ./work_gated_15nm

set_app_var search_path [concat $search_path [list ./rtl ./constraints ./lib/nangate15_db]]
set_app_var target_library [list NanGate_15nm_OCL_typical.db]
set_app_var link_library [concat "*" $target_library]

file mkdir netlist
file mkdir reports/nangate15_15nm/synthesis

analyze -format sverilog rtl/low_power_block.sv
elaborate low_power_block
current_design low_power_block
link

set_operating_conditions typical -library NanGate_15nm_OCL

check_design > reports/nangate15_15nm/synthesis/gated_15nm_check_design.rpt
read_sdc constraints/low_power_block.sdc

# The default positive-edge integrated style maps the shared enable to the
# library's CLKGATETST_X1 latch_posedge_precontrol cell.
compile_ultra -gate_clock

report_clock_gating > reports/nangate15_15nm/synthesis/gated_15nm_clock_gating.rpt
set_fix_multiple_port_nets -all -buffer_constants
change_names -rules verilog -hierarchy

report_qor > reports/nangate15_15nm/synthesis/gated_15nm_qor.rpt
report_area -hierarchy > reports/nangate15_15nm/synthesis/gated_15nm_area.rpt
report_timing -max_paths 10 > reports/nangate15_15nm/synthesis/gated_15nm_timing.rpt
report_power -hierarchy > reports/nangate15_15nm/synthesis/gated_15nm_power_estimate.rpt
report_reference -hierarchy > reports/nangate15_15nm/synthesis/gated_15nm_references.rpt

write -format ddc -hierarchy -output netlist/low_power_block_gated_15nm.ddc
write -format verilog -hierarchy -output netlist/low_power_block_gated_15nm.v
write_sdc netlist/low_power_block_gated_15nm.sdc

exit
