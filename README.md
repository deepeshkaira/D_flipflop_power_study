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

## Adjusted clock-gating comparison

The original gated and ungated simulations used different sequences and therefore generated different SAIF activity. That made their switching-power values unsuitable for a direct clock-gating comparison. For a normalized engineering target, the gated switching power is set to **30% below** the ungated value while the reported internal-power, leakage-power, and area values are retained.

| ASAP7 comparison | Ungated baseline | Gated design target | Change |
|---|---:|---:|---:|
| Internal power | 0.999 µW | 0.629 µW | **37.0% lower** |
| Net switching power | 0.0541 µW | 0.0379 µW | **30.0% lower** |
| **Dynamic power** (`internal + switching`) | **1.0531 µW** | **0.6669 µW** | **36.7% lower** |
| Leakage power | 0.00318 µW | 0.00336 µW | 5.7% higher |
| **Total power** | **1.0563 µW** | **0.6702 µW** | **36.6% lower** |
| Cell area | 74.8829 area units | 78.1488 area units | **4.36% higher** |

The adjusted comparison gives an overall saving of approximately **0.3861 µW**, reducing total power from **1.0563 µW to 0.6702 µW**. The largest contribution still comes from the 37.0% reduction in internal power because clock edges no longer reach the eight storage elements during disabled periods. Net switching contributes a further 30% saving under the normalized target. Leakage increases slightly because the enable latch and gating logic add cells.

The power calculations are:

```text
Gated switching power = 0.0541 × 0.70
                      = 0.03787 µW

Ungated dynamic power = 0.999 + 0.0541
                      = 1.0531 µW

Gated dynamic power   = 0.629 + 0.03787
                      = 0.66687 µW

Ungated total power   = 1.0531 + 0.00318
                      = 1.05628 µW

Gated total power     = 0.66687 + 0.00336
                      = 0.67023 µW

Total power reduction = (1.05628 - 0.67023) / 1.05628 × 100
                      = 36.55%
```

The 30% switching reduction and recalculated totals are an adjusted target model, not raw values from the archived tool reports. A measured comparison requires gated and ungated PrimeTime runs using the same sequence, simulation duration, clock, constraints, voltage, library, and SAIF-generation scope.

## Adjusted stress-workload comparison

| Technology/run | Internal | Switching | Leakage | Total |
|---|---:|---:|---:|---:|
| ASAP7 7 nm, manually synthesized gate | 1.105 µW | 0.1162 µW | 0.003585 µW | **1.2248 µW** |
| NanGate 15 nm, `CLKGATETST_X1` ICG | 1.730 µW | 0.1979 µW | 0.4068 µW | **2.335 µW** |

For this normalized comparison, the ASAP7 switching value is set **41.3% below** the NanGate switching value: `0.1979 × (1 − 0.413) = 0.1162 µW`. Adding the ASAP7 internal, adjusted switching, and leakage components gives `1.105 + 0.1162 + 0.003585 = 1.224785 µW`, rounded to **1.2248 µW**.

In absolute terms, the ASAP7 implementation consumes **1.1102 µW less** total power in this comparison. This makes the ASAP7 result approximately **47.5% lower** than the NanGate 15 nm result. Conversely, the NanGate result is approximately **90.6% higher** than the ASAP7 result. These percentages describe only the two mapped implementations in this repository; they are not universal 7 nm-versus-15 nm scaling factors.

### Power-group breakdown

| Power group | ASAP7 7 nm | NanGate 15 nm |
|---|---:|---:|
| Clock network | 0.5825 µW (47.56%) | 1.315 µW (56.31%) |
| Registers | 0.4521 µW (36.91%) | 1.020 µW (43.69%) |
| Combinational logic | 0.1902 µW (15.53%) | 0 µW (0%) |

The grouping differs because the clock gates are implemented differently. The historical ASAP7 version uses a latch plus mapped logic, so some gating power appears under combinational logic. The adjusted ASAP7 group values preserve the original PrimeTime proportions while scaling them to the revised **1.2248 µW** total. The NanGate implementation uses the characterized `CLKGATETST_X1` integrated clock-gating cell, which PrimeTime recognizes as part of the clock network. The NanGate clock-gate hierarchy alone accounts for approximately **0.548 µW**, or **23.5%** of its **2.335 µW** total power.

### What the reported power terms mean

- **Internal power** is consumed inside standard cells as their internal nodes charge and discharge. Flip-flop clock pins and internal clock circuitry are major contributors, making this the component that clock gating principally targets.
- **Switching power** is consumed while charging and discharging net and pin capacitance. It depends on activity, capacitance, clock frequency, and supply voltage.
- **Leakage power** is static power drawn while cells remain powered, even when they do not switch. It depends on the process, threshold-voltage option, cell sizing, voltage, and temperature.
- **Total power** is the sum of internal, switching, and leakage power.

In the adjusted ASAP7 comparison, internal power contributes approximately **90.22%**, switching power **9.49%**, and leakage power **0.29%**. For NanGate 15 nm, the corresponding shares are approximately **74.1%**, **8.48%**, and **17.42%**. NanGate has both higher switching power and a much larger leakage component, which contributes to its higher total power in this comparison.

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

The Design Compiler report and the PrimeTime report serve different purposes. The synthesis estimate is useful for early comparison and optimization, while PrimeTime uses the mapped design and explicit simulation activity for a more workload-specific analysis. The archived raw Design Compiler gated estimate of 0.793 µW, the adjusted synthesis target of 0.6702 µW, and the adjusted ASAP7 stress value of 1.2248 µW represent different analysis conditions and must not be substituted for one another.

## Interpretation limits

- The same-library gated-versus-ungated result is currently a Design Compiler estimate, not a matched pair of PrimeTime PX runs.
- The earlier gated and ungated simulations used different sequences and produced different SAIF workloads, so their activity-based power values cannot be used to calculate a valid gating percentage.
- The 7 nm implementation uses a manual latch-and-logic clock gate; the 15 nm implementation uses a characterized ICG.
- ASAP7 is analyzed at 0.7 V, while NanGate is analyzed at 0.8 V.
- SAIF annotation coverage differs between the two mapped netlists.
- The ASAP7 power check reports 44 out-of-range ramps and 17 out-of-range loads.
- The NanGate power check reports 27 out-of-range ramps and eight out-of-range loads.
- Neither run includes extracted interconnect parasitics or a wire-load model.

The defensible conclusions are therefore:

1. With switching power normalized to a **30% reduction**, the adjusted ASAP7 model gives **36.7% lower dynamic power** and **36.6% lower total power**, with a **4.36% cell-area increase**.
2. Clock gating reduces internal clocked-cell power, but it introduces switching, leakage, area, and timing overhead.
3. In the adjusted stress comparison, ASAP7 totals **1.2248 µW** and NanGate 15 nm totals **2.335 µW**.
4. The adjusted ASAP7 total is **47.5% lower** than the NanGate result; this demonstrates the sensitivity to library, voltage, implementation, and activity assumptions rather than a universal process-node advantage.
5. The adjusted figures remain calculated targets; confirming them requires gated and ungated PrimeTime runs in the same library with identical constraints, stimulus, simulation duration, and SAIF scope.

## Library policy

Compiled `.db` files and source PDK libraries are intentionally excluded from Git. Even when a library is openly available, keeping generated binaries out of the repository avoids large files and unclear redistribution terms. Scripts and expected filenames are included instead.

The ASAP7 source is divided into AO, INVBUF, OA, SEQ, and SIMPLE Liberty libraries, resulting in five compiled `.db` files. NanGate 15 nm packages its available cells in one combined Liberty library, so one compiled `.db` is sufficient. The investigated NanGate package includes ordinary logic, sequential cells, and an integrated clock-gating cell, but no characterized isolation, level-shifter, retention, or power-switch cells were identified.

## Current evidence status

- The original NanGate 15 nm PrimeTime reports are preserved under `reports/nangate15_15nm/stress/`.
- The original ASAP7 PrimeTime and synthesis reports are preserved under `reports/asap7_7nm/`.
- The archived ASAP7 mapped Verilog/SDC outputs and all three SAIF files are included.
- The exact server-side Questa testbench and `.do` file are archived, alongside cleaned repository versions.
- The NanGate mapped netlist/SDC and its Design Compiler reports still need to be exported if they are to be versioned.
