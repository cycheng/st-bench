# St-Codegen-Test

Portable helper scripts for running Tensile YAML workloads in Docker, collecting ASM artifacts, comparing generated assembly, and parsing StinkyTofu timing logs.

This project is extracted from an internal ticket workflow and cleaned up for reuse:
- no MI450-specific script names
- no hardcoded user paths
- no fixed container/build directory names

## Project layout

- `scripts/run-single-yaml.sh`: run one YAML inside a docker container.
- `scripts/run-all-yaml.sh`: batch-run YAML files from one config file.
- `scripts/diff-asm.sh`: compare `orig` vs `st` ASM folders.
- `scripts/parse_timing.py`: parse compile timing log and print top-k + distributions.
- `examples/sample.yaml`: sample input YAML.
- `test-lists/`: test target list files (`*.list`).
- `examples/test.cfg`: example config.

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

# Run a single YAML
scripts/run-single-yaml.sh \
  --yaml examples/sample.yaml \
  --build-dir /path/to/tensile/build \
  --container my-dev-container \
  --workdir /workspace/st-codegen-test
```

Output artifacts are saved to `artifacts/<yaml-base>/` by default.

## Batch run

```bash
scripts/run-all-yaml.sh examples/test.cfg
```

This is the recommended flow: put all options in config, then run with one argument.

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
scripts/diff-asm.sh --asm-root ./asm
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
