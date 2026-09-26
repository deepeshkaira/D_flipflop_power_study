# End-to-end flow

## 1. Functional and power-aware simulation

The UVM testbench drives `en` and `data_in` on the falling edge of the root clock and samples outputs after the following rising-edge nonblocking assignments. The scoreboard models reset, capture when enabled, and hold when disabled.

UPF defines a single primary power domain with `VDD_n` and `VSS_n`. The testbench calls `supply_on` during initialization. This verifies supply-aware behavior; it is not required merely to generate SAIF.

SAIF records state durations and transition counts from the simulated workload. Changing the sequence changes the activity and therefore changes activity-based power.

## 2. Library preparation

ASAP7 is partitioned into AO, INVBUF, OA, SEQ, and SIMPLE Liberty libraries. The RVT/TT NLDM files were converted into five Synopsys `.db` files.

NanGate 15 nm provides one combined 76-cell Liberty library per corner. Its typical NLDM file was converted into one `.db` file. It includes `CLKGATETST_X1`, classified as `latch_posedge_precontrol`.

## 3. Synthesis

The historical ASAP7 gated run used an RTL latch-and-AND clock gate. Its power is distributed across clock, register, and combinational groups.

The NanGate run uses technology-neutral enabled-register RTL and:

```tcl
compile_ultra -gate_clock
```

Design Compiler inserted one `CLKGATETST_X1` feeding eight `DFFRNQ_X1` cells. A failed attempt to force a plain `latch_posedge` style was removed because the available NanGate ICG is the `latch_posedge_precontrol` form; the default integrated style maps it correctly.

Each clean synthesis script uses a separate `WORK` directory to prevent stale analyzed modules from leaking between runs.

## 4. PrimeTime PX

PrimeTime consumes:

- the technology-mapped Verilog netlist;
- the SDC exported by Design Compiler;
- the matching technology `.db` library;
- the stress-workload SAIF from Questa.

The current analysis is averaged, pre-layout power. No SPEF or wire-load model is applied.

## 5. Interpretation rules

- Compare PrimeTime results with PrimeTime results, not with Design Compiler's vectorless estimate.
- Reuse the same workload for technology comparisons.
- Measure clock-gating savings within one technology by comparing gated and ungated implementations under identical activity.
- Treat cross-library results as implementation comparisons, not as proof that one process node inherently consumes a fixed percentage less power.

