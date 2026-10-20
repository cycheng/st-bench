#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Run one Tensile YAML in docker or on host.

Usage:
  scripts/run-single-yaml.sh <config-file> <yaml-file>
  scripts/run-single-yaml.sh --yaml <file> --build-dir <dir> [options]

Required:
  --yaml <file>          YAML file to run.
  --build-dir <dir>      Build directory that contains Tensile.sh.

Optional:
  --config <file>        Config file path.
  --execution-mode <m>   Runtime mode: docker|host (default: docker).
  --container <name>     Docker container name (default: stinkytofu-dev).
  --workdir <dir>        Working directory inside container (default: current directory).
  --client <path>        Prebuilt client path (default: <build-dir>/tensilelite/client/tensilelite-client).
  --output-root <dir>    Host output root (default: ./artifacts).
  --env KEY=VALUE        Extra env var (repeatable). Overrides the same
                         key from --config.
  --env-file <file>      File with KEY=VALUE env lines (repeatable).
  --build-only           Generate and compile kernels without benchmarking.
  --no-build-only        Disable --build-only (default: --build-only is enabled).
  --reuse-build          Skip Tensile and re-run the run.sh scripts already
                         generated under <yaml-base>.out in the run directory.
  --no-start             Do not auto-start container.
  --run-dir <dir>        Generate <yaml-base>.out in this directory instead of
                         the workdir. The directory is kept.
  --isolate-run-dir      Run inside a private subdir of workdir. Required for
                         concurrent runs, which otherwise share cmpasm/.out.
  --keep-container-out   Keep <yaml-base>.out in container workdir.
  --live-output          Stream command output while also saving its log (default).
  --no-live-output       Save the log quietly, then print it when the run finishes.
  -h, --help             Show help.

Examples:
  scripts/run-single-yaml.sh examples/test.cfg examples/sample.yaml

  scripts/run-single-yaml.sh \
    --yaml examples/sample.yaml \
    --build-dir /work/hipblaslt/tensilelite/new_dbg_build_anydocker \
    --container my-dev-container \
    --workdir /work/st-codegen-test \
    --env TARGET_ARCH=gfx1250
EOF
}

YAML_FILE=""
BUILD_DIR=""
CONFIG_FILE=""
EXECUTION_MODE="docker"
CONTAINER_NAME="${DOCKER_CONTAINER:-stinkytofu-dev}"
WORKDIR="$(pwd)"
CLIENT_PATH=""
OUTPUT_ROOT="$(pwd)/artifacts"
AUTO_START=1
BUILD_ONLY=1
BUILD_ONLY_OVERRIDE=""
REUSE_BUILD=0
KEEP_CONTAINER_OUT=0
KEEP_CONTAINER_OUT_OVERRIDE=""
ISOLATE_RUN_DIR=0
RUN_DIR_ARG=""
LIVE_OUTPUT=1
LIVE_OUTPUT_OVERRIDE=""
RUN_DIR=""
EXTRA_ENVS=()
CLI_ENVS=()
ENV_FILES=()

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

git_commit_id_for_path() {
  local path="$1"
  local dir

  if [[ -d "${path}" ]]; then
    dir="${path}"
  else
    dir="$(dirname -- "${path}")"
  fi

  git -C "${dir}" rev-parse HEAD 2>/dev/null || true
}

detect_git_commit_id() {
  local commit_id=""
  local candidate

  for candidate in "${ABS_YAML}" "${WORKDIR}" "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"; do
    commit_id="$(git_commit_id_for_path "${candidate}")"
    if [[ -n "${commit_id}" ]]; then
      echo "${commit_id}"
      return
    fi
  done

  echo "unknown"
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
      task_type) : ;;  # accepted for shared config compatibility
      build_dir) BUILD_DIR="${value}" ;;
      list_file) : ;;  # accepted for shared config compatibility
      rocm_libraries_path) : ;;  # accepted for shared config compatibility
      execution_mode) EXECUTION_MODE="$(normalize_execution_mode "${value}")" ;;
      container) CONTAINER_NAME="${value}" ;;
      workdir) WORKDIR="${value}" ;;
      client) CLIENT_PATH="${value}" ;;
      output_root) OUTPUT_ROOT="${value}" ;;
      env) EXTRA_ENVS+=("${value}") ;;
      env_file) ENV_FILES+=("${value}") ;;
      docker_auto_start) AUTO_START="$(parse_bool "${value}")" ;;
      no_start) AUTO_START=$((1 - $(parse_bool "${value}"))) ;;
      build_only) BUILD_ONLY="$(parse_bool "${value}")" ;;
      keep_container_out) KEEP_CONTAINER_OUT="$(parse_bool "${value}")" ;;
      live_output) LIVE_OUTPUT="$(parse_bool "${value}")" ;;
      jobs) : ;;  # accepted for shared config compatibility
      hipblaslt_repo_path) : ;;      # accepted for shared config compatibility
      hipblaslt_install_flags) : ;;  # accepted for shared config compatibility
      hipblaslt_build_type) : ;;     # accepted for shared config compatibility
      hipblaslt_symlink_name) : ;;   # accepted for shared config compatibility
      *)
        echo "Unknown config key: ${key}" >&2
        exit 1
        ;;
    esac
  done < "${cfg}"
}

if [[ $# -ge 2 && "$1" != -* ]]; then
  CONFIG_FILE="$1"
  YAML_FILE="$2"
  shift 2
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      CONFIG_FILE="$2"
      shift 2
      ;;
    --yaml)
      YAML_FILE="$2"
      shift 2
      ;;
    --build-dir)
      BUILD_DIR="$2"
      shift 2
      ;;
    --execution-mode)
      EXECUTION_MODE="$(normalize_execution_mode "$2")"
      shift 2
      ;;
    --host|--native-host|--no-docker)
      EXECUTION_MODE="host"
      shift
      ;;
    --container)
      CONTAINER_NAME="$2"
      shift 2
      ;;
    --workdir)
      WORKDIR="$2"
      shift 2
      ;;
    --client)
      CLIENT_PATH="$2"
      shift 2
      ;;
    --output-root)
      OUTPUT_ROOT="$2"
      shift 2
      ;;
    --env)
      CLI_ENVS+=("$2")
      shift 2
      ;;
    --env-file)
      ENV_FILES+=("$2")
      shift 2
      ;;
    --build-only)
      BUILD_ONLY_OVERRIDE=1
      shift
      ;;
    --no-build-only)
      BUILD_ONLY_OVERRIDE=0
      shift
      ;;
    --reuse-build)
      REUSE_BUILD=1
      shift
      ;;
    --run-dir)
      [[ $# -ge 2 ]] || { echo "Missing value for --run-dir" >&2; exit 2; }
      RUN_DIR_ARG="$2"
      shift 2
      ;;
    --no-start)
      AUTO_START=0
      shift
      ;;
    --isolate-run-dir)
      ISOLATE_RUN_DIR=1
      shift
      ;;
    --keep-container-out)
      KEEP_CONTAINER_OUT_OVERRIDE=1
      shift
      ;;
    --live-output)
      LIVE_OUTPUT_OVERRIDE=1
      shift
      ;;
    --no-live-output)
      LIVE_OUTPUT_OVERRIDE=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -n "${CONFIG_FILE}" ]]; then
  parse_config_file "${CONFIG_FILE}"
fi
# Command-line --env is applied after the config so it overrides the same key.
for kv in "${CLI_ENVS[@]}"; do
  EXTRA_ENVS+=("${kv}")
done
if [[ -n "${BUILD_ONLY_OVERRIDE}" ]]; then
  BUILD_ONLY="${BUILD_ONLY_OVERRIDE}"
fi
if [[ -n "${KEEP_CONTAINER_OUT_OVERRIDE}" ]]; then
  KEEP_CONTAINER_OUT="${KEEP_CONTAINER_OUT_OVERRIDE}"
fi
if [[ ${REUSE_BUILD} -eq 1 ]]; then
  KEEP_CONTAINER_OUT=1
fi
if [[ -n "${LIVE_OUTPUT_OVERRIDE}" ]]; then
  LIVE_OUTPUT="${LIVE_OUTPUT_OVERRIDE}"
fi

if [[ -z "${YAML_FILE}" || -z "${BUILD_DIR}" ]]; then
  echo "YAML and build_dir are required." >&2
  usage
  exit 1
fi

EXECUTION_MODE="$(normalize_execution_mode "${EXECUTION_MODE}")"

if [[ ! -f "${YAML_FILE}" ]]; then
  echo "YAML file not found: ${YAML_FILE}" >&2
  exit 1
fi

TENSILE_PATH="${BUILD_DIR}/tensilelite/Tensile.sh"
if [[ ! -x "${TENSILE_PATH}" ]]; then
  echo "Tensile.sh is missing or not executable: ${TENSILE_PATH}" >&2
  exit 1
fi

if [[ -z "${CLIENT_PATH}" ]]; then
  CLIENT_PATH="${BUILD_DIR}/tensilelite/client/tensilelite-client"
fi
if [[ ! -x "${CLIENT_PATH}" ]]; then
  echo "Client binary is missing or not executable: ${CLIENT_PATH}" >&2
  exit 1
fi

if [[ "${EXECUTION_MODE}" == "docker" && ${AUTO_START} -eq 1 ]]; then
  docker start "${CONTAINER_NAME}" >/dev/null
fi

BASE_NAME="$(basename "${YAML_FILE}" .yaml)"
ABS_YAML="$(readlink -f "${YAML_FILE}")"
HOST_OUTPUT_DIR="${OUTPUT_ROOT}/${BASE_NAME}"
mkdir -p "${HOST_OUTPUT_DIR}"
GIT_COMMIT_ID="$(detect_git_commit_id)"

# Tensile writes cmpasm/ and <base>.out relative to its working directory, so
# concurrent runs must not share one. Everything handed to Tensile below is an
# absolute path, which lets each run own a private directory instead.
if [[ -n "${RUN_DIR_ARG}" && ${ISOLATE_RUN_DIR} -eq 1 ]]; then
  echo "--run-dir cannot be combined with --isolate-run-dir." >&2
  exit 1
fi
if [[ ${REUSE_BUILD} -eq 1 && ${ISOLATE_RUN_DIR} -eq 1 ]]; then
  echo "--reuse-build cannot be combined with --isolate-run-dir." >&2
  exit 1
fi
if [[ -n "${RUN_DIR_ARG}" ]]; then
  RUN_DIR="${RUN_DIR_ARG}"
elif [[ ${ISOLATE_RUN_DIR} -eq 1 ]]; then
  RUN_DIR="${WORKDIR}/.runs/${BASE_NAME}.$$"
else
  RUN_DIR="${WORKDIR}"
fi

runtime_sh() {
  if [[ "${EXECUTION_MODE}" == "docker" ]]; then
    docker exec -w "${WORKDIR}" "${CONTAINER_NAME}" bash -lc "$1"
  else
    (cd "${WORKDIR}" && /bin/bash -lc "$1")
  fi
}

remove_run_dir() {
  [[ ${ISOLATE_RUN_DIR} -eq 1 && -n "${RUN_DIR}" ]] || return 0
  runtime_sh "rm -rf '${RUN_DIR}'" >/dev/null 2>&1 || true
}

if [[ -n "${RUN_DIR_ARG}" || ${ISOLATE_RUN_DIR} -eq 1 ]]; then
  mkdir -p -- "${RUN_DIR}"
  runtime_sh "mkdir -p '${RUN_DIR}'"
fi
if [[ ${ISOLATE_RUN_DIR} -eq 1 && ${KEEP_CONTAINER_OUT} -eq 0 ]]; then
  # Also clean up when Tensile fails and set -e aborts the script.
  trap remove_run_dir EXIT
fi

RUNTIME_ENV_VARS=()
for kv in "${EXTRA_ENVS[@]}"; do
  RUNTIME_ENV_VARS+=("${kv}")
done

for env_file in "${ENV_FILES[@]}"; do
  if [[ ! -f "${env_file}" ]]; then
    echo "Env file not found: ${env_file}" >&2
    exit 1
  fi
  while IFS= read -r line; do
    [[ -z "${line}" || "${line}" =~ ^# ]] && continue
    RUNTIME_ENV_VARS+=("${line}")
  done < "${env_file}"
done

if [[ ${REUSE_BUILD} -eq 0 ]]; then
  if [[ "${EXECUTION_MODE}" == "docker" ]]; then
    docker exec -w "${RUN_DIR}" "${CONTAINER_NAME}" bash -lc "rm -rf '${BASE_NAME}.out' 'cmpasm'"
  else
    (cd "${RUN_DIR}" && rm -rf "${BASE_NAME}.out" "cmpasm")
  fi
fi

if [[ "${EXECUTION_MODE}" == "docker" ]]; then
  echo "Running ${ABS_YAML} in container ${CONTAINER_NAME}"
else
  echo "Running ${ABS_YAML} on host at ${RUN_DIR}"
fi
if [[ ${REUSE_BUILD} -eq 1 ]]; then
  echo "Reusing kernels already built in ${RUN_DIR}/${BASE_NAME}.out"
  # Tensile writes one run.sh per benchmark step, holding absolute paths to the
  # client and that step's ClientParameters.ini, and runs it from its own
  # directory. Replaying them benchmarks again without regenerating kernels.
  # Build-only compiles kernels and writes ClientParameters.ini, but run.sh is
  # created only when Tensile itself launches the client. Replay run.sh when it
  # exists; otherwise launch the prebuilt client against those ini files. Their
  # library paths are absolute, and the client prints the gflops CSV to stdout.
  TENSILE_ARGS="$(cat <<EOF
shopt -s nullglob
status=0
scripts=( '${BASE_NAME}.out'/1_BenchmarkProblems/*/*/build/run.sh )
if [ \${#scripts[@]} -gt 0 ]; then
  for script in "\${scripts[@]}"; do
    ( cd "\$(dirname "\${script}")" && bash ./run.sh ) || status=\$?
  done
  exit \${status}
fi
inis=( '${BASE_NAME}.out'/1_BenchmarkProblems/*/*/caches/*/source/ClientParameters.ini )
if [ \${#inis[@]} -eq 0 ]; then
  echo 'No generated run.sh or ClientParameters.ini found; rerun this YAML without --reuse-build.' >&2
  exit 1
fi
for ini in "\${inis[@]}"; do
  '${CLIENT_PATH}' --config-file "\${ini}" || status=\$?
  granularity="\${ini%/ClientParameters.ini}/ClientParameters_Granularity.ini"
  if [ -f "\${granularity}" ]; then
    '${CLIENT_PATH}' --config-file "\${granularity}" || status=\$?
  fi
done
exit \${status}
EOF
)"
else
  TENSILE_ARGS="'${TENSILE_PATH}' '${ABS_YAML}' '${BASE_NAME}.out'"
  if [[ ${BUILD_ONLY} -eq 1 ]]; then
    TENSILE_ARGS+=" --build-only"
  fi
  TENSILE_ARGS+=" --prebuilt-client='${CLIENT_PATH}'"
fi

run_status=0
run_log="${HOST_OUTPUT_DIR}/${BASE_NAME}.log"
DOCKER_ENV_ARGS=()
if [[ "${EXECUTION_MODE}" == "docker" ]]; then
  for kv in "${RUNTIME_ENV_VARS[@]}"; do
    DOCKER_ENV_ARGS+=("-e" "${kv}")
  done
fi

run_tensile() {
  if [[ "${EXECUTION_MODE}" == "docker" ]]; then
    echo "Git commit: ${GIT_COMMIT_ID}"
    echo "YAML: ${ABS_YAML}"
    echo "Execution mode: ${EXECUTION_MODE}"
    echo "Container: ${CONTAINER_NAME}"
    echo
    docker exec -w "${RUN_DIR}" "${DOCKER_ENV_ARGS[@]}" "${CONTAINER_NAME}" bash -lc \
      "${TENSILE_ARGS}"
  else
    echo "Git commit: ${GIT_COMMIT_ID}"
    echo "YAML: ${ABS_YAML}"
    echo "Execution mode: ${EXECUTION_MODE}"
    echo "Workdir: ${RUN_DIR}"
    echo
    (cd "${RUN_DIR}" && env "${RUNTIME_ENV_VARS[@]}" /bin/bash -lc "${TENSILE_ARGS}")
  fi
}

if [[ ${LIVE_OUTPUT} -eq 1 ]]; then
  if run_tensile </dev/null 2>&1 | tee "${run_log}"; then
    :
  else
    pipeline_status=("${PIPESTATUS[@]}")
    run_status="${pipeline_status[0]}"
    if [[ ${run_status} -eq 0 && ${pipeline_status[1]} -ne 0 ]]; then
      run_status="${pipeline_status[1]}"
    fi
  fi
else
  if run_tensile </dev/null >"${run_log}" 2>&1; then
    :
  else
    run_status=$?
  fi
  cat "${run_log}"
fi

if [[ -f "${run_log}" ]]; then
  grep -A 4 'Processes:' "${run_log}" || true
  grep -oE 'NO_CHECK.{0,10}' "${run_log}" || true
fi

# A reused build regenerates no cmpasm. Leave the artifacts from the build run.
if [[ ${REUSE_BUILD} -eq 0 ]]; then
# Do not let missing output from this run look like an artifact from an older
# run of the same YAML.
rm -rf "${HOST_OUTPUT_DIR}/orig" "${HOST_OUTPUT_DIR}/st"

if [[ "${EXECUTION_MODE}" == "docker" ]]; then
  if docker exec -w "${RUN_DIR}" "${CONTAINER_NAME}" bash -lc "test -d 'cmpasm/orig'"; then
    docker cp "${CONTAINER_NAME}:${RUN_DIR}/cmpasm/orig" "${HOST_OUTPUT_DIR}/orig"
  fi
  if docker exec -w "${RUN_DIR}" "${CONTAINER_NAME}" bash -lc "test -d 'cmpasm/st'"; then
    docker cp "${CONTAINER_NAME}:${RUN_DIR}/cmpasm/st" "${HOST_OUTPUT_DIR}/st"
  fi
  # Keep workspace clean after artifact copy.
  docker exec -w "${RUN_DIR}" "${CONTAINER_NAME}" bash -lc "rm -rf 'cmpasm'"
else
  if [[ -d "${RUN_DIR}/cmpasm/orig" ]]; then
    cp -a "${RUN_DIR}/cmpasm/orig" "${HOST_OUTPUT_DIR}/orig"
  fi
  if [[ -d "${RUN_DIR}/cmpasm/st" ]]; then
    cp -a "${RUN_DIR}/cmpasm/st" "${HOST_OUTPUT_DIR}/st"
  fi
  # Keep workspace clean after artifact copy.
  rm -rf "${RUN_DIR}/cmpasm"
fi

cp "${ABS_YAML}" "${HOST_OUTPUT_DIR}/"
fi

if [[ ${KEEP_CONTAINER_OUT} -eq 0 ]]; then
  if [[ "${EXECUTION_MODE}" == "docker" ]]; then
    docker exec -w "${RUN_DIR}" "${CONTAINER_NAME}" bash -lc "rm -rf '${BASE_NAME}.out'"
  else
    rm -rf "${RUN_DIR}/${BASE_NAME}.out"
  fi
fi

echo "Saved artifacts to ${HOST_OUTPUT_DIR}"
exit "${run_status}"
