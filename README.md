# Power-Aware DFF Verification and Power Analysis

This repository records a small ASIC low-power lab built around an 8-bit enabled D flip-flop. It progresses from functional UVM verification and UPF-aware simulation to SAIF-driven synthesis and PrimeTime power analysis.

The completed experiments cover:

- an enabled, ungated RTL baseline;
- a historical manually gated ASAP7 7 nm implementation;
- synthesis-inserted integrated clock gating with the NanGate 15 nm library;
- activity generation with Questa and SAIF;
- synthesis with Synopsys Design Compiler;
- averaged power analysis with PrimeTime PX;
- an initial 7 nm versus 15 nm stress-workload comparison.

## Measured stress-workload results

| Technology/run | Internal | Switching | Leakage | Total |
|---|---:|---:|---:|---:|
| ASAP7 7 nm, manually synthesized gate | 1.105 µW | 0.2621 µW | 0.003585 µW | **1.370 µW** |
| NanGate 15 nm, `CLKGATETST_X1` ICG | 1.730 µW | 0.1979 µW | 0.4068 µW | **2.335 µW** |

Under these specific runs, the reported ASAP7 total is 41.3% lower than the NanGate 15 nm total. This is not a clock-gating-savings measurement: the two runs use different clock-gate implementations, libraries, nominal voltages, and SAIF annotation coverage. See [Results and limitations](docs/RESULTS.md).

## Repository layout

```text
rtl/                 Technology-neutral and historical RTL variants
tb/                  UVM testbench and stress sequence
upf/                 Voltage-specific UPF files and archived original UPF
constraints/         Shared synthesis/timing constraints
scripts/lc/          Liberty-to-DB Library Compiler scripts
scripts/dc/          Design Compiler baseline and gated runs
scripts/pt/          PrimeTime PX activity-based power runs
scripts/questa/      Questa workflow notes
lib/                 Local library staging instructions; libraries are ignored
netlist/             Generated Verilog/SDC outputs when exported from the server
saif/                Questa-generated activity files when exported from the server
reports/             Preserved text reports grouped by technology
docs/                Flow, methodology, results, and known limitations
```

## Tool chain

- Siemens Questa for UVM and power-aware simulation
- IEEE 1801 UPF for supply-domain intent
- SAIF for workload activity exchange
- Synopsys Library Compiler for `.lib` to `.db` conversion
- Synopsys Design Compiler for technology mapping and clock-gate insertion
- Synopsys PrimeTime PX for averaged power analysis

The laboratory server requires:

```bash
source /apps/enable
```

## Reproducing the flow

1. Stage the libraries described in [lib/README.md](lib/README.md).
2. Run UVM/UPF simulation and generate the stress SAIF as described in [scripts/questa/README.md](scripts/questa/README.md).
3. Synthesize the selected implementation from the repository root.
4. Run the matching PrimeTime script using the generated technology netlist, SDC, and shared SAIF.
5. Review `check_timing`, `check_power`, activity coverage, and verbose power reports before comparing numbers.

See [Next steps](docs/NEXT_STEPS.md) for the remaining runs and publication checklist.

Example NanGate commands:

```bash
dc_shell -f scripts/dc/synthesize_gated_nangate15.tcl |& tee logs/synthesize_gated_15nm.log
pt_shell -f scripts/pt/primetime_stress_nangate15.tcl |& tee logs/primetime_stress_15nm.log
```

## Library policy

Compiled `.db` files and source PDK libraries are intentionally excluded from Git. Even when a library is openly available, keeping generated binaries out of the repository avoids large files and unclear redistribution terms. Scripts and expected filenames are included instead.

## Current evidence status

- The original NanGate 15 nm PrimeTime reports are preserved under `reports/nangate15_15nm/stress/`.
- The original ASAP7 PrimeTime and synthesis reports are preserved under `reports/asap7_7nm/`.
- The archived ASAP7 mapped Verilog/SDC outputs and all three SAIF files are included.
- The exact server-side Questa testbench and `.do` file are archived, alongside cleaned repository versions.
- The NanGate mapped netlist/SDC and its Design Compiler reports still need to be exported if they are to be versioned.
