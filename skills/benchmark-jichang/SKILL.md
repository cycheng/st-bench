---
name: benchmark-jichang
description: >-
  Sets up and runs Jichang silicon benchmarks with
  scripts/benchmark-jichang-commits.sh. Use when a developer asks to benchmark
  stinkytofu or hipblaslt commits, create or fill test-silicon-rel.cfg, clone
  rocm-libraries, build the tensilelite gfx1250 release, install python3-joblib
  and python3-msgpack, choose a GPU, run MAF, MAB, or medium YAMLs, enable PM
  logging, or report the benchmark summary.
---

# Benchmark Jichang commits

Drive this as an interactive setup, then run
`scripts/benchmark-jichang-commits.sh` from the `st-codegen-test` checkout.
Do not clone, build, or start a benchmark until the user confirms that step.

## Progress

Copy and update this checklist:

```
- [ ] 1. Locate st-codegen-test
- [ ] 2. Write test-silicon-rel.cfg
- [ ] 3. rocm-libraries present (clone only if the user says yes)
- [ ] 4. Release build present (build only if the user says yes)
- [ ] 5. python3-joblib and python3-msgpack import
- [ ] 6. Collect benchmark options and run
- [ ] 7. Dump summary.txt
```

## 1. Locate st-codegen-test

Find the directory that contains `scripts/benchmark-jichang-commits.sh`.
Run the benchmark from that directory. `workdir` in the config is this same checkout.

## 2. Write examples/test-silicon-rel.cfg

These three paths have to be right:

| Key | Meaning |
| --- | --- |
| `rocm_libraries_path` | rocm-libraries checkout the benchmark checks commits out in |
| `build_dir` | Release tensilelite build. Default: `<rocm_libraries_path>/projects/hipblaslt/tensilelite/new_rel_build_mi450` |
| `workdir` | st-codegen-test checkout used as the benchmark working directory |

Ask for any path you cannot infer. Use absolute paths.

If `examples/test-silicon-rel.cfg` already exists, read it and confirm the three paths before rewriting. Do not replace another machine's paths without a yes.

Write this file. Set `list_file` to `<workdir>/test-lists/gfx1250.list`:

```
task_type=yaml

build_dir=<build_dir>
list_file=<workdir>/test-lists/gfx1250.list
rocm_libraries_path=<rocm_libraries_path>
workdir=<workdir>
output_root=./asm

env=ENABLE_DEBUG_STINKYTOFU_ASM=1
env=HIP_VISIBLE_DEVICES=<gpu>

docker_auto_start=false
keep_container_out=false
execution_mode=host
build_only=false
live_output=true
```

Ask which physical GPU to use before writing this file. `<gpu>` is that index (`1` means `env=HIP_VISIBLE_DEVICES=1`). If an `env=HIP_VISIBLE_DEVICES=` line is already present, replace it instead of adding a second one. The same index is passed as `--gpu` in step 6.

This file holds machine-local paths. Do not commit it unless the user asks.

Pass the same `rocm_libraries_path` as `--repo`. The script default is `~/rocm-libraries`, which is often a different tree.

## 3. Clone rocm-libraries if it is missing

The tree is ready when all of these exist:

- `<rocm_libraries_path>/.git`
- `<rocm_libraries_path>/projects/hipblaslt`
- `<rocm_libraries_path>/shared/stinkytofu`
- `<rocm_libraries_path>/shared/origami`
- `<rocm_libraries_path>/shared/mxdatagenerator`

If any are missing, ask whether to clone or sparse-checkout. Stop until the user says yes.

If the directory does not exist, clone into its parent so the resulting folder is `rocm_libraries_path`. When that folder is named `rocm-libraries`, use these commands exactly:

```
git clone --filter=blob:none --sparse git@github.com:ROCm/rocm-libraries.git

cd rocm-libraries
git sparse-checkout set projects/hipblaslt
git sparse-checkout add shared/stinkytofu
git sparse-checkout add shared/origami
git sparse-checkout add shared/mxdatagenerator
curl -o .clang-format https://raw.githubusercontent.com/ROCm/rocm-libraries/develop/.clang-format
```

Run the clone from the parent of `rocm_libraries_path`. If the target directory name is not `rocm-libraries`, pass that path as the clone destination and run the sparse-checkout and curl commands inside it. Keep the same flags and the same sparse paths.

If the repo already exists but a sparse path is missing, run only the matching `git sparse-checkout add` lines inside it. Do not clone again.

SSH access to `git@github.com:ROCm/rocm-libraries.git` is required. If clone fails, show the error and stop.

## 4. Build the release if it is missing

A build is present when both files exist:

- `<build_dir>/Tensile.sh`
- `<build_dir>/tensilelite/client/tensilelite-client`

If either is missing, ask whether to build. Stop until the user says yes.

For the default `tensilelite/new_rel_build_mi450` build, run this from `<rocm_libraries_path>/projects/hipblaslt`:

```
cmake --preset tensilelite -S . -B tensilelite/new_rel_build_mi450  -DCMAKE_BUILD_TYPE=Release -DSTINKYTOFU_BUILD_TESTS=ON -DGPU_TARGETS=gfx1250
cmake --build tensilelite/new_rel_build_mi450 --parallel
```

If the user chose a different `build_dir`, use that path as `-B` instead of `tensilelite/new_rel_build_mi450`. Keep the other flags.

This compile is long. Wait until it exits, then check that both files above exist. Do not start the benchmark until they do. If cmake fails, show the error and stop.

## 5. Install python3-joblib and python3-msgpack

The benchmark imports `joblib` and `msgpack`. Before running, check:

```
python3 -c "import joblib, msgpack"
```

If that fails, install the distro packages and check again:

```
sudo apt-get install -y python3-joblib python3-msgpack
python3 -c "import joblib, msgpack"
```

Do not start the benchmark until the import succeeds. If install fails, show the error and stop.

## 6. Ask what to benchmark

Ask in one turn. Use these defaults when the user does not care:

| Option | Default | Flag |
| --- | --- | --- |
| GPU index | ask; do not assume | `--gpu <n>`. Required. |
| commits | current checkout; do not change it | repeat `--commit <sha>`, or `--start` with `--end`. Never mix `--commit` with `--start`/`--end`. |
| repeat | 1 | `--repeat <n>` |
| category | all of mab, maf, and medium | `--category mab`, `--category maf`, or `--category medium`. Omit the flag for all. |
| pm-log-maf | no | `--pm-log-maf` |
| keep raw PM CSV | no | `--keep-pm-log`. Only valid together with `--pm-log-maf`. |
| validation | validate every run | `--validate-first-only` is the usual choice when repeat is greater than 1. `--no-validate` disables validation. |
| output-dir | `benchmark-results/<YYYYMMDD-HHMMSS>` | `--output-dir <dir>` |

`--pm-log-maf`, `--keep-pm-log`, and `--category` are optional. `--gpu` is not.

Ask which physical GPU to use, for example `0` or `1`. Before running:

- Set or replace `env=HIP_VISIBLE_DEVICES=<n>` in the config. GPU `1` is `env=HIP_VISIBLE_DEVICES=1`.
- Pass `--gpu <n>`.

`--gpu <n>` runs the workload on that GPU and, with `--pm-log-maf`, monitors it. `agt_internal -i=0` is GPU 0. For GPU n the script passes `-i=5n` (`-i=5` for GPU 1, `-i=10` for GPU 2). Do not pass `-i` yourself.

`--pm-log-maf` needs `/opt/amd-apps/agt_internal/agt_internal` and passwordless `sudo`. Check both before adding the flag. If either is missing, say so and run without PM logging unless the user fixes it. `--gpu` is still required.

Show the full command, then run it from the st-codegen-test root. Always pass `--config` and `--repo`.

```
./scripts/benchmark-jichang-commits.sh --repeat 3 \
  --config ./examples/test-silicon-rel.cfg \
  --repo <rocm_libraries_path> \
  --output-dir ./benchmark-results/20261001-maf \
  --commit 75f256bfc \
  --commit 7fac33c60 \
  --commit 80414d879 \
  --commit 8ef6640ab \
  --gpu 1 \
  --pm-log-maf --validate-first-only --keep-pm-log --category maf
```

Before starting, tell the user that the script stashes tracked local changes in `rocm_libraries_path` and checks out each commit there. Do not start if that checkout has unrelated work the user did not agree to stash.

The run can take a long time. Wait until the process exits. Reusing the same `--output-dir` resumes; completed YAMLs are skipped. After an unexpected interruption, restore the rocm-libraries worktree manually before resuming.

## 7. Dump the summary

When the process exits, print the full contents of `<output-dir>/summary.txt` in the reply. The script writes `summary.txt`, not `summary.log`.

Also give the absolute paths of:

- `summary.txt`
- `time-summary.txt`
- `results.csv`
- `failures.csv`, when it has any failure rows

How to read the table:

- MAB scores are max GB/s. MAF and medium scores are PFLOPS (max GFLOPS / 1000). Higher is better.
- A trailing `*` means that sample failed validation.
- A trailing `=` means the generated ASM matches the previous chronological commit.
- `0.00` means that YAML produced no finite score.

If the process fails before writing a summary, show the error and the log path under `<output-dir>/logs/`. Do not invent scores.
