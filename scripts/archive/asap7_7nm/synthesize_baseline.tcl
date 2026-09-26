set_app_var search_path [concat $search_path [list ./rtl ./constraints ./lib/asap7_db]]

set_app_var target_library [list \
				asap7sc7p5t_AO_RVT_TT_08302018.db \
				asap7sc7p5t_INVBUF_RVT_TT_08302018.db \
				asap7sc7p5t_OA_RVT_TT_08302018.db \
				asap7sc7p5t_SEQ_RVT_TT_08302018.db \
				asap7sc7p5t_SIMPLE_RVT_TT_08302018.db    
			   ]

set_app_var link_library [concat "*" $target_library]

file mkdir netlist
file mkdir reports/synthesis

analyze -format sverilog rtl/low_power_block.sv
elaborate low_power_block
current_design low_power_block
link

check_design > reports/synthesis/baseline_check_design.rpt

read_sdc constraints/low_power_block.sdc

compile_ultra

set_fix_multiple_port_nets -all -buffer_constants
change_names -rules verilog -hierarchy

report_qor > reports/synthesis/baseline_qor.rpt
report_area -hierarchy > reports/synthesis/baseline_area.rpt
report_timing -max_paths 10 > reports/synthesis/baseline_timing.rpt
report_power -hierarchy > reports/synthesis/baseline_power_estimate.rpt
report_reference -hierarchy > reports/synthesis/baseline_references.rpt

write -format ddc -hierarchy -output netlist/low_power_block_baseline.ddc
write -format verilog -hierarchy -output netlist/low_power_block_baseline.v
write_sdc netlist/low_power_block_baseline.sdc

exit
