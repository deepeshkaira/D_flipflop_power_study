###################################################################

# Created by write_sdc on Tue Sep 15 23:49:57 2026

###################################################################
set sdc_version 2.1

set_units -time ps -resistance kOhm -capacitance fF -voltage V -current mA
create_clock [get_ports clk]  -period 10000  -waveform {0 5000}
set_clock_uncertainty 100  [get_clocks clk]
set_input_delay -clock clk  1000  [get_ports en]
set_input_delay -clock clk  1000  [get_ports {data_in[7]}]
set_input_delay -clock clk  1000  [get_ports {data_in[6]}]
set_input_delay -clock clk  1000  [get_ports {data_in[5]}]
set_input_delay -clock clk  1000  [get_ports {data_in[4]}]
set_input_delay -clock clk  1000  [get_ports {data_in[3]}]
set_input_delay -clock clk  1000  [get_ports {data_in[2]}]
set_input_delay -clock clk  1000  [get_ports {data_in[1]}]
set_input_delay -clock clk  1000  [get_ports {data_in[0]}]
set_output_delay -clock clk  1000  [get_ports {data_out[7]}]
set_output_delay -clock clk  1000  [get_ports {data_out[6]}]
set_output_delay -clock clk  1000  [get_ports {data_out[5]}]
set_output_delay -clock clk  1000  [get_ports {data_out[4]}]
set_output_delay -clock clk  1000  [get_ports {data_out[3]}]
set_output_delay -clock clk  1000  [get_ports {data_out[2]}]
set_output_delay -clock clk  1000  [get_ports {data_out[1]}]
set_output_delay -clock clk  1000  [get_ports {data_out[0]}]
set_false_path   -from [get_ports rst_n]
