# Results Logging Protocol

Track every experiment iteration in a structured TSV log. Enables pattern recognition and prevents repeating failed experiments.

## Log File

`logs/research-results.tsv` — created at first EXECUTE phase, gitignored (local only).

## Setup (First EXECUTE)

```bash
# Create log with header and metric direction
echo "# metric_direction: {higher_is_better | lower_is_better}" > logs/research-results.tsv
echo -e "cycle\texp\tcommit\tmetric\tdelta\tguard\tstatus\tdescription" >> logs/research-results.tsv

# Record baseline as experiment 0
BASELINE=$({verify_command})
COMMIT=$(git rev-parse --short HEAD)
echo -e "{cycle}\t0\t${COMMIT}\t${BASELINE}\t0.0\tpass\tbaseline\tinitial state" >> logs/research-results.tsv
```

## Columns

| Column | Type | Description |
|--------|------|-------------|
| cycle | int | Research cycle number (from RSD) |
| exp | int | Experiment number within cycle (0 = baseline) |
| commit | string | Short git hash (7 chars), "-" if reverted |
| metric | float | Measured value from verification |
| delta | float | Change from previous best |
| guard | enum | `pass`, `fail`, or `-` (no guard) |
| status | enum | `baseline`, `keep`, `discard`, `crash`, `no-op` |
| description | string | One-sentence description of what was tried |

## Example

```tsv
cycle	exp	commit	metric	delta	guard	status	description
1	0	a1b2c3d	0.76	0.0	pass	baseline	initial state — F1 baseline
1	1	b2c3d4e	0.82	+0.06	pass	keep	COMPASS alignment at L12
1	2	-	0.79	-0.03	-	discard	alignment at L6 (weaker than L12)
1	3	-	0.00	0.00	-	crash	alignment at L3 (OOM)
1	4	c3d4e5f	0.84	+0.02	pass	keep	increase alignment heads from 4 to 8
```

## Reading the Log

```bash
# Recent entries for pattern recognition
tail -20 logs/research-results.tsv

# Count outcomes
grep -c 'keep' logs/research-results.tsv     # successful changes
grep -c 'discard' logs/research-results.tsv   # failed attempts
grep -c 'crash' logs/research-results.tsv     # crashes

# Detect stuck state: >5 consecutive discards
tail -5 logs/research-results.tsv | awk -F'\t' '{print $7}'

# Descriptions of successful changes
grep 'keep' logs/research-results.tsv | awk -F'\t' '{print $8}'
```

## Summary Reporting

Every 5 iterations (or at loop completion), print:
```
=== Research Progress (cycle {N}, iteration {M}/{max}) ===
Baseline: {baseline} → Current best: {best} ({delta})
Keeps: X | Discards: Y | Crashes: Z
Last 5: keep, discard, discard, keep, keep
```

## Integration

- **Phase 1 (Review):** Read last 10-20 TSV entries + git log for context
- **Phase 7 (Log):** Append row after every keep/discard/crash decision
- **Phase 8 (Repeat):** Back to Phase 1 with updated log
- **INTERPRET phase:** Use TSV data to compute aggregate statistics for prediction delta
