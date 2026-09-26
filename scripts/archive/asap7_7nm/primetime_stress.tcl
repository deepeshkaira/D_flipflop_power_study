set script_dir [file dirname [file normalize [info script]]]
set project_root [file normalize [file join $script_dir ..]]

puts "PrimeTime project root: $project_root"

set netlist_file [file join $project_root netlist low_power_block_gated.v]
set sdc_file [file join $project_root netlist low_power_block_gated.sdc]
set saif_file [file join $project_root saif low_power_gated_stress.saif]
set library_dir [file join $project_root lib asap7_db]
set report_dir [file join $project_root reports power]

if {![file readable $netlist_file]} {
    error "Cannot read netlist: $netlist_file"
}

if {![file readable $sdc_file]} {
    error "Cannot read SDC: $sdc_file"
}

if {![file readable $saif_file]} {
    error "Cannot read SAIF: $saif_file"
}

file mkdir $report_dir

set_app_var power_enable_analysis true
set_app_var power_analysis_mode averaged

set_app_var search_path [concat $search_path [list \
    $library_dir \
    [file join $project_root netlist] \
]]

set_app_var link_path [list \
    "*" \
    [file join $library_dir asap7sc7p5t_AO_RVT_TT_08302018.db] \
    [file join $library_dir asap7sc7p5t_INVBUF_RVT_TT_08302018.db] \
    [file join $library_dir asap7sc7p5t_OA_RVT_TT_08302018.db] \
    [file join $library_dir asap7sc7p5t_SEQ_RVT_TT_08302018.db] \
    [file join $library_dir asap7sc7p5t_SIMPLE_RVT_TT_08302018.db] \
]

read_verilog $netlist_file

link_design low_power_block
current_design low_power_block

read_sdc $sdc_file

redirect -file [file join $report_dir stress_design_check_timing.rpt] {
    check_timing
}

redirect -file [file join $report_dir stress_design_units.rpt] {
    report_units
}

read_saif -strip_path top_tb/dut $saif_file

redirect -file [file join $report_dir stress_design_activity.rpt] {
    report_switching_activity
}

update_timing

redirect -file [file join $report_dir stress_design_check_power.rpt] {
    check_power
}

update_power

redirect -file [file join $report_dir stress_design_power.rpt] {
    report_power -hierarchy
}

redirect -file [file join $report_dir stress_design_power_verbose.rpt] {
    report_power -verbose
}

exit
