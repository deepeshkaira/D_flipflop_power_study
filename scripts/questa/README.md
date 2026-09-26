# Questa simulation and SAIF generation

The original laboratory script is preserved under `archive/run_low_power_block.do`. The cleaned repository script is `run_asap7_stress.do`; it uses repository-relative paths and writes the stress SAIF expected by the PrimeTime scripts.

The verified logical sequence was:

1. Create or reuse the `work` library.
2. Compile `rtl/low_power_block.sv` and `tb/testbench.sv` with SystemVerilog and the installed Questa UVM package.
3. Elaborate `top_tb` with the selected UPF applied at the DUT scope.
4. In the testbench, turn on `VDD` and `VSS` with `supply_on` using the voltage matching the selected UPF.
5. Run `lp_test` with the stress sequence.
6. Record DUT activity below `top_tb/dut`.
7. Write `saif/low_power_gated_stress.saif`.
8. Preserve the Questa PA architecture report separately from the SAIF.

The harmless message below means the library already exists:

```text
Warning: (vlib-34) Library already exists at "work".
```

From the repository root, the intended GUI invocation is:

```tcl
do scripts/questa/run_asap7_stress.do
```

The testbench defaults to 0.7 V. For a 15 nm UPF-aware RTL simulation, use 0.8 V consistently in both `upf/low_power_nangate15_0p8v.upf` and the `top_tb.VDD_VOLTAGE` parameter. PrimeTime obtains voltage from the timing/power library unless its script explicitly loads UPF.

The archived server script records activity after the first 20 ns of reset/setup time, which avoids counting initialization in the SAIF window. The cleaned script preserves that behavior.
