# Archived server-run notes

The exact ASAP7 server artifacts are preserved under:

- `rtl/archive/`
- `constraints/archive/`
- `upf/archive/`
- `scripts/archive/asap7_7nm/`
- `reports/asap7_7nm/`
- `netlist/*_7nm.*`
- `saif/low_power_*.saif`

The archived UPF declares 1.0 V, while the PrimeTime report used the ASAP7 library's `PVT_0P7V_25C` operating condition. This demonstrates that the PrimeTime script obtained voltage from the `.db`, not the UPF.

The archived `synthesize_baseline.tcl` and `synthesize_gated.tcl` both currently analyze `rtl/low_power_block.sv`. At archive time that RTL contains the manual gate. The saved baseline netlist was generated from an earlier ungated revision that is no longer present at that path. For reproducibility, use the clean scripts under `scripts/dc/`, which explicitly select the appropriate RTL variant.

