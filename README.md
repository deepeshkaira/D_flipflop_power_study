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

## Main clock-gating result

The clearest gated-versus-ungated result in the preserved reports comes from the ASAP7 Design Compiler estimates. Both implementations use the same ASAP7 library family and the same `PVT_0P7V_25C` operating condition.

| ASAP7 synthesis estimate | Ungated baseline | Gated design | Change |
|---|---:|---:|---:|
| Internal power | 0.999 µW | 0.629 µW | **37.0% lower** |
| Net switching power | 0.0541 µW | 0.161 µW | 197.6% higher |
| Leakage power | 0.00318 µW | 0.00336 µW | 5.7% higher |
| **Total power** | **1.06 µW** | **0.793 µW** | **25.2% lower** |
| Cell area | 74.8829 area units | 78.1488 area units | **4.36% higher** |

The gated design saves approximately **0.267 µW** of estimated total power while adding approximately **3.266 area units**. Most of the saving comes from the 37.0% reduction in internal power: during disabled periods, clock edges no longer reach the eight storage elements. The switching and leakage components increase because the enable latch and gating logic consume power and area of their own.

These are vectorless synthesis estimates, so they show the direction and trade-off of the optimization rather than a final workload-calibrated measurement. The PrimeTime PX results below use simulated SAIF activity.

## Measured stress-workload results

| Technology/run | Internal | Switching | Leakage | Total |
|---|---:|---:|---:|---:|
| ASAP7 7 nm, manually synthesized gate | 1.105 µW | 0.2621 µW | 0.003585 µW | **1.370 µW** |
| NanGate 15 nm, `CLKGATETST_X1` ICG | 1.730 µW | 0.1979 µW | 0.4068 µW | **2.335 µW** |

Under these specific runs, the reported ASAP7 total is 41.3% lower than the NanGate 15 nm total. This is not a clock-gating-savings measurement: the two runs use different clock-gate implementations, libraries, nominal voltages, and SAIF annotation coverage. See [Results and limitations](docs/RESULTS.md).

In absolute terms, the ASAP7 implementation consumes **0.965 µW less** total power in this experiment. Conversely, the NanGate result is **70.4% higher** than the ASAP7 result. These percentages describe only the two mapped implementations in this repository; they are not universal 7 nm-versus-15 nm scaling factors.

### Power-group breakdown

| Power group | ASAP7 7 nm | NanGate 15 nm |
|---|---:|---:|
| Clock network | 0.6517 µW (47.56%) | 1.315 µW (56.31%) |
| Registers | 0.5057 µW (36.91%) | 1.020 µW (43.69%) |
| Combinational logic | 0.2128 µW (15.53%) | 0 µW (0%) |

The grouping differs because the clock gates are implemented differently. The historical ASAP7 version uses a latch plus mapped logic, so some gating power appears under combinational logic. The NanGate implementation uses the characterized `CLKGATETST_X1` integrated clock-gating cell, which PrimeTime recognizes as part of the clock network. The NanGate clock-gate hierarchy alone accounts for approximately **0.548 µW**, or **23.5%** of that design's total power.

### What the reported power terms mean

- **Internal power** is consumed inside standard cells as their internal nodes charge and discharge. Flip-flop clock pins and internal clock circuitry are major contributors, making this the component that clock gating principally targets.
- **Switching power** is consumed while charging and discharging net and pin capacitance. It depends on activity, capacitance, clock frequency, and supply voltage.
- **Leakage power** is static power drawn while cells remain powered, even when they do not switch. It depends on the process, threshold-voltage option, cell sizing, voltage, and temperature.
- **Total power** is the sum of internal, switching, and leakage power.

For the ASAP7 PrimeTime run, internal power contributes approximately **80.7%**, switching power **19.1%**, and leakage power **0.26%**. For NanGate 15 nm, the corresponding shares are approximately **74.1%**, **8.48%**, and **17.42%**. The much larger leakage component is a significant reason that the NanGate total is higher despite its lower net-switching result.

## Design evolution

### Ungated enabled register

The baseline is an 8-bit register with an asynchronous active-low reset. When `en` is asserted, `data_in` is captured on the rising clock edge; when it is deasserted, the stored value is retained. Although the data state does not change during idle cycles, an ungated implementation can still deliver every clock edge to all eight flip-flops and consume clock-related dynamic power.

### Manually gated ASAP7 implementation

The historical ASAP7 experiment captures the enable while the source clock is low and combines it with the clock to produce a glitch-free gated clock. The mapped implementation contains eight `ASYNC_DFFHx1_ASAP7_75t_R` cells, one `DLLx1_ASAP7_75t_R` enable latch, and the inverters and logic gates required by technology mapping.

The mapped cell area rises from **74.8829** to **78.1488** area units. This 4.36% overhead is the physical cost paid for suppressing clock activity during idle periods.

### Synthesis-inserted NanGate integrated clock gate

For NanGate 15 nm, the RTL remains technology-neutral and Design Compiler performs automatic clock-gate insertion. Inspection of the mapped netlist and reference report confirmed:

- one `CLKGATETST_X1` integrated clock-gating cell;
- eight `DFFRNQ_X1` asynchronous-reset flip-flops.

Using a characterized ICG is preferable to constructing a gate from arbitrary Boolean cells because the library provides defined timing, power, test-enable, and clock-gating behavior that downstream tools can recognize.

## UVM verification and workloads

The testbench contains a sequence item, sequencer, driver, monitor, agent, environment, test, and queue-based scoreboard. The monitor samples the DUT after its nonblocking assignments, and the scoreboard maintains the expected register state in transaction order:

- reset clears the expected value to `8'h00`;
- `en == 1` updates it from `data_in`;
- `en == 0` retains the previous value;
- each expected value is queued and compared with the monitored `data_out`.

Four useful traffic styles were developed:

- **active sequence:** randomized data with enable asserted;
- **idle sequence:** enable deasserted to verify state retention;
- **clock-gating sequence:** long active and idle windows to exercise clock start/stop behavior;
- **stress sequence:** alternating data, toggling inputs while disabled, and alternating enable activity.

The stress workload includes `00/FF` alternation while enabled, `AA/55` input toggling while disabled, and alternating enable cycles using `8'hA5 ^ i`. This matters because power depends on both the circuit and the workload applied to it.

## Role of UPF

The UPF files describe power intent separately from the functional RTL. They define the `PD_TOP` domain, the VDD and VSS supply ports, the internal `VDD_n` and `VSS_n` supply nets, their domain connections, and the valid supply states.

| Technology | UPF supply voltage | Library operating point |
|---|---:|---|
| ASAP7 7 nm | 0.7 V | `PVT_0P7V_25C` |
| NanGate 15 nm | 0.8 V | Typical, 25 °C |

In Questa, UPF establishes and validates the power-aware architecture. It is not required solely to create a SAIF file—ordinary simulation can also generate SAIF. Its value is that the functional simulation is performed with explicit power-domain and supply intent. This design currently has one always-on domain, so isolation, retention, level shifting, and power switching are not yet instantiated.

## Role of SAIF

SAIF records state durations and transition counts for signals over the simulated interval. PrimeTime combines this workload activity with the characterized capacitance, internal-energy, and leakage data stored in the technology libraries.

Changing the UVM sequence changes the SAIF and can therefore change the final power result without changing the RTL or netlist. An idle-heavy test is expected to show a larger clock-gating benefit than a continuously active test. The same stress SAIF was used for the two technology experiments to keep the logical workload as consistent as possible.

### Activity annotation coverage

| SAIF annotation metric | ASAP7 7 nm | NanGate 15 nm |
|---|---:|---:|
| Total analyzed nets | 49 | 21 |
| Directly annotated from SAIF | 28 (57.14%) | 19 (90.48%) |
| Primary-input nets annotated | 11/11 | 11/11 |
| Sequential nets annotated | 8/9 | 8/8 |

The NanGate ICG was created during synthesis and therefore did not exist in the RTL simulation that produced the SAIF. PrimeTime inferred activity for synthesis-created nets from connected activity. A gate-level SAIF would provide stronger direct annotation for those mapped nets.

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

## How the analysis artifacts fit together

```text
SystemVerilog RTL + UVM sequences + UPF
                   |
                   v
       Questa power-aware simulation
                   |
                   v
          workload activity (SAIF)
                   |
                   +--------------------------+
                                              |
RTL + SDC + technology libraries              |
                   |                          |
                   v                          |
       Synopsys Design Compiler               |
                   |                          |
                   v                          v
          mapped netlist + SDC ----------> PrimeTime PX
                                              |
                                              v
                         internal / switching / leakage / total power
```

Design Compiler generates the technology-mapped Verilog netlist and the synthesized SDC used by PrimeTime. Questa provides workload activity through SAIF. PrimeTime reads those artifacts together with the characterized `.db` library and calculates averaged power.

The Design Compiler report and the PrimeTime report serve different purposes. The synthesis estimate is useful for early comparison and optimization, while PrimeTime uses the mapped design and explicit simulation activity for a more workload-specific analysis. This explains why the ASAP7 Design Compiler gated estimate of 0.793 µW should not be numerically substituted for the ASAP7 PrimeTime result of 1.370 µW.

## Interpretation limits

- The same-library gated-versus-ungated result is currently a Design Compiler estimate, not a matched pair of PrimeTime PX runs.
- The 7 nm PrimeTime implementation uses a manual latch-and-logic clock gate; the 15 nm implementation uses a characterized ICG.
- ASAP7 is analyzed at 0.7 V, while NanGate is analyzed at 0.8 V.
- SAIF annotation coverage differs between the two mapped netlists.
- The ASAP7 power check reports 44 out-of-range ramps and 17 out-of-range loads.
- The NanGate power check reports 27 out-of-range ramps and eight out-of-range loads.
- Neither run includes extracted interconnect parasitics or a wire-load model.

The defensible conclusions are therefore:

1. The ASAP7 synthesis estimates show a **25.2% total-power reduction** from clock gating with a **4.36% cell-area increase**.
2. Clock gating reduces internal clocked-cell power, but it introduces switching, leakage, area, and timing overhead.
3. Under the shared stress workload, PrimeTime reports **1.370 µW** for ASAP7 and **2.335 µW** for NanGate 15 nm.
4. The 41.3% lower ASAP7 result demonstrates library and implementation sensitivity; it is not a universal process-node comparison.
5. A final activity-based clock-gating claim requires gated and ungated PrimeTime runs in the same library with identical constraints and stimulus.

## Library policy

Compiled `.db` files and source PDK libraries are intentionally excluded from Git. Even when a library is openly available, keeping generated binaries out of the repository avoids large files and unclear redistribution terms. Scripts and expected filenames are included instead.

The ASAP7 source is divided into AO, INVBUF, OA, SEQ, and SIMPLE Liberty libraries, resulting in five compiled `.db` files. NanGate 15 nm packages its available cells in one combined Liberty library, so one compiled `.db` is sufficient. The investigated NanGate package includes ordinary logic, sequential cells, and an integrated clock-gating cell, but no characterized isolation, level-shifter, retention, or power-switch cells were identified.

## Current evidence status

- The original NanGate 15 nm PrimeTime reports are preserved under `reports/nangate15_15nm/stress/`.
- The original ASAP7 PrimeTime and synthesis reports are preserved under `reports/asap7_7nm/`.
- The archived ASAP7 mapped Verilog/SDC outputs and all three SAIF files are included.
- The exact server-side Questa testbench and `.do` file are archived, alongside cleaned repository versions.
- The NanGate mapped netlist/SDC and its Design Compiler reports still need to be exported if they are to be versioned.
