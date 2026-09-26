create_clock -name clk -period 10000.000 [get_ports clk]

set_clock_uncertainty 100.000 [get_clocks clk]

set_input_delay 1000.000 -clock [get_clocks clk] [get_ports {en data_in[*]}]

set_output_delay 1000.000 -clock [get_clocks clk] [get_ports {data_out[*]}]

set_false_path -from [get_ports rst_n]
