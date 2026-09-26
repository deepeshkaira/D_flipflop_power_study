# Technology library staging

Technology libraries are not committed. Create these files locally before running synthesis or PrimeTime.

## ASAP7 7 nm

Expected under `lib/asap7_db/`:

```text
asap7sc7p5t_AO_RVT_TT_08302018.db
asap7sc7p5t_INVBUF_RVT_TT_08302018.db
asap7sc7p5t_OA_RVT_TT_08302018.db
asap7sc7p5t_SEQ_RVT_TT_08302018.db
asap7sc7p5t_SIMPLE_RVT_TT_08302018.db
```

They were compiled from the ASAP7 RVT/TT NLDM Liberty files. CCS conversion was not used because the installed Library Compiler rejected unsupported waveform constructs.

## NanGate 15 nm

Expected under `lib/nangate15_db/`:

```text
NanGate_15nm_OCL_typical.db
```

Server source Liberty:

```text
/apps/cds/ic618/local/NanGate_15nm/front_end/timing_power_noise/NLDM/NanGate_15nm_OCL_typical_conditional_nldm.lib
```

The combined NanGate library contains 76 cells, including `DFFRNQ_X1` and the `CLKGATETST_X1` integrated clock-gating cell.

