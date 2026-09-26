
vopt top_tb +acc -pa_top /top_tb/dut -pa_upf low_power.upf -pa_lib work -pa_genrpt=pa+de -o top_pa_opt

vsim top_pa_opt -pa -pa_lib work

add wave sim:/top_tb/clk
add wave sim:/top_tb/intf/rst_n
add wave sim:/top_tb/intf/en
add wave sim:/top_tb/intf/data_in
add wave sim:/top_tb/intf/data_out
add wave sim:/top_tb/dut/reg_data

file mkdir saif_reports

run 20ns

power add -r /top_tb/dut/*

run -all

power report -all -bsaif saif_reports/low_power_baseline.saif
