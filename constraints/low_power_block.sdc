# Both characterized libraries use ps as their timing unit.
# 10,000 ps = 10 ns = 100 MHz.

create_clock -name clk -period 10000 [get_ports clk]
set_clock_uncertainty 100 [get_clocks clk]

set data_inputs [remove_from_collection [all_inputs] [get_ports {clk rst_n}]]
set_input_delay 1000 -clock clk $data_inputs
set_input_transition 50 $data_inputs
set_output_delay 1000 -clock clk [all_outputs]
set_load 1 [all_outputs]

# Reset is asynchronous and is excluded from ordinary clocked data-path timing.
set_false_path -from [get_ports rst_n]

