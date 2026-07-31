# St-Codegen-Test

Portable helper scripts for running Tensile YAML workloads in Docker, collecting ASM artifacts, comparing generated assembly, and parsing StinkyTofu timing logs.

## Requirements

- Linux with `bash`, `python3`, `docker`
- A built Tensile tree with:
  - `<build-dir>/Tensile.sh`
  - `<build-dir>/tensilelite/client/tensilelite-client`
- Container has access to the same paths used in script arguments.

## Quick start

```bash
cd st-codegen-test
chmod +x scripts/*.sh

# Run a single YAML with config
scripts/run-single-yaml.sh examples/test.cfg examples/sample.yaml
```

Output artifacts are saved to `artifacts/<yaml-base>/` by default.

## Batch run

```bash
scripts/run-all-yaml.sh examples/test.cfg
```

This is the recommended flow: put all options in config, then run with one argument.

`run-all-yaml.sh` supports two task types via `task_type` in config:
- `yaml` (default): run YAMLs from `list_file`
- `hipblaslt_install`: run `hipblaslt/install.sh` and symlink generated `cmpasm`

List files support comments and one target per line:

```text
# can be a glob
${rocm_libraries_path}/projects/hipblaslt/tensilelite/Tensile/Tests/common/gemm/gfx12/*gfx1250.yaml

# or a directory (all *.yaml recursively)
${rocm_libraries_path}/projects/hipblaslt/tensilelite/Tensile/Tests/common/sparse/gfx1250
```

`env_file` format:
```text
# comments allowed
ROCM_PATH=/opt/rocm
TARGET_ARCH=gfx1250
ENABLE_DEBUG_STINKYTOFU_ASM=1
```

### Parallel YAML runs

`jobs=N` in config controls how many YAMLs run concurrently (default `16`). Set
`jobs=1` to run serially.

Tensile writes `cmpasm/` and `<yaml-base>.out` relative to its working
directory, so concurrent runs in a shared `workdir` would overwrite each
other's assembly. With `jobs>1` each run therefore gets a private directory
under `<workdir>/.runs/`, which is removed when the run finishes. Nothing else
changes: `Tensile.sh`, the YAML, and the client are all passed as absolute
paths, and artifacts still land in `<output_root>/<yaml-base>/`.

Notes:
- Each run's output is buffered and printed as one block in list order, so the
  batch log stays readable and reproducible regardless of finish order. The
  per-YAML `<output_root>/<yaml-base>/<yaml-base>.log` files are unaffected.
  `[start i/N]` markers go to stderr as jobs launch, for progress.
- Two YAMLs with the same basename write to the same `<output_root>` directory.
  That is a hard error when `jobs>1`; serially it only warns, as before.
- With `continue_on_failure=false` a failure stops new runs from launching,
  waits for in-flight ones, then exits with the failing run's exit code.
- Tensile already forks a worker pool per YAML, so useful concurrency is
  usually well below the core count.

## hipblaslt install task

Use this mode for tests that are not YAML-driven.

Example config:

```text
task_type=hipblaslt_install
rocm_libraries_path=/data0/cycheng2/rocm-libraries
container=cy_mi450
workdir=/data0/cycheng2/tickets/st-codegen-test
output_root=./asm

# shared runtime envs (same format as YAML mode)
env=ROCM_PATH=/opt/rocm
env=TARGET_ARCH=gfx1250
env=ENABLE_DEBUG_STINKYTOFU_ASM=1

hipblaslt_repo_path=${rocm_libraries_path}/projects/hipblaslt
hipblaslt_install_flags=-idc -a gfx1250 --logic-yaml-filter gfx1250/GridBased/* --skip_rocroller
hipblaslt_build_type=debug
hipblaslt_symlink_name=hipblaslt-test-asm
```

Run:

```bash
scripts/run-all-yaml.sh examples/test.cfg
```

This runs:
- `docker exec ... ./install.sh <hipblaslt_install_flags>`
- creates symlink:
  - `${output_root}/hipblaslt-test-asm` (or custom `hipblaslt_symlink_name`)
- points to:
  - debug: `${hipblaslt_repo_path}/build/debug/library/src/amd_detail/rocblaslt/src/cmpasm`
  - release: `${hipblaslt_repo_path}/build/release/library/src/amd_detail/rocblaslt/src/cmpasm`

## ASM diff

If you have case folders under `asm/` such as:

```text
asm/
  case-a/
    orig/
    st/
  case-b/
    orig/
    st/
```

run:

```bash
# default use ./asm folder
scripts/diff-asm.sh
```

```bash
scripts/diff-asm.sh --asm-root ./myfolder
```

For side-by-side output:

```bash
scripts/diff-asm.sh --asm-root ./asm --side-by-side
```

## Timing parse

```bash
python3 scripts/parse_timing.py artifacts/sample/sample.log --top 20
```

This prints:
- top kernels by `(1a)+(1b)+(2)`
- top kernels by `(A)/Rocisa::str(moduleKernelBody)`
- distribution summaries and histograms

## Notes

- `run-single-yaml.sh` can auto-start the container. Use `--no-start` if container lifecycle is managed elsewhere.
- By default, container `<yaml-base>.out` is deleted after run. Use `--keep-container-out` to preserve it.
- `run-all-yaml.sh` expands variables in list entries (for example `${rocm_libraries_path}`).
- In config files, use `docker_auto_start=true|false` to control automatic `docker start`.
