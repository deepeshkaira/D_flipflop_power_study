set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir ../..]]

puts "PrimeTime project root: $project_root"

set netlist_file [file join $project_root netlist low_power_block_gated_15nm.v]
set sdc_file [file join $project_root netlist low_power_block_gated_15nm.sdc]
set saif_file [file join $project_root saif low_power_gated_stress.saif]
set library_dir [file join $project_root lib nangate15_db]
set library_file [file join $library_dir NanGate_15nm_OCL_typical.db]
set report_dir [file join $project_root reports nangate15_15nm stress]

foreach required_file [list $netlist_file $sdc_file $saif_file $library_file] {
    if {![file readable $required_file]} {
        error "Cannot read required input: $required_file"
    }
}

file mkdir $report_dir

set_app_var power_enable_analysis true
set_app_var power_analysis_mode averaged
set_app_var search_path [concat $search_path [list $library_dir [file join $project_root netlist]]]
set_app_var link_path [list "*" $library_file]

read_verilog $netlist_file
link_design low_power_block
current_design low_power_block
set_operating_conditions typical -library NanGate_15nm_OCL
read_sdc $sdc_file

redirect -file [file join $report_dir stress_design_15nm_check_timing.rpt] { check_timing }
redirect -file [file join $report_dir stress_design_15nm_units.rpt] { report_units }

read_saif -strip_path top_tb/dut $saif_file
redirect -file [file join $report_dir stress_design_15nm_activity.rpt] { report_switching_activity }

update_timing
redirect -file [file join $report_dir stress_design_15nm_check_power.rpt] { check_power }
update_power

redirect -file [file join $report_dir stress_design_15nm_power.rpt] { report_power -hierarchy }
redirect -file [file join $report_dir stress_design_15nm_power_verbose.rpt] { report_power -verbose }

exit

