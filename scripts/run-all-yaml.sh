#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Run tasks from config.

Usage:
  scripts/run-all-yaml.sh <config-file>
  scripts/run-all-yaml.sh <config-file> <list-file>

Config file format (key=value):
  task_type=yaml|hipblaslt_install     # optional, default: yaml
  execution_mode=docker|host           # optional, default: docker
  build_dir=/path/to/build
  list_file=./test-lists/gfx1250.list   # repeatable, required for task_type=yaml
  rocm_libraries_path=/data0/cycheng2/rocm-libraries
  container=my-dev-container
  workdir=/workspace/st-codegen-test
  output_root=./artifacts
  env=TARGET_ARCH=gfx1250               # repeatable
  env_file=./my-env.list                # repeatable
  build_only=true                       # default true; set false to skip --build-only
  continue_on_failure=false             # keep running remaining YAMLs after a failure
  jobs=16                               # concurrent YAML runs; 1 runs serially
  docker_auto_start=true
  keep_container_out=false
  hipblaslt_repo_path=${rocm_libraries_path}/projects/hipblaslt
  hipblaslt_install_flags=-idc -a gfx1250 --logic-yaml-filter gfx1250/GridBased/* --skip_rocroller
  hipblaslt_build_type=debug|release    # for task_type=hipblaslt_install
  hipblaslt_symlink_name=hipblaslt-test-asm

List file format:
  - skip blank lines and # comments
  - each line can be: yaml path, directory, or glob
EOF
}

BUILD_DIR=""
LIST_FILES=()
ROCM_LIBRARIES_PATH="${rocm_libraries_path:-}"
CONTAINER_NAME=""
WORKDIR=""
OUTPUT_ROOT=""
EXTRA_ENVS=()
ENV_FILES=()
DOCKER_AUTO_START=1
BUILD_ONLY=1
CONTINUE_ON_FAILURE=0
KEEP_CONTAINER_OUT=0
JOBS=16
PARALLEL=0
TASK_TYPE="yaml"
EXECUTION_MODE="docker"
HIPBLASLT_REPO_PATH=""
HIPBLASLT_INSTALL_FLAGS=""
HIPBLASLT_BUILD_TYPE="debug"
HIPBLASLT_SYMLINK_NAME="hipblaslt-test-asm"

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

parse_jobs() {
  local raw="$1"
  if [[ ! "${raw}" =~ ^[0-9]+$ || "${raw}" -lt 1 ]]; then
    echo "Invalid jobs value: ${raw}. Use a positive integer." >&2
    exit 1
  fi
  echo "${raw}"
}

normalize_execution_mode() {
  local raw="$1"
  local lower="${raw,,}"
  case "${lower}" in
    docker|host) echo "${lower}" ;;
    *)
      echo "Invalid execution mode: ${raw}. Use docker or host." >&2
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
      task_type) TASK_TYPE="${value}" ;;
      execution_mode) EXECUTION_MODE="$(normalize_execution_mode "${value}")" ;;
      build_dir) BUILD_DIR="${value}" ;;
      list_file) LIST_FILES+=("${value}") ;;
      rocm_libraries_path) ROCM_LIBRARIES_PATH="${value}" ;;
      container) CONTAINER_NAME="${value}" ;;
      workdir) WORKDIR="${value}" ;;
      output_root) OUTPUT_ROOT="${value}" ;;
      env) EXTRA_ENVS+=("${value}") ;;
      env_file) ENV_FILES+=("${value}") ;;
      docker_auto_start) DOCKER_AUTO_START="$(parse_bool "${value}")" ;;
      no_start) DOCKER_AUTO_START="$((1 - $(parse_bool "${value}")))" ;;
      build_only) BUILD_ONLY="$(parse_bool "${value}")" ;;
      continue_on_failure) CONTINUE_ON_FAILURE="$(parse_bool "${value}")" ;;
      keep_container_out) KEEP_CONTAINER_OUT="$(parse_bool "${value}")" ;;
      jobs) JOBS="$(parse_jobs "${value}")" ;;
      hipblaslt_repo_path) HIPBLASLT_REPO_PATH="${value}" ;;
      hipblaslt_install_flags) HIPBLASLT_INSTALL_FLAGS="${value}" ;;
      hipblaslt_build_type) HIPBLASLT_BUILD_TYPE="${value}" ;;
      hipblaslt_symlink_name) HIPBLASLT_SYMLINK_NAME="${value}" ;;
      *)
        echo "Unknown config key: ${key}" >&2
        exit 1
        ;;
    esac
  done < "${cfg}"
}

if [[ $# -ge 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
  usage
  exit 0
fi
if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

CONFIG_FILE="$1"
parse_config_file "${CONFIG_FILE}"

if [[ $# -eq 2 ]]; then
  if [[ "${TASK_TYPE}" != "yaml" ]]; then
    echo "The <list-file> override argument is only supported for task_type=yaml." >&2
    exit 1
  fi
  override_list_file="$2"
  config_dir="$(cd -- "$(dirname -- "${CONFIG_FILE}")" && pwd)"
  if [[ "${override_list_file}" = /* ]]; then
    LIST_FILES=("${override_list_file}")
  elif [[ -f "${override_list_file}" ]]; then
    LIST_FILES=("${override_list_file}")
  else
    LIST_FILES=("${config_dir}/${override_list_file}")
  fi
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
RUN_ONE_SCRIPT="${SCRIPT_DIR}/run-single-yaml.sh"

expand_vars() {
  local raw="$1"
  local expanded
  if [[ -n "${ROCM_LIBRARIES_PATH}" ]]; then
    export rocm_libraries_path="${ROCM_LIBRARIES_PATH}"
  fi
  set +u
  expanded="$(eval "echo \"${raw}\"")"
  set -u
  echo "${expanded}"
}

build_docker_env_args() {
  RUNTIME_ENV_VARS=()
  DOCKER_ENV_ARGS=()
  local env_file line
  for kv in "${EXTRA_ENVS[@]}"; do
    RUNTIME_ENV_VARS+=("${kv}")
  done
  for env_file in "${ENV_FILES[@]}"; do
    if [[ ! -f "${env_file}" ]]; then
      echo "Env file not found: ${env_file}" >&2
      exit 1
    fi
    while IFS= read -r line || [[ -n "${line}" ]]; do
      line="${line#"${line%%[![:space:]]*}"}"
      line="${line%"${line##*[![:space:]]}"}"
      [[ -z "${line}" || "${line}" == \#* ]] && continue
      RUNTIME_ENV_VARS+=("${line}")
    done < "${env_file}"
  done
  for kv in "${RUNTIME_ENV_VARS[@]}"; do
    DOCKER_ENV_ARGS+=("-e" "${kv}")
  done
}

run_yaml() {
  local yaml_file="$1"
  echo "=========================================="
  echo "YAML: ${yaml_file}"
  echo "=========================================="

  local args=()
  args=(--yaml "${yaml_file}" --build-dir "${BUILD_DIR}")
  args+=(--execution-mode "${EXECUTION_MODE}")
  [[ -n "${CONTAINER_NAME}" ]] && args+=(--container "${CONTAINER_NAME}")
  [[ -n "${WORKDIR}" ]] && args+=(--workdir "${WORKDIR}")
  [[ -n "${OUTPUT_ROOT}" ]] && args+=(--output-root "${OUTPUT_ROOT}")
  [[ ${BUILD_ONLY} -eq 0 ]] && args+=(--no-build-only)
  [[ ${KEEP_CONTAINER_OUT} -eq 1 ]] && args+=(--keep-container-out)
  # Concurrent runs would otherwise share cmpasm/ and <base>.out in workdir.
  [[ ${PARALLEL} -eq 1 ]] && args+=(--isolate-run-dir)
  # In parallel mode the container is started once up front instead.
  [[ ${DOCKER_AUTO_START} -eq 0 || ${PARALLEL} -eq 1 ]] && args+=(--no-start)

  for kv in "${EXTRA_ENVS[@]}"; do
    args+=(--env "${kv}")
  done
  for ef in "${ENV_FILES[@]}"; do
    args+=(--env-file "${ef}")
  done

  "${RUN_ONE_SCRIPT}" "${args[@]}"
}

normalize_build_type() {
  local lower="${1,,}"
  case "${lower}" in
    debug|dbg) echo "debug" ;;
    release|rel) echo "release" ;;
    *)
      echo "Invalid hipblaslt_build_type: ${1}. Use debug or release." >&2
      exit 1
      ;;
  esac
}

run_hipblaslt_install() {
  local repo_path install_flags build_type cmpasm_path
  local output_root symlink_name symlink_path cmd

  if [[ -z "${HIPBLASLT_REPO_PATH}" ]]; then
    echo "hipblaslt_repo_path is required for task_type=hipblaslt_install." >&2
    exit 1
  fi

  repo_path="$(expand_vars "${HIPBLASLT_REPO_PATH}")"
  install_flags="$(expand_vars "${HIPBLASLT_INSTALL_FLAGS}")"
  build_type="$(normalize_build_type "${HIPBLASLT_BUILD_TYPE}")"
  cmpasm_path="${repo_path}/build/${build_type}/device-library/cmpasm"
  output_root="${OUTPUT_ROOT:-./artifacts}"
  symlink_name="${HIPBLASLT_SYMLINK_NAME:-hipblaslt-test-asm}"
  symlink_path="${output_root%/}/${symlink_name}"

  build_docker_env_args

  if [[ "${EXECUTION_MODE}" == "docker" ]]; then
    if [[ -z "${CONTAINER_NAME}" ]]; then
      echo "container is required for task_type=hipblaslt_install in docker mode." >&2
      exit 1
    fi
    if [[ -z "${WORKDIR}" ]]; then
      echo "workdir is required for task_type=hipblaslt_install in docker mode." >&2
      exit 1
    fi
    if [[ ${DOCKER_AUTO_START} -eq 1 ]]; then
      docker start "${CONTAINER_NAME}" >/dev/null
    fi
  fi

  printf -v cmd "cd %q && ./install.sh %s" "${repo_path}" "${install_flags}"

  echo "=========================================="
  echo "Task: hipblaslt_install"
  echo "Execution mode: ${EXECUTION_MODE}"
  if [[ "${EXECUTION_MODE}" == "docker" ]]; then
    echo "Container: ${CONTAINER_NAME}"
  fi
  echo "Repo: ${repo_path}"
  echo "Install flags: ${install_flags}"
  echo "=========================================="
  if [[ "${EXECUTION_MODE}" == "docker" ]]; then
    docker exec -w "${WORKDIR}" "${DOCKER_ENV_ARGS[@]}" "${CONTAINER_NAME}" bash -lc "${cmd}"
  else
    env "${RUNTIME_ENV_VARS[@]}" /bin/bash -lc "${cmd}"
  fi

  mkdir -p "${output_root}"
  ln -sfn "${cmpasm_path}" "${symlink_path}"
  echo "cmpasm symlink: ${symlink_path} -> ${cmpasm_path}"
}

declare -A seen_yamls=()
declare -A seen_basenames=()
selected_yamls=()
total_runs=0
passed_runs=0
failed_runs=0
summary_yamls=()
summary_statuses=()
summary_exit_codes=()
HARD_FAILURE_EXIT=""

print_yaml_summary() {
  local i yaml status exit_code
  local ran=$((passed_runs + failed_runs))

  echo "=========================================="
  echo "YAML run summary"
  echo "=========================================="
  for i in "${!summary_yamls[@]}"; do
    yaml="${summary_yamls[${i}]}"
    status="${summary_statuses[${i}]}"
    exit_code="${summary_exit_codes[${i}]}"
    if [[ "${status}" == "PASS" ]]; then
      printf '[PASS] %s\n' "${yaml}"
    else
      printf '[FAIL exit=%s] %s\n' "${exit_code}" "${yaml}"
    fi
  done
  echo "Total YAML runs: ${ran}, passed: ${passed_runs}, failed: ${failed_runs}"
  if (( ran < total_runs )); then
    echo "Skipped after failure: $((total_runs - ran)) of ${total_runs} selected YAMLs"
  fi
}

record_result() {
  local yaml_file="$1"
  local exit_code="$2"

  summary_yamls+=("${yaml_file}")
  summary_exit_codes+=("${exit_code}")
  if [[ "${exit_code}" -eq 0 ]]; then
    passed_runs=$((passed_runs + 1))
    summary_statuses+=("PASS")
  else
    failed_runs=$((failed_runs + 1))
    summary_statuses+=("FAIL")
  fi
}

# Returns non-zero when the caller should stop starting new YAMLs.
handle_failure() {
  local yaml_file="$1"
  local exit_code="$2"

  if [[ ${CONTINUE_ON_FAILURE} -eq 1 ]]; then
    echo "YAML failed with exit code ${exit_code}; continuing because continue_on_failure=true: ${yaml_file}" >&2
    return 0
  fi

  HARD_FAILURE_EXIT="${exit_code}"
  return 1
}

select_yaml() {
  local yaml_file="$1"
  local base

  [[ -n "${seen_yamls[${yaml_file}]:-}" ]] && return 0
  seen_yamls["${yaml_file}"]=1

  # Artifacts land in <output_root>/<basename>, so two YAMLs sharing a basename
  # overwrite each other serially and race outright in parallel.
  base="$(basename "${yaml_file}" .yaml)"
  if [[ -n "${seen_basenames[${base}]:-}" ]]; then
    if [[ ${JOBS} -gt 1 ]]; then
      echo "Duplicate YAML basename '${base}' cannot run concurrently:" >&2
      echo "  ${seen_basenames[${base}]}" >&2
      echo "  ${yaml_file}" >&2
      echo "Both write to ${OUTPUT_ROOT:-./artifacts}/${base}. Rename one or set jobs=1." >&2
      exit 1
    fi
    echo "Warning: duplicate YAML basename '${base}'; ${yaml_file} overwrites artifacts from ${seen_basenames[${base}]}" >&2
  fi
  seen_basenames["${base}"]="${yaml_file}"

  selected_yamls+=("${yaml_file}")
  total_runs=$((total_runs + 1))
}

collect_from_target() {
  local list_file="$1"
  local raw_target="$2"
  local target yaml_file match
  target="$(expand_vars "${raw_target}")"

  if [[ -z "${target}" ]]; then
    return
  fi

  if [[ -d "${target}" ]]; then
    while IFS= read -r -d '' yaml_file; do
      select_yaml "${yaml_file}"
    done < <(find "${target}" -type f -name "*.yaml" -print0 | sort -z)
    return
  fi

  if [[ -f "${target}" && "${target}" == *.yaml ]]; then
    select_yaml "${target}"
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
        select_yaml "${yaml_file}"
      done < <(find "${match}" -type f -name "*.yaml" -print0 | sort -z)
    elif [[ -f "${match}" && "${match}" == *.yaml ]]; then
      select_yaml "${match}"
    fi
  done
}

run_serial() {
  local yaml_file exit_code

  for yaml_file in "${selected_yamls[@]}"; do
    exit_code=0
    run_yaml "${yaml_file}" || exit_code=$?
    record_result "${yaml_file}" "${exit_code}"
    if [[ ${exit_code} -ne 0 ]]; then
      handle_failure "${yaml_file}" "${exit_code}" || return 0
    fi
  done
}

JOB_DIR=""

cleanup_job_dir() {
  [[ -n "${JOB_DIR}" ]] && rm -rf "${JOB_DIR}"
  return 0
}

launch_job() {
  local idx="$1"
  local yaml_file="${selected_yamls[${idx}]}"

  printf '[start %d/%d] %s\n' "$((idx + 1))" "${total_runs}" "${yaml_file}" >&2
  (
    local_exit=0
    run_yaml "${yaml_file}" >"${JOB_DIR}/${idx}.out" 2>&1 || local_exit=$?
    # Published last, and via rename, so the parent only ever sees a complete
    # status file once the matching .out file is fully written.
    echo "${local_exit}" >"${JOB_DIR}/${idx}.status.part"
    mv "${JOB_DIR}/${idx}.status.part" "${JOB_DIR}/${idx}.status"
  ) &
}

flush_job() {
  local idx="$1"
  local yaml_file="${selected_yamls[${idx}]}"
  local exit_code

  exit_code="$(<"${JOB_DIR}/${idx}.status")"
  cat "${JOB_DIR}/${idx}.out"
  rm -f "${JOB_DIR}/${idx}.out" "${JOB_DIR}/${idx}.status"

  record_result "${yaml_file}" "${exit_code}"
  if [[ ${exit_code} -ne 0 ]]; then
    handle_failure "${yaml_file}" "${exit_code}" || return 1
  fi
  return 0
}

run_parallel() {
  local next_launch=0 next_print=0 running=0 stop_launching=0

  JOB_DIR="$(mktemp -d)"
  trap cleanup_job_dir EXIT

  # Each run would otherwise start the container itself, concurrently.
  if [[ "${EXECUTION_MODE}" == "docker" && ${DOCKER_AUTO_START} -eq 1 && -n "${CONTAINER_NAME}" ]]; then
    docker start "${CONTAINER_NAME}" >/dev/null
  fi

  echo "Running ${total_runs} YAMLs, up to ${JOBS} at a time."
  echo "Each run's output is buffered and printed in list order as it completes."

  while (( next_print < next_launch )) || (( stop_launching == 0 && next_launch < total_runs )); do
    while (( stop_launching == 0 && running < JOBS && next_launch < total_runs )); do
      launch_job "${next_launch}"
      next_launch=$((next_launch + 1))
      running=$((running + 1))
    done

    if (( running > 0 )); then
      # Exit status is read from the status file, so ignore the one wait reports.
      wait -n 2>/dev/null || true
      running=$((running - 1))
    fi

    while (( next_print < next_launch )) && [[ -f "${JOB_DIR}/${next_print}.status" ]]; do
      flush_job "${next_print}" || stop_launching=1
      next_print=$((next_print + 1))
    done
  done

  if (( stop_launching == 1 && next_launch < total_runs )); then
    echo "Skipped $((total_runs - next_launch)) remaining YAMLs because continue_on_failure=false." >&2
  fi
}

EXECUTION_MODE="$(normalize_execution_mode "${EXECUTION_MODE}")"

if [[ "${TASK_TYPE}" == "yaml" ]]; then
  if [[ ! -x "${RUN_ONE_SCRIPT}" ]]; then
    echo "Cannot execute ${RUN_ONE_SCRIPT}" >&2
    exit 1
  fi
  if [[ -z "${BUILD_DIR}" ]]; then
    echo "build_dir is required in config for task_type=yaml." >&2
    exit 1
  fi
  if [[ ${#LIST_FILES[@]} -eq 0 ]]; then
    echo "At least one list_file is required in config for task_type=yaml." >&2
    exit 1
  fi
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
      collect_from_target "${list_file}" "${line}"
    done < "${list_file}"
  done

  if [[ ${total_runs} -eq 0 ]]; then
    echo "No YAML files were selected by list files." >&2
    exit 1
  fi

  if [[ ${JOBS} -gt 1 && ${total_runs} -gt 1 ]]; then
    PARALLEL=1
    run_parallel
  else
    run_serial
  fi

  print_yaml_summary
  if [[ -n "${HARD_FAILURE_EXIT}" ]]; then
    exit "${HARD_FAILURE_EXIT}"
  fi
  if [[ ${failed_runs} -gt 0 ]]; then
    echo "Batch run complete with failures."
    exit 1
  fi
  echo "Batch run complete. Total YAML runs: ${total_runs}"
elif [[ "${TASK_TYPE}" == "hipblaslt_install" ]]; then
  run_hipblaslt_install
  echo "Batch run complete. Total hipblaslt install runs: 1"
else
  echo "Unknown task_type: ${TASK_TYPE}" >&2
  echo "Supported task_type values: yaml, hipblaslt_install" >&2
  exit 1
fi
