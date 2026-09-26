# Next steps

## Complete the local evidence

- Export the NanGate mapped Verilog, SDC, clock-gating report, synthesis reports, and synthesis log from the server.
- Preserve the final 15 nm PrimeTime log alongside the existing text reports if desired.
- Confirm the committed SAIF checksum against the file used by both PrimeTime runs.

## Make the clock-gating comparison rigorous

- Synthesize an ungated NanGate baseline with `scripts/dc/synthesize_baseline_asap7.tcl` adapted to the NanGate library.
- Run gated and ungated NanGate netlists through PrimeTime with the same SAIF and constraints.
- Investigate whether ASAP7 contains a characterized ICG that Design Compiler can insert; otherwise label the ASAP7 run as manual-gate synthesis.
- Do not present the cross-library 41.3% difference as clock-gating savings.

## Improve accuracy

- Generate gate-level SAIF for each mapped netlist if direct cell annotation is required.
- Add realistic input drivers and output loads to reduce out-of-table-range warnings.
- Run physical design and annotate SPEF before making signoff-quality claims.
- Review disabled timing arcs and explicitly constrain asynchronous reset behavior.

## Extend the UPF exercise

- Add a genuinely switchable secondary domain.
- Add isolation strategy and control sequencing.
- Add retention only after locating a characterized retention-cell library.
- Add level shifting only when two legal voltage domains and matching level-shifter cells are available.

## Publish

- Choose a repository license.
- Review PDK and generated-netlist redistribution terms.
- Create the GitHub repository and add it as `origin`.
- Push `main` only after checking that no `.db`, Liberty, credentials, or server-only paths were accidentally staged.

