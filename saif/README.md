# Switching activity

Place Questa-generated SAIF files here. The stress scripts expect:

```text
low_power_gated_stress.saif
```

For technology comparisons, reuse the same workload activity wherever signal mapping permits. A gate-level SAIF for each mapped netlist gives higher annotation coverage but is a different methodology and must be labelled accordingly.

The committed `low_power_gated_stress.saif` is the original file from the historical manually gated ASAP7 RTL run. The cleaned Questa script regenerates the same named workload file from the technology-neutral enabled-register RTL. Record which version was used whenever publishing a comparison.
