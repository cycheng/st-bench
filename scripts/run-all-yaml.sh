#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Run YAMLs from config + list files.

Usage:
  scripts/run-all-yaml.sh <config-file>

Config file format (key=value):
  build_dir=/path/to/build
  list_file=./test-lists/gfx1250.list   # repeatable, required
  container=my-dev-container
  workdir=/workspace/st-codegen-test
  output_root=./artifacts
  env=TARGET_ARCH=gfx1250               # repeatable
  env_file=./my-env.list                # repeatable
  no_start=true
  keep_container_out=false

List file format:
  - skip blank lines and # comments
  - each line can be: yaml path, directory, or glob
EOF
}

BUILD_DIR=""
LIST_FILES=()
CONTAINER_NAME=""
WORKDIR=""
OUTPUT_ROOT=""
EXTRA_ENVS=()
ENV_FILES=()
NO_START=0
KEEP_CONTAINER_OUT=0

parse_bool() {
  local raw="$1"
  local lower="${raw,,}"
  case "${lower}" in
    1|true|yes|on) echo 1 ;;
    0|false|no|off) echo 0 ;;
    *)
      echo "Invalid boolean value: ${raw}" >&2
      exit 1
      ;;
  esac
}

parse_config_file() {
  local cfg="$1"
  local line key value

  if [[ ! -f "${cfg}" ]]; then
    echo "Config file not found: ${cfg}" >&2
    exit 1
  fi

  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "${line}" || "${line}" == \#* ]] && continue

    if [[ "${line}" != *=* ]]; then
      echo "Invalid config line (expected key=value): ${line}" >&2
      exit 1
    fi

    key="${line%%=*}"
    value="${line#*=}"
    key="${key#"${key%%[![:space:]]*}"}"
    key="${key%"${key##*[![:space:]]}"}"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"

    case "${key}" in
      build_dir) BUILD_DIR="${value}" ;;
      list_file) LIST_FILES+=("${value}") ;;
      container) CONTAINER_NAME="${value}" ;;
      workdir) WORKDIR="${value}" ;;
      output_root) OUTPUT_ROOT="${value}" ;;
      env) EXTRA_ENVS+=("${value}") ;;
      env_file) ENV_FILES+=("${value}") ;;
      no_start) NO_START="$(parse_bool "${value}")" ;;
      keep_container_out) KEEP_CONTAINER_OUT="$(parse_bool "${value}")" ;;
      *)
        echo "Unknown config key: ${key}" >&2
        exit 1
        ;;
    esac
  done < "${cfg}"
}

if [[ $# -eq 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
  usage
  exit 0
fi
if [[ $# -ne 1 ]]; then
  usage
  exit 1
fi

CONFIG_FILE="$1"
parse_config_file "${CONFIG_FILE}"

if [[ -z "${BUILD_DIR}" ]]; then
  echo "build_dir is required in config." >&2
  exit 1
fi
if [[ ${#LIST_FILES[@]} -eq 0 ]]; then
  echo "At least one list_file is required in config." >&2
  exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUN_ONE_SCRIPT="${SCRIPT_DIR}/run-yaml.sh"

if [[ ! -x "${RUN_ONE_SCRIPT}" ]]; then
  echo "Cannot execute ${RUN_ONE_SCRIPT}" >&2
  exit 1
fi

expand_vars() {
  local raw="$1"
  eval "echo \"${raw}\""
}

run_yaml() {
  local yaml_file="$1"
  echo "=========================================="
  echo "YAML: ${yaml_file}"
  echo "=========================================="

  args=(--yaml "${yaml_file}" --build-dir "${BUILD_DIR}")
  [[ -n "${CONTAINER_NAME}" ]] && args+=(--container "${CONTAINER_NAME}")
  [[ -n "${WORKDIR}" ]] && args+=(--workdir "${WORKDIR}")
  [[ -n "${OUTPUT_ROOT}" ]] && args+=(--output-root "${OUTPUT_ROOT}")
  [[ ${NO_START} -eq 1 ]] && args+=(--no-start)
  [[ ${KEEP_CONTAINER_OUT} -eq 1 ]] && args+=(--keep-container-out)

  for kv in "${EXTRA_ENVS[@]}"; do
    args+=(--env "${kv}")
  done
  for ef in "${ENV_FILES[@]}"; do
    args+=(--env-file "${ef}")
  done

  "${RUN_ONE_SCRIPT}" "${args[@]}"
}

declare -A seen_yamls=()
total_runs=0

collect_and_run_from_target() {
  local list_file="$1"
  local raw_target="$2"
  local target
  target="$(expand_vars "${raw_target}")"

  if [[ -z "${target}" ]]; then
    return
  fi

  if [[ -d "${target}" ]]; then
    while IFS= read -r -d '' yaml_file; do
      [[ -n "${seen_yamls[${yaml_file}]:-}" ]] && continue
      seen_yamls["${yaml_file}"]=1
      total_runs=$((total_runs + 1))
      run_yaml "${yaml_file}"
    done < <(find "${target}" -type f -name "*.yaml" -print0 | sort -z)
    return
  fi

  if [[ -f "${target}" && "${target}" == *.yaml ]]; then
    if [[ -z "${seen_yamls[${target}]:-}" ]]; then
      seen_yamls["${target}"]=1
      total_runs=$((total_runs + 1))
      run_yaml "${target}"
    fi
    return
  fi

  mapfile -t glob_matches < <(compgen -G "${target}" || true)
  if [[ ${#glob_matches[@]} -eq 0 ]]; then
    echo "Warning: no matches for target in ${list_file}: ${raw_target}" >&2
    return
  fi

  for match in "${glob_matches[@]}"; do
    if [[ -d "${match}" ]]; then
      while IFS= read -r -d '' yaml_file; do
        [[ -n "${seen_yamls[${yaml_file}]:-}" ]] && continue
        seen_yamls["${yaml_file}"]=1
        total_runs=$((total_runs + 1))
        run_yaml "${yaml_file}"
      done < <(find "${match}" -type f -name "*.yaml" -print0 | sort -z)
    elif [[ -f "${match}" && "${match}" == *.yaml ]]; then
      [[ -n "${seen_yamls[${match}]:-}" ]] && continue
      seen_yamls["${match}"]=1
      total_runs=$((total_runs + 1))
      run_yaml "${match}"
    fi
  done
}

for list_file in "${LIST_FILES[@]}"; do
  if [[ ! -f "${list_file}" ]]; then
    echo "List file not found: ${list_file}" >&2
    exit 1
  fi

  echo "Using list file: ${list_file}"
  while IFS= read -r raw_line || [[ -n "${raw_line}" ]]; do
    line="${raw_line#"${raw_line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "${line}" || "${line}" == \#* ]] && continue
    collect_and_run_from_target "${list_file}" "${line}"
  done < "${list_file}"
done

if [[ ${total_runs} -eq 0 ]]; then
  echo "No YAML files were selected by list files." >&2
  exit 1
fi

echo "Batch run complete. Total YAML runs: ${total_runs}"
