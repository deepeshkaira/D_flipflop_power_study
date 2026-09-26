# Results and limitations

## Stress workload: PrimeTime PX

| Metric | ASAP7 7 nm manual gate | NanGate 15 nm ICG | 15 nm relative to 7 nm |
|---|---:|---:|---:|
| Internal power | 1.105 µW | 1.730 µW | +56.6% |
| Net switching power | 0.2621 µW | 0.1979 µW | -24.5% |
| Leakage power | 0.003585 µW | 0.4068 µW | approximately 113x |
| Total power | **1.370 µW** | **2.335 µW** | **+70.4%** |

Equivalently, the reported ASAP7 total is 41.3% below the NanGate total for these particular runs.

## Power-group breakdown

| Group | ASAP7 7 nm | NanGate 15 nm |
|---|---:|---:|
| Clock network | 0.6517 µW (47.56%) | 1.315 µW (56.31%) |
| Registers | 0.5057 µW (36.91%) | 1.020 µW (43.69%) |
| Combinational | 0.2128 µW (15.53%) | 0 µW (0%) |

The categories are not directly equivalent. The historical ASAP7 latch-and-logic gate contributes to `combinational`; the NanGate `CLKGATETST_X1` is recognized as part of the clock network. The explicit NanGate clock-gate hierarchy consumes 0.548 µW, or 23.5% of its design total.

## Activity coverage

| Metric | ASAP7 7 nm | NanGate 15 nm |
|---|---:|---:|
| Total nets | 49 | 21 |
| Directly annotated from SAIF | 28 (57.14%) | 19 (90.48%) |
| Primary-input nets annotated | 11/11 | 11/11 |
| Sequential nets annotated | 8/9 | 8/8 |
| Recognized clock-gate nets | none | 1, not directly annotated |

The NanGate ICG was inserted after RTL simulation, so its output net does not exist in the RTL SAIF. PrimeTime derives its behavior from connected activity. Gate-level SAIF would improve direct mapped-cell coverage.

## Analysis limitations

- The ASAP7 run used a manually synthesized gate; the NanGate run used a characterized ICG.
- Nominal operating points differ: ASAP7 reports `PVT_0P7V_25C`; NanGate typical is 0.8 V, 25 C.
- The ASAP7 check reported 44 out-of-range ramps and 17 out-of-range loads.
- The NanGate check reported 27 out-of-range ramps and eight out-of-range loads.
- Neither run includes extracted interconnect parasitics or a wire-load model.
- The SAIF annotation coverage differs substantially.
- UPF was not loaded into PrimeTime; the reported operating voltage comes from each `.db` library.

Accordingly, this repository reports the observed numbers but does not claim that the 41.3% difference is a clock-gating reduction. A valid clock-gating-savings claim requires gated and ungated PrimeTime runs within the same library, operating condition, constraints, and workload.

## Earlier Design Compiler estimates

The earlier vectorless Design Compiler reports showed approximately:

| ASAP7 synthesis estimate | Total |
|---|---:|
| Manually gated | 7.93e-4 report units |
| Baseline | 1.06e-3 report units |

Those values suggested about a 25.2% reduction in that synthesis estimate. They are not substituted for the activity-based PrimeTime results above.

