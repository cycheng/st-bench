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
  --env KEY=VALUE        Extra docker env var (repeatable).
  --env-file <file>      File with KEY=VALUE env lines (repeatable).
  --no-build-only        Disable --build-only (default: --build-only is enabled).
  --no-start             Do not auto-start container.
  --keep-container-out   Keep <yaml-base>.out in container workdir.
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
KEEP_CONTAINER_OUT=0
EXTRA_ENVS=()
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
      EXTRA_ENVS+=("$2")
      shift 2
      ;;
    --env-file)
      ENV_FILES+=("$2")
      shift 2
      ;;
    --no-build-only)
      BUILD_ONLY=0
      shift
      ;;
    --no-start)
      AUTO_START=0
      shift
      ;;
    --keep-container-out)
      KEEP_CONTAINER_OUT=1
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

TENSILE_PATH="${BUILD_DIR}/Tensile.sh"
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

if [[ "${EXECUTION_MODE}" == "docker" ]]; then
  docker exec -w "${WORKDIR}" "${CONTAINER_NAME}" bash -lc "rm -rf '${BASE_NAME}.out' 'cmpasm'"
else
  (cd "${WORKDIR}" && rm -rf "${BASE_NAME}.out" "cmpasm")
fi

if [[ "${EXECUTION_MODE}" == "docker" ]]; then
  echo "Running ${ABS_YAML} in container ${CONTAINER_NAME}"
else
  echo "Running ${ABS_YAML} on host at ${WORKDIR}"
fi
TENSILE_ARGS="'${TENSILE_PATH}' '${ABS_YAML}' '${BASE_NAME}.out'"
if [[ ${BUILD_ONLY} -eq 1 ]]; then
  TENSILE_ARGS+=" --build-only"
fi
TENSILE_ARGS+=" --prebuilt-client='${CLIENT_PATH}'"

if [[ "${EXECUTION_MODE}" == "docker" ]]; then
  DOCKER_ENV_ARGS=()
  for kv in "${RUNTIME_ENV_VARS[@]}"; do
    DOCKER_ENV_ARGS+=("-e" "${kv}")
  done
  docker exec -w "${WORKDIR}" "${DOCKER_ENV_ARGS[@]}" "${CONTAINER_NAME}" bash -lc \
    "${TENSILE_ARGS}" 2>&1 \
    | tee "${HOST_OUTPUT_DIR}/${BASE_NAME}.log"
else
  (cd "${WORKDIR}" && env "${RUNTIME_ENV_VARS[@]}" /bin/bash -lc "${TENSILE_ARGS}") 2>&1 \
    | tee "${HOST_OUTPUT_DIR}/${BASE_NAME}.log"
fi

if [[ -f "${HOST_OUTPUT_DIR}/${BASE_NAME}.log" ]]; then
  grep -A 4 'Processes:' "${HOST_OUTPUT_DIR}/${BASE_NAME}.log" || true
  grep -oE 'NO_CHECK.{0,10}' "${HOST_OUTPUT_DIR}/${BASE_NAME}.log" || true
fi

if [[ "${EXECUTION_MODE}" == "docker" ]]; then
  if docker exec -w "${WORKDIR}" "${CONTAINER_NAME}" bash -lc "test -d 'cmpasm/orig'"; then
    rm -rf "${HOST_OUTPUT_DIR}/orig"
    docker cp "${CONTAINER_NAME}:${WORKDIR}/cmpasm/orig" "${HOST_OUTPUT_DIR}/orig"
  fi
  if docker exec -w "${WORKDIR}" "${CONTAINER_NAME}" bash -lc "test -d 'cmpasm/st'"; then
    rm -rf "${HOST_OUTPUT_DIR}/st"
    docker cp "${CONTAINER_NAME}:${WORKDIR}/cmpasm/st" "${HOST_OUTPUT_DIR}/st"
  fi
  # Keep workspace clean after artifact copy.
  docker exec -w "${WORKDIR}" "${CONTAINER_NAME}" bash -lc "rm -rf 'cmpasm'"
else
  if [[ -d "${WORKDIR}/cmpasm/orig" ]]; then
    rm -rf "${HOST_OUTPUT_DIR}/orig"
    cp -a "${WORKDIR}/cmpasm/orig" "${HOST_OUTPUT_DIR}/orig"
  fi
  if [[ -d "${WORKDIR}/cmpasm/st" ]]; then
    rm -rf "${HOST_OUTPUT_DIR}/st"
    cp -a "${WORKDIR}/cmpasm/st" "${HOST_OUTPUT_DIR}/st"
  fi
  # Keep workspace clean after artifact copy.
  rm -rf "${WORKDIR}/cmpasm"
fi

cp "${ABS_YAML}" "${HOST_OUTPUT_DIR}/"

if [[ ${KEEP_CONTAINER_OUT} -eq 0 ]]; then
  if [[ "${EXECUTION_MODE}" == "docker" ]]; then
    docker exec -w "${WORKDIR}" "${CONTAINER_NAME}" bash -lc "rm -rf '${BASE_NAME}.out'"
  else
    rm -rf "${WORKDIR}/${BASE_NAME}.out"
  fi
fi

echo "Saved artifacts to ${HOST_OUTPUT_DIR}"
