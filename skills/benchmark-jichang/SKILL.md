---
name: benchmark-jichang
description: >-
  Sets up and runs Jichang silicon benchmarks with
  scripts/benchmark-jichang-commits.sh. Use when a developer asks to benchmark
  stinkytofu or hipblaslt commits, create or fill test-silicon-rel.cfg, clone
  rocm-libraries, report whether st-codegen-test and rocm-libraries are
  behind origin, build the tensilelite gfx1250 release, rebuild it in a clean
  venv when the system rocisa hook blocks imports, install python3-joblib and
  python3-msgpack, choose a GPU, run MAF, MAB, or medium YAMLs, enable PM
  logging, or report the benchmark summary.
---

# Benchmark Jichang commits

Drive this as an interactive setup, then run
`scripts/benchmark-jichang-commits.sh` from the `st-codegen-test` checkout.
Do not clone, build, or start a benchmark until the user confirms that step.

## Progress

Copy and update this checklist:

```
- [ ] 1. Locate st-codegen-test; ask before fetch, then ask before update
- [ ] 2. Write test-silicon-rel.cfg
- [ ] 3. rocm-libraries present; ask before fetch, then ask before update (clone only if the user says yes)
- [ ] 4. Release build present (build only if the user says yes); venv rebuild if the system rocisa hook is active; libomp.so loads
- [ ] 5. joblib and msgpack import on the Python that Tensile.sh runs
- [ ] 6. Smoke-test examples/1024vgpr.yaml and tell the user it succeeded
- [ ] 7. Collect benchmark options and run
- [ ] 8. Dump summary.txt
```

## 1. Locate st-codegen-test

Find the directory that contains `scripts/benchmark-jichang-commits.sh`.
Run the benchmark from that directory. `workdir` in the config is this same checkout.

If that checkout is a git repo, ask before fetching. Stop until the user says yes. Do not fetch, pull, merge, or reset on your own.

After the user says yes, run this inside the checkout:

```
git fetch origin
git status -sb
git rev-list --left-right --count HEAD...@{u}
```

The left count is commits the local branch has that upstream does not. The right count is commits upstream has that the local branch does not. Tell the user the branch name and one of these:

- up to date: both counts are 0
- behind: the right count is greater than 0 and the left count is 0
- ahead: the left count is greater than 0 and the right count is 0
- diverged: both counts are greater than 0

Include the counts. If `HEAD...@{u}` fails because the branch has no upstream, say that and do not guess. A detached HEAD has no upstream; say it is detached and give the commit.

If the branch is behind and `git status -sb` shows no local changes, ask whether to update it. Stop until the user says yes. The update is `git pull --ff-only` on that branch. Afterwards, give the new HEAD. Do not merge, rebase, or reset. If the branch is ahead, diverged, detached, or has local changes, say so and do not update it.

If the user says no to the fetch, do not fetch. Say that freshness is unknown. If fetch fails, show the error and stop. Do not claim the checkout is up to date.

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

Ask which physical GPU to use before writing this file. `<gpu>` is that index (`1` means `env=HIP_VISIBLE_DEVICES=1`). If an `env=HIP_VISIBLE_DEVICES=` line is already present, replace it instead of adding a second one. The same index is passed as `--gpu` in step 7.

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

When the tree already exists, ask before fetching. Stop until the user says yes. Do not fetch, pull, merge, or reset on your own.

After the user says yes, run this inside `rocm_libraries_path`:

```
git fetch origin
git status -sb
git rev-list --left-right --count HEAD...@{u}
```

Use the same behind, ahead, diverged, and up-to-date counts as in step 1. Tell the user the branch name. A detached HEAD has no upstream; say it is detached and give the commit.

If the branch is behind and the only extra content is the untracked build directory, ask whether to update it. Stop until the user says yes. The update is `git pull --ff-only` on that branch. Afterwards, give the new HEAD. Do not merge, rebase, or reset. If the branch is ahead, diverged, detached, or has other local changes, say so and do not update it.

If the user named commits, check each one after the fetch with `git cat-file -e <sha>^{commit}`. If a commit is missing, say which one and stop before the benchmark. If the user said no to the fetch, skip that check and say the commits were not verified.

SSH access to `git@github.com:ROCm/rocm-libraries.git` is required. If clone or fetch fails, show the error and stop. Do not claim either repo is up to date.

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

After `Tensile.sh` exists, read which Python it runs. A system interpreter is a problem when that interpreter has an editable `rocisa` hook, usually `/usr/local/lib/python3.*/dist-packages/_editable_skbc_rocisa.pth`, whose finder points at a root-owned tree such as `/opt/amd-apps/rocm-libraries_tensilelite_v3`. `run-single-yaml.sh` and the benchmark script then fail during `from rocisa import rocIsa` with:

```
PermissionError: [Errno 13] Permission denied: '.../editable_rebuild.lock'
```

Activating a venv does not fix a `Tensile.sh` that already calls `/usr/bin/python3` by absolute path. Ask before rebuilding. Stop until the user says yes. Then create a venv without system site packages and rebuild the same `build_dir` with that interpreter. Default venv path is `$HOME/venv-tensile`.

```
python3 -m venv "$HOME/venv-tensile"
"$HOME/venv-tensile/bin/python" -m pip install -r <rocm_libraries_path>/projects/hipblaslt/tensilelite/requirements.txt
rm -rf <build_dir>
cmake --preset tensilelite -S . -B <build_dir> -DCMAKE_BUILD_TYPE=Release -DSTINKYTOFU_BUILD_TESTS=ON -DGPU_TARGETS=gfx1250 -DPython3_EXECUTABLE="$HOME/venv-tensile/bin/python"
cmake --build <build_dir> --parallel
```

Run cmake from `<rocm_libraries_path>/projects/hipblaslt`. Do not pass `--system-site-packages`. `requirements.txt` includes `joblib`, `msgpack`, and `pyyaml`; apt packages on the system interpreter are not visible inside this venv.

Wait until the build exits. `Tensile.sh` must invoke `$HOME/venv-tensile/bin/python`. With that interpreter and the `PYTHONPATH` from `Tensile.sh`, `from rocisa import rocIsa` and `from Tensile import Tensile` must succeed, and `sys.meta_path` must not contain `ScikitBuildRedirectingFinder`. `rocisa.__file__` must be under `build_dir`.

Do not tell the user to `source` the venv before `run-single-yaml.sh` or `benchmark-jichang-commits.sh`. Those scripts call `Tensile.sh`, which uses the venv interpreter by absolute path.

After the client exists, check that it can load `libomp.so`:

```
ldd <build_dir>/tensilelite/client/tensilelite-client | grep libomp.so
```

`run-single-yaml.sh` and the benchmark script both fail with this when it is missing:

```
tensilelite-client: error while loading shared libraries: libomp.so: cannot open shared object file: No such file or directory
```

If `ldd` reports `libomp.so => not found`, or a run already failed with that message, confirm this file exists:

```
/opt/rocm/lib/llvm/lib/x86_64-unknown-linux-gnu/libomp.so
```

Then add this line to the config, with the other `env=` lines, unless an `env=LD_LIBRARY_PATH=` line is already present:

```
env=LD_LIBRARY_PATH=/opt/rocm/lib/llvm/lib/x86_64-unknown-linux-gnu:$LD_LIBRARY_PATH
```

That is the config form of `export LD_LIBRARY_PATH=/opt/rocm/lib/llvm/lib/x86_64-unknown-linux-gnu:$LD_LIBRARY_PATH`. Do not add a second `env=LD_LIBRARY_PATH=` line. If one is already present and does not include that directory, say so and wait. If `libomp.so` is not at that path, show the error and stop. Do not start the benchmark while `ldd` still reports `libomp.so => not found`.

## 5. Install joblib and msgpack for the Python Tensile.sh runs

The benchmark imports `joblib` and `msgpack`. Check with the interpreter named in `Tensile.sh`, not whichever `python3` is first on `PATH`.

If `Tensile.sh` runs `$HOME/venv-tensile/bin/python`, those imports come from the venv `requirements.txt` install in step 4. Do not use apt for that interpreter.

If `Tensile.sh` runs the system interpreter, check:

```
python3 -c "import joblib, msgpack"
```

If that fails, install the distro packages and check again:

```
sudo apt-get install -y python3-joblib python3-msgpack
python3 -c "import joblib, msgpack"
```

Do not start the benchmark until the import succeeds on the interpreter `Tensile.sh` runs. If install fails, show the error and stop.

## 6. Smoke-test examples/1024vgpr.yaml

After the build, `libomp.so`, and Python imports are ready, run this from the st-codegen-test root. Use the config written in step 2. Do not `source` the venv.

```
./scripts/run-single-yaml.sh ./examples/test-silicon-rel.cfg ./examples/1024vgpr.yaml
```

`HIP_VISIBLE_DEVICES` in that config selects the GPU. Wait until the process exits. The initial test succeeded when the output contains `clientExit=0 (PASS)`. Tell the user that, and quote that line.

If it fails with `libomp.so: cannot open shared object file` or `editable_rebuild.lock` / `PermissionError`, apply the matching fix from step 4 and run this smoke test again. For any other failure, show the error and stop. Do not start the commit benchmark, and do not say the initial test succeeded.

## 7. Ask what to benchmark

Ask in one turn. Use these defaults when the user does not care:

| Option | Default | Flag |
| --- | --- | --- |
| GPU index | ask; do not assume | `--gpu <n>`. Required. |
| commits | current checkout; do not change it | repeat `--commit <sha>`, or `--start` with `--end`. Never mix `--commit` with `--start`/`--end`. |
| repeat | 1 | `--repeat <n>` |
| category | all of mab, maf, and medium | `--category mab`, `--category maf`, or `--category medium`. Omit the flag for all. |
| yaml | all catalog YAMLs | `--yaml <path>` under `examples/jichang`. A file that is not in the mab/maf/medium catalog is accepted. |
| pm-log-maf | no | `--pm-log-maf`. Logs only `examples/jichang/maf/*` and rewrites those warmup counts. |
| force-pm-log | no | `--force-pm-log`. Logs every selected YAML and leaves warmup counts unchanged. |
| keep raw PM CSV | no | `--keep-pm-log`. Requires `--pm-log-maf` or `--force-pm-log`. |
| validation | validate every run | `--validate-first-only` is the usual choice when repeat is greater than 1. `--no-validate` disables validation. |
| output-dir | `benchmark-results/<YYYYMMDD-HHMMSS>` | `--output-dir <dir>` |

`--pm-log-maf`, `--force-pm-log`, `--keep-pm-log`, `--yaml`, and `--category` are optional. `--gpu` is not. `--force-pm-log` is the flag for a YAML outside `examples/jichang/maf/`.

Ask which physical GPU to use, for example `0` or `1`. Before running:

- Set or replace `env=HIP_VISIBLE_DEVICES=<n>` in the config. GPU `1` is `env=HIP_VISIBLE_DEVICES=1`.
- Pass `--gpu <n>`.

`--gpu <n>` runs the workload on that GPU and, with `--pm-log-maf`, monitors it. `agt_internal -i=0` is GPU 0. For GPU n the script passes `-i=5n` (`-i=5` for GPU 1, `-i=10` for GPU 2). Do not pass `-i` yourself.

`--pm-log-maf` and `--force-pm-log` need `/opt/amd-apps/agt_internal/agt_internal` and passwordless `sudo`. Check both before adding either flag. If either is missing, say so and run without PM logging unless the user fixes it. `--gpu` is still required.

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

## 8. Dump the summary

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

If the process fails before writing a summary, show the error and the log path under `<output-dir>/logs/`. Do not invent scores. If the error is `libomp.so: cannot open shared object file`, add the `env=LD_LIBRARY_PATH=` line from step 4 and stop. If the error is `editable_rebuild.lock` with `PermissionError`, rebuild with the venv from step 4 and stop. Do not report scores from that run.
