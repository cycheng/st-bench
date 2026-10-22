---
name: mxdatagen-bit-transition
description: >-
  Run and analyze MXDataGenerator True/False experiments for TensileLite YAMLs.
  Use when investigating whether input data patterns affect bit transitions,
  power, sustained GPU frequency, or MAF throughput.
---

# MXDataGenerator Bit-Transition Experiment

Use this workflow to compare `MXDataGenerator: True` and `False` with the same
TensileLite kernel configuration, then correlate performance and frequency
with A/B input bit-pattern statistics.

## Inputs

Use any TensileLite YAML as the source:

```bash
export SOURCE_YAML=/path/to/input.yaml
```

Use an existing `st-bench` host config for the target build. Prefer a config
that does not dump StinkyTofu ASM unless ASM is part of the investigation:

```bash
CONFIG=/path/to/host-config.cfg
```

## Create True/False YAML Variants

Create temporary variants beside the experiment outputs, not as committed
source files:

```bash
cd ~/st-bench
mkdir -p experiments/mxdatagen_bit_test/yamls

python3 - <<'PY'
import os
from pathlib import Path

source = Path(os.environ["SOURCE_YAML"]).expanduser().resolve()
out_dir = Path("experiments/mxdatagen_bit_test/yamls")
text = source.read_text()

lines = [line for line in text.splitlines() if not line.strip().startswith("MXDataGenerator:")]
text = "\n".join(lines) + "\n"

for value in ("True", "False"):
    out = out_dir / f"{source.stem}_mxdatagen_{value.lower()}.yaml"
    out.write_text(text.replace("GlobalParameters:\n", f"GlobalParameters:\n  MXDataGenerator: {value}\n", 1))
    print(out)
PY
```

## Run Performance Repeats

For arbitrary YAMLs, use `run-single-yaml.sh` in a repeat loop. If the YAML is
already supported by a benchmark driver that collects PM logs, use that driver;
otherwise collect PM logs separately around each run.

```bash
cd ~/st-bench
OUTDIR="experiments/mxdatagen_bit_test/perf-$(date +%Y%m%d-%H%M%S)"
mkdir -p "${OUTDIR}/logs"

for variant in true false; do
  yaml="experiments/mxdatagen_bit_test/yamls/$(basename "${SOURCE_YAML%.yaml}")_mxdatagen_${variant}.yaml"
  for run in 1 2 3; do
    ./scripts/run-single-yaml.sh "${CONFIG}" "${yaml}" --live-output \
      > "${OUTDIR}/logs/${variant}.run-${run}.log" 2>&1
  done
done
```

From each run log, extract the CSV result row and record:

- validation status
- time-us
- gflops
- PF, computed as `gflops / 1e6`
- PM frequency and power if PM logging was enabled

If a run fails with `hipErrorLaunchFailure` or `nan`, do not include that
sample in finite-sample averages; rerun the affected variant if more clean
samples are needed.

## Small A/B Input Dumps

Create debug-size YAMLs from the True/False variants. Use a small problem so
A/B can be printed:

```bash
cd ~/st-bench
mkdir -p experiments/mxdatagen_bit_test/dumps

python3 - <<'PY'
from pathlib import Path

src_dir = Path("experiments/mxdatagen_bit_test/yamls")
out_dir = Path("experiments/mxdatagen_bit_test/dumps")

for src in sorted(src_dir.glob("*_mxdatagen_*.yaml")):
    text = src.read_text()
    text = text.replace("  NumWarmups: 160\n", "  NumWarmups: 0\n", 1)
    text = text.replace("  EnqueuesPerSync: 1600\n", "  EnqueuesPerSync: 1\n", 1)
    text = text.replace("  KeepBuildTmp: True\n", "  KeepBuildTmp: False\n", 1)
    text = text.replace("  DataInitTypeBeta: 0\n", "  DataInitTypeBeta: 0\n  PrintTensorA: 1\n  PrintTensorB: 1\n", 1)

    lines = text.splitlines()
    out = []
    skipping = False
    for line in lines:
        if line.strip() == "- ProblemSizes:":
            out.append(line)
            out.append("          - Exact: [16, 16, 1, 128]")
            skipping = True
            continue
        if skipping and line.startswith("          - Exact:"):
            continue
        skipping = False
        out.append(line)

    dst = out_dir / f"{src.stem}_dump.yaml"
    dst.write_text("\n".join(out) + "\n")
    print(dst)
PY

for yaml in experiments/mxdatagen_bit_test/dumps/*_dump.yaml; do
  ./scripts/run-single-yaml.sh "${CONFIG}" "${yaml}" --live-output \
    > "${yaml%.yaml}.log" 2>&1
done
```

## Bit-Pattern Analysis

The client usually prints decoded tensor values, not raw bytes. Treat
reconstructed FP8 bytes as a proxy unless the client is changed to dump raw hex
bytes.

For each True/False dump:

1. Extract the `A: [a]` block until `B: [b]`.
2. Extract the `B: [b]` block until the CSV result header.
3. Parse numeric values inside the final tensor bracket.
4. Map each printed value to the nearest expected FP8 byte for the YAML data
   type.
5. Compute:
   - value histogram and unique-value count
   - min, max, mean absolute value, zero fraction
   - average Hamming weight of encoded bytes
   - average adjacent Hamming distance in printed memory order
   - optional per-bit one fraction

Use bit statistics as supporting evidence only. Final output bits are not
enough to prove switching behavior because internal datapath transitions are
not directly visible.

## Summary Format

Report two compact tables:

```text
Runtime:
variant passed PF_avg PF_std PF_best us_avg PM_freq_GHz_avg PM_freq_GHz_best power_avg_if_available

Bit stats:
variant tensor range mean_abs zero_fraction avg_hamming_weight avg_adjacent_hamming_distance
```

Interpretation:

- If `MXDataGenerator=True` has higher A/B Hamming metrics and lower sustained
  frequency or throughput, the result supports the input-switching hypothesis.
- If PM logs do not include power, say so explicitly.
- Keep the conclusion as correlation, not proof of exact internal dynamic
  power.
