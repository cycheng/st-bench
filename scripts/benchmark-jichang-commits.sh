#!/usr/bin/env bash

set -uo pipefail

usage() {
  cat <<'EOF'
Benchmark the Jichang MAB, MAF, and medium YAMLs, optionally across a
rocm-libraries commit range or an explicit commit list.

Usage:
  scripts/benchmark-jichang-commits.sh [options]

Options:
  --commit <commit>      Run this exact commit. Repeat for multiple commits.
                         Cannot be combined with --start/--end.
  --start <commit>       First range boundary (inclusive; requires --end).
  --end <commit>         Last range boundary (inclusive; requires --start).
  --config <file>        run-single-yaml config (default: examples/test.cfg).
  --repo <dir>           rocm-libraries repository (default: ~/rocm-libraries).
  --patch <file>         Patch applied to every checked-out commit (disabled
                         by default).
  --timeout <duration>   Maximum time for one YAML (default: 10m).
  --repeat <num>         Run each commit/YAML this many times (default: 1).
  --no-validate          Set NumElementsToValidate to 0 for every measured run.
  --validate-first-only  With --repeat, validate only the first run for each
                         commit/YAML and disable validation for later runs.
  --live-output          Stream YAML output (or set live_output=true in config).
  --pm-log-maf           Run agt_internal PM logging during MAF workload runs
                         using longer MAF warmup/enqueue settings.
  --force-pm-log         Run agt_internal PM logging for every selected YAML.
                         Does not rewrite warmup or enqueue counts.
  --keep-pm-log          Keep raw PM CSV files after extracting their summary.
                         Requires --pm-log-maf or --force-pm-log.
  --gpu <index>          Physical GPU index (default: 0). Sets
                         HIP_VISIBLE_DEVICES for every YAML run, overriding
                         the same key in the config. PM logging monitors GPU n
                         with agt_internal -i=5n (-i=0 for GPU 0).
  --agt-internal <file>  agt_internal executable (default: /opt/amd-apps/
                         agt_internal/agt_internal).
  --skip-identical-asm   Build and compare ASM with the previous selected
                         commit; reuse its score when the ASM is identical.
  --output-dir <dir>     Result directory (default: benchmark-results/<time>).
  --category <name>      Only run mab, maf, or medium.
  --yaml <file>          Only run this YAML under examples/jichang. Repeat
                         to run several, in the order given. Catalog names
                         such as maf/f8_tn_maf.yaml are accepted, and so is
                         any other file under examples/jichang.
  --exclude-yaml <file>  Skip one YAML, relative to examples/jichang. Repeat
                         this option to skip multiple YAMLs.
  --component <name>     Range commits from stinkytofu, hipblaslt, or either
                         (default: either).
  -h, --help             Show this help.

Without --commit or --start/--end, test the current checkout once and do not
change or stash the repository.

In range mode, commits that modify shared/stinkytofu, projects/hipblaslt, or
both are tested. Repeated --commit options instead test exactly the supplied
commits in the supplied order, without component filtering. The source column
identifies which component each commit changes. When at least two commits are
selected, asm-same reports whether each commit's complete generated st ASM
matches the previous chronological commit. Local tracked changes are stashed
once. When supplied, --patch is applied to each tested commit.

With two or more commits, each commit is copied to codebases/<sha> (a git
worktree) and every selected YAML is built before any measured run. Kernel
generation checks that commit out in the main repository, because Tensile.sh
compiles against it; the copy and the kernels/<sha>/<test> directory keep
that commit's results. The script then runs one YAML across all commits
before the next YAML, replaying the saved run.sh. With --repeat, each
repetition of that YAML runs on every commit before the next repetition
starts (A, B, C, then A, B, C again). A single commit still builds and
measures each YAML before the next one.

YAML compatibility is selected automatically for each rocm-libraries commit:
  before f2a6c23df523:  st-codegen-test revision 2065321
  f2a6c23df523 onward: st-codegen-test revision c394e5b
  9a9953849d8 onward:  st-codegen-test HEAD at benchmark start

For that current HEAD revision, each selected YAML is copied from the working
tree. If the working tree file differs from HEAD, the script warns and still
uses that dirty copy. Pinned older revisions are loaded with git show and
ignore working tree edits. An output directory that already contains the
extracted YAML reuses it.

Output:
  run-state.csv           Atomic resumable task ledger (source of truth).
  run-samples.csv         Individual score and time-us from each repetition.
  run-statistics.csv      Score and time-us statistics per YAML.
  results.csv             Tested commits and maximum score per YAML.
  summary.txt             Human-readable table, updated after every YAML.
  time-summary.txt        Execution-time tables in us; lower is better for
                           mab, maf, and medium.
  failures.csv            YAML failures and skipped-commit reasons.
  pm-summary.csv          Per-run active-window PM frequency statistics.
  asm-summary.csv         Per-commit-pair and per-YAML ASM comparison counts.
  asm-file-comparisons.csv
                           Exact status and hashes for every ASM file.
  logs/<commit>/<test>.attempt-N.log
  logs/<commit>/<test>.attempt-N.run-M.log (when --repeat is greater than 1)
  logs/<commit>/<test>.attempt-N.pm.log (agt_internal console output)
  asm/<commit>/<test>/st  Cached generated ASM used for comparison.
  codebases/<commit>      Git worktree of that commit, for multi-commit runs.
  kernels/<commit>/<test> Generated kernels replayed across those commits.
  asm-diffs/<pair>/<test>/<file>.diff
                           Unified diffs for changed ASM files.

Reusing --output-dir resumes that run. Completed YAMLs, including failures,
are skipped; interrupted running YAMLs receive a new attempt log.
After an unexpected interruption, manually restore the rocm-libraries worktree
before resuming; the script does not validate the recovered Git state.
SIGINT, SIGTERM, SIGHUP, and SIGTSTP cancel the active YAML and leave it
pending. agt_internal is stopped with SIGTERM and is never SIGKILL'd; a
second interrupt during that cleanup is ignored. Rerun the command to
resume; do not use shell fg/bg for recovery.

MAB scores use max(gbps-bandwidth) in GB/s. MAF and medium scores use
max(gflops) / 1000 in PFLOPS.
A score followed by * came from a row whose validation field is FAILED, so the
measured performance is shown but its output was incorrect. A YAML with no
finite value for its metric is recorded as 0, and the remaining YAMLs still
run. A score followed by = generated the same ASM as the previous chronological
commit for that YAML.
ASM comparison ignores // comments and the nondeterministic 16-character
hash in cluster-barrier basic-block labels.
Average and standard deviation use finite performance samples; standard
deviation is the population standard deviation.
Execution time is read from the time-us column on the row selected for the
maximum score.
EOF
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
HEAD_YAML_REVISION=""
RESULT_HELPER="${SCRIPT_DIR}/benchmark-jichang-results.py"
STATE_HELPER="${SCRIPT_DIR}/benchmark-jichang-state.py"
CONFIG_FILE="${PROJECT_DIR}/examples/test.cfg"
ROCM_REPO="${HOME}/rocm-libraries"
PATCH_FILE=""
YAML_TIMEOUT="10m"
REPEAT_RUNS=1
NO_VALIDATE=0
VALIDATE_FIRST_ONLY=0
VALIDATION_MODE="all"
LIVE_OUTPUT=0
PM_LOG_MAF=0
FORCE_PM_LOG=0
KEEP_PM_LOG=0
GPU_EXPLICIT=0
GPU_INDEX=0
PM_DEVICE_SELECTOR=0
YAML_GPU_ARGS=()
AGT_INTERNAL="/opt/amd-apps/agt_internal/agt_internal"
SKIP_IDENTICAL_ASM=0
OUTPUT_DIR="${PROJECT_DIR}/benchmark-results/$(date +%Y%m%d-%H%M%S)"
START_COMMIT=""
END_COMMIT=""
SELECTED_COMMITS=()
CATEGORY=""
ONLY_YAMLS=()
EXCLUDED_YAMLS=()
COMPONENT="either"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --commit)
      [[ $# -ge 2 ]] || { echo "Missing value for --commit" >&2; exit 2; }
      SELECTED_COMMITS+=("$2")
      shift 2
      ;;
    --start)
      [[ $# -ge 2 ]] || { echo "Missing value for --start" >&2; exit 2; }
      START_COMMIT="$2"
      shift 2
      ;;
    --end)
      [[ $# -ge 2 ]] || { echo "Missing value for --end" >&2; exit 2; }
      END_COMMIT="$2"
      shift 2
      ;;
    --config)
      [[ $# -ge 2 ]] || { echo "Missing value for --config" >&2; exit 2; }
      CONFIG_FILE="$2"
      shift 2
      ;;
    --repo)
      [[ $# -ge 2 ]] || { echo "Missing value for --repo" >&2; exit 2; }
      ROCM_REPO="$2"
      shift 2
      ;;
    --patch)
      [[ $# -ge 2 ]] || { echo "Missing value for --patch" >&2; exit 2; }
      PATCH_FILE="$2"
      shift 2
      ;;
    --timeout)
      [[ $# -ge 2 ]] || { echo "Missing value for --timeout" >&2; exit 2; }
      YAML_TIMEOUT="$2"
      shift 2
      ;;
    --repeat)
      [[ $# -ge 2 ]] || { echo "Missing value for --repeat" >&2; exit 2; }
      REPEAT_RUNS="$2"
      shift 2
      ;;
    --no-validate)
      NO_VALIDATE=1
      shift
      ;;
    --validate-first-only)
      VALIDATE_FIRST_ONLY=1
      shift
      ;;
    --live-output)
      LIVE_OUTPUT=1
      shift
      ;;
    --pm-log-maf)
      PM_LOG_MAF=1
      shift
      ;;
    --force-pm-log)
      FORCE_PM_LOG=1
      shift
      ;;
    --keep-pm-log)
      KEEP_PM_LOG=1
      shift
      ;;
    --gpu)
      [[ $# -ge 2 ]] || { echo "Missing value for --gpu" >&2; exit 2; }
      GPU_INDEX="$2"
      GPU_EXPLICIT=1
      shift 2
      ;;
    --agt-internal)
      [[ $# -ge 2 ]] || { echo "Missing value for --agt-internal" >&2; exit 2; }
      AGT_INTERNAL="$2"
      shift 2
      ;;
    --skip-identical-asm)
      SKIP_IDENTICAL_ASM=1
      shift
      ;;
    --output-dir)
      [[ $# -ge 2 ]] || { echo "Missing value for --output-dir" >&2; exit 2; }
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --category)
      [[ $# -ge 2 ]] || { echo "Missing value for --category" >&2; exit 2; }
      CATEGORY="$2"
      shift 2
      ;;
    --yaml)
      [[ $# -ge 2 ]] || { echo "Missing value for --yaml" >&2; exit 2; }
      ONLY_YAMLS+=("$2")
      shift 2
      ;;
    --exclude-yaml)
      [[ $# -ge 2 ]] || { echo "Missing value for --exclude-yaml" >&2; exit 2; }
      EXCLUDED_YAMLS+=("$2")
      shift 2
      ;;
    --component)
      [[ $# -ge 2 ]] || { echo "Missing value for --component" >&2; exit 2; }
      COMPONENT="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if { [[ -n "${START_COMMIT}" ]] && [[ -z "${END_COMMIT}" ]]; } ||
   { [[ -z "${START_COMMIT}" ]] && [[ -n "${END_COMMIT}" ]]; }; then
  echo "--start and --end must be provided together." >&2
  exit 2
fi
if [[ ${#SELECTED_COMMITS[@]} -gt 0 && -n "${START_COMMIT}" ]]; then
  echo "--commit cannot be combined with --start/--end." >&2
  exit 2
fi
if [[ -n "${CATEGORY}" ]] &&
   [[ "${CATEGORY}" != "mab" && "${CATEGORY}" != "maf" && "${CATEGORY}" != "medium" ]]; then
  echo "--category must be mab, maf, or medium." >&2
  exit 2
fi
if [[ ! "${REPEAT_RUNS}" =~ ^[1-9][0-9]*$ ]]; then
  echo "--repeat must be a positive integer." >&2
  exit 2
fi
if [[ ! "${GPU_INDEX}" =~ ^[0-9]+$ ]]; then
  echo "--gpu must be a non-negative integer." >&2
  exit 2
fi
if [[ ${NO_VALIDATE} -eq 1 && ${VALIDATE_FIRST_ONLY} -eq 1 ]]; then
  echo "--no-validate and --validate-first-only cannot be combined." >&2
  exit 2
fi
if [[ ${KEEP_PM_LOG} -eq 1 && ${PM_LOG_MAF} -eq 0 && ${FORCE_PM_LOG} -eq 0 ]]; then
  echo "--keep-pm-log requires --pm-log-maf or --force-pm-log." >&2
  exit 2
fi
if [[ ${NO_VALIDATE} -eq 1 ]]; then
  VALIDATION_MODE="none"
elif [[ ${VALIDATE_FIRST_ONLY} -eq 1 ]]; then
  VALIDATION_MODE="first-repeat"
fi
if [[ "${COMPONENT}" != "stinkytofu" &&
      "${COMPONENT}" != "hipblaslt" &&
      "${COMPONENT}" != "either" ]]; then
  echo "--component must be stinkytofu, hipblaslt, or either." >&2
  exit 2
fi

CONFIG_FILE="$(readlink -f -- "${CONFIG_FILE}")"
ROCM_REPO="$(readlink -f -- "${ROCM_REPO}")"
if [[ -n "${PATCH_FILE}" ]]; then
  PATCH_FILE="$(readlink -f -- "${PATCH_FILE}")"
fi
AGT_INTERNAL="$(readlink -f -- "${AGT_INTERNAL}")"
OUTPUT_DIR="$(readlink -m -- "${OUTPUT_DIR}")"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Config file not found: ${CONFIG_FILE}" >&2
  exit 2
fi
CONFIG_GPU=""
while IFS= read -r config_line || [[ -n "${config_line}" ]]; do
  config_line="${config_line#"${config_line%%[![:space:]]*}"}"
  config_line="${config_line%"${config_line##*[![:space:]]}"}"
  [[ -z "${config_line}" || "${config_line}" == \#* ]] && continue
  config_key="${config_line%%=*}"
  config_value="${config_line#*=}"
  config_key="${config_key#"${config_key%%[![:space:]]*}"}"
  config_key="${config_key%"${config_key##*[![:space:]]}"}"
  config_value="${config_value#"${config_value%%[![:space:]]*}"}"
  config_value="${config_value%"${config_value##*[![:space:]]}"}"
  if [[ "${config_key}" == "env" && "${config_value}" == HIP_VISIBLE_DEVICES=* ]]; then
    CONFIG_GPU="${config_value#HIP_VISIBLE_DEVICES=}"
  fi
  [[ "${config_key}" == "live_output" ]] || continue
  case "${config_value,,}" in
    1|true|yes|on) LIVE_OUTPUT=1 ;;
    0|false|no|off) ;;
    *)
      echo "Invalid live_output value in ${CONFIG_FILE}: ${config_value}" >&2
      exit 2
      ;;
  esac
done < "${CONFIG_FILE}"
if [[ -n "${CONFIG_GPU}" && ! "${CONFIG_GPU}" =~ ^[0-9]+$ ]]; then
  echo "Invalid HIP_VISIBLE_DEVICES in ${CONFIG_FILE}: ${CONFIG_GPU}" >&2
  exit 2
fi
if [[ ${GPU_EXPLICIT} -eq 0 && -n "${CONFIG_GPU}" ]]; then
  GPU_INDEX="${CONFIG_GPU}"
elif [[ ${GPU_EXPLICIT} -eq 1 && -n "${CONFIG_GPU}" && "${CONFIG_GPU}" != "${GPU_INDEX}" ]]; then
  echo "Config HIP_VISIBLE_DEVICES=${CONFIG_GPU} overridden by --gpu ${GPU_INDEX}." >&2
fi
# agt_internal device n*5 is physical GPU n. -i=0 is GPU 0, -i=5 is GPU 1.
PM_DEVICE_SELECTOR=$((10#${GPU_INDEX} * 5))
if [[ ${GPU_EXPLICIT} -eq 1 ]]; then
  YAML_GPU_ARGS=(--env "HIP_VISIBLE_DEVICES=${GPU_INDEX}")
fi
if [[ ${GPU_EXPLICIT} -eq 1 || -n "${CONFIG_GPU}" ]]; then
  echo "GPU ${GPU_INDEX}: HIP_VISIBLE_DEVICES=${GPU_INDEX}, agt_internal -i=${PM_DEVICE_SELECTOR}"
else
  echo "GPU ${GPU_INDEX}: agt_internal -i=${PM_DEVICE_SELECTOR} (HIP_VISIBLE_DEVICES unchanged)"
fi
if [[ -n "${PATCH_FILE}" && ! -f "${PATCH_FILE}" ]]; then
  echo "Patch file not found: ${PATCH_FILE}" >&2
  exit 2
fi
if ! command -v setsid >/dev/null 2>&1 ||
   ! command -v timeout >/dev/null 2>&1 ||
   ! command -v tail >/dev/null 2>&1; then
  echo "This script requires the setsid, timeout, and tail commands." >&2
  exit 2
fi
if [[ ${PM_LOG_MAF} -eq 1 || ${FORCE_PM_LOG} -eq 1 ]]; then
  if ! command -v sudo >/dev/null 2>&1; then
    echo "PM logging requires sudo." >&2
    exit 2
  fi
  if [[ ! -x "${AGT_INTERNAL}" ]]; then
    echo "agt_internal executable not found: ${AGT_INTERNAL}" >&2
    exit 2
  fi
  if ! sudo -n true >/dev/null 2>&1; then
    echo "PM logging requires passwordless sudo or an existing sudo credential." >&2
    exit 2
  fi
fi
if [[ ${EUID} -eq 0 && -n "${SUDO_USER:-}" ]]; then
  echo "WARNING: running the entire benchmark through sudo is discouraged." >&2
  echo "Prefer normal user permissions and run it inside tmux." >&2
fi
if [[ ! -f "${RESULT_HELPER}" ]]; then
  echo "Result helper not found: ${RESULT_HELPER}" >&2
  exit 2
fi
if [[ ! -f "${STATE_HELPER}" ]]; then
  echo "State helper not found: ${STATE_HELPER}" >&2
  exit 2
fi
if [[ ! -d "${ROCM_REPO}/shared/stinkytofu" ]]; then
  echo "stinkytofu directory not found: ${ROCM_REPO}/shared/stinkytofu" >&2
  exit 2
fi
if ! git -C "${ROCM_REPO}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Not a Git repository: ${ROCM_REPO}" >&2
  exit 2
fi
if ! git -C "${PROJECT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Benchmark project is not a Git repository: ${PROJECT_DIR}" >&2
  exit 2
fi
HEAD_YAML_REVISION="$(git -C "${PROJECT_DIR}" rev-parse HEAD)"

ALL_TEST_NAMES=(
  mab-bf16 mab-FP8 mab-MXFP8 mab-MXFP4 mab-NVFP4 mab-bf16-m64
  maf-bf16 maf-FP8 maf-FP8-henry maf-MXFP8 maf-MXFP8-henry maf-MXFP4 maf-NVFP4
  medium-bf16 medium-FP8 medium-MXFP8 medium-MXFP4
)
ALL_TEST_YAMLS=(
  examples/jichang/mab/bbs_tn_mab.yaml
  examples/jichang/mab/f8_tn_mab.yaml
  examples/jichang/mab/mxf8_tn_mab.yaml
  examples/jichang/mab/mxf4_tn_mab.yaml
  examples/jichang/mab/nvf4_tn_mab.yaml
  examples/jichang/mab/bbs_tn_m_64_mab.yaml
  examples/jichang/maf/bbs_tn_maf.yaml
  examples/jichang/maf/f8_tn_maf.yaml
  examples/jichang/maf/f8_tn_maf_henry.yaml
  examples/jichang/maf/mxf8_tn_maf.yaml
  examples/jichang/maf/mxf8_tn_maf_henry.yaml
  examples/jichang/maf/mxf4_tn_maf.yaml
  examples/jichang/maf/nvf4_tn_maf.yaml
  examples/jichang/medium/bbs_tn_medium.yaml
  examples/jichang/medium/f8_tn_medium.yaml
  examples/jichang/medium/mxf8_tn_medium.yaml
  examples/jichang/medium/mxf4_tn_medium.yaml
)

normalize_jichang_yaml() {
  local yaml="$1"
  yaml="${yaml#./}"
  if [[ "${yaml}" == *"/examples/jichang/"* ]]; then
    yaml="examples/jichang/${yaml#*examples/jichang/}"
  elif [[ "${yaml}" != examples/jichang/* ]]; then
    yaml="examples/jichang/${yaml#examples/jichang/}"
  fi
  case "${yaml}" in
    *..*)
      echo "YAML path must stay under examples/jichang: ${yaml}" >&2
      return 2
      ;;
  esac
  printf '%s\n' "${yaml}"
}

yaml_is_excluded() {
  local yaml="$1"
  local excluded_yaml
  for excluded_yaml in "${EXCLUDED_YAMLS[@]}"; do
    if [[ "${yaml}" == "${excluded_yaml}" ]]; then
      return 0
    fi
  done
  return 1
}

yaml_matches_category() {
  local yaml="$1"
  local yaml_category="${yaml#examples/jichang/}"
  if [[ "${yaml_category}" == */* ]]; then
    yaml_category="${yaml_category%%/*}"
  else
    yaml_category=""
  fi
  [[ -z "${CATEGORY}" || "${yaml_category}" == "${CATEGORY}" ]]
}

if [[ ${#ONLY_YAMLS[@]} -gt 0 ]]; then
  normalized_yamls=()
  for yaml in "${ONLY_YAMLS[@]}"; do
    yaml="$(normalize_jichang_yaml "${yaml}")" || exit 2
    normalized_yamls+=("${yaml}")
  done
  ONLY_YAMLS=("${normalized_yamls[@]}")
fi
for index in "${!EXCLUDED_YAMLS[@]}"; do
  yaml="${EXCLUDED_YAMLS[${index}]#./}"
  yaml="${yaml#examples/jichang/}"
  EXCLUDED_YAMLS[${index}]="examples/jichang/${yaml}"
done

TEST_NAMES=()
TEST_YAMLS=()
if [[ ${#ONLY_YAMLS[@]} -eq 0 ]]; then
  for index in "${!ALL_TEST_NAMES[@]}"; do
    yaml="${ALL_TEST_YAMLS[${index}]}"
    yaml_matches_category "${yaml}" || continue
    yaml_is_excluded "${yaml}" && continue
    TEST_NAMES+=("${ALL_TEST_NAMES[${index}]}")
    TEST_YAMLS+=("${yaml}")
  done
else
  for requested in "${ONLY_YAMLS[@]}"; do
    if [[ ${#TEST_YAMLS[@]} -gt 0 ]]; then
      for selected in "${TEST_YAMLS[@]}"; do
        if [[ "${selected}" == "${requested}" ]]; then
          echo "Duplicate YAML: ${requested}" >&2
          exit 2
        fi
      done
    fi
    if yaml_is_excluded "${requested}" || ! yaml_matches_category "${requested}"; then
      echo "Unknown YAML or YAML excluded by filters: ${requested}" >&2
      exit 2
    fi
    found=0
    for index in "${!ALL_TEST_YAMLS[@]}"; do
      if [[ "${ALL_TEST_YAMLS[${index}]}" == "${requested}" ]]; then
        TEST_NAMES+=("${ALL_TEST_NAMES[${index}]}")
        TEST_YAMLS+=("${requested}")
        found=1
        break
      fi
    done
    if [[ ${found} -eq 0 ]]; then
      if [[ ! -f "${PROJECT_DIR}/${requested}" ]]; then
        echo "Unknown YAML or YAML excluded by filters: ${requested}" >&2
        exit 2
      fi
      rel="${requested#examples/jichang/}"
      test_name="${rel%.yaml}"
      test_name="${test_name//\//-}"
      TEST_NAMES+=("${test_name}")
      TEST_YAMLS+=("${requested}")
    fi
  done
fi

if [[ ${#TEST_YAMLS[@]} -eq 0 ]]; then
  echo "No YAMLs selected after applying filters." >&2
  exit 2
fi

for yaml in "${TEST_YAMLS[@]}"; do
  if [[ ! -f "${PROJECT_DIR}/${yaml}" ]]; then
    echo "YAML file not found: ${PROJECT_DIR}/${yaml}" >&2
    exit 2
  fi
done

init_args=(
  --output "${OUTPUT_DIR}" --config "${CONFIG_FILE}" --repo "${ROCM_REPO}"
  --repeat "${REPEAT_RUNS}" --validation-mode "${VALIDATION_MODE}"
)
if [[ ${PM_LOG_MAF} -eq 1 ]]; then
  init_args+=(--pm-log-maf)
fi
if ! python3 "${STATE_HELPER}" init "${init_args[@]}"; then
  exit 1
fi
mkdir -p "${OUTPUT_DIR}/logs"
RUN_STATE="${OUTPUT_DIR}/run-state.csv"
RESULTS_CSV="${OUTPUT_DIR}/results.csv"
SUMMARY_FILE="${OUTPUT_DIR}/summary.txt"
TIME_SUMMARY_FILE="${OUTPUT_DIR}/time-summary.txt"
FAILURES_CSV="${OUTPUT_DIR}/failures.csv"

regenerate_reports() {
  python3 "${STATE_HELPER}" reports --output "${OUTPUT_DIR}" || exit 1
}

finish_task() {
  python3 "${STATE_HELPER}" finish --state "${RUN_STATE}" \
    --commit "$1" --test "$2" --status "$3" --score "$4" \
    --asm-status "$5" --message "$6" || exit 1
  regenerate_reports
}

extract_best_result() {
  python3 "${RESULT_HELPER}" extract "$1" --metric "$2" --include-time-us
}

cache_generated_asm() {
  local log_file="$1"
  local destination="$2"
  local artifact_dir

  artifact_dir="$(awk '
    /^Saved artifacts to / {
      sub(/^Saved artifacts to /, "")
      path = $0
    }
    END { print path }
  ' "${log_file}")"
  if [[ -z "${artifact_dir}" ]]; then
    echo "run-single-yaml did not report its artifact directory" >&2
    return 1
  fi
  if [[ "${artifact_dir}" != /* ]]; then
    artifact_dir="${PROJECT_DIR}/${artifact_dir}"
  fi
  if [[ ! -d "${artifact_dir}/st" ]]; then
    echo "Generated st ASM directory not found: ${artifact_dir}/st" >&2
    return 1
  fi

  rm -rf -- "${destination}"
  mkdir -p -- "$(dirname -- "${destination}")"
  cp -a -- "${artifact_dir}/st" "${destination}"
}

ACTIVE_PM_PID=""
ACTIVE_PM_CSV=""
ACTIVE_PM_RUNTIME_LOG=""

pm_logger_alive() {
  local pm_pid="$1"
  sudo -n kill -0 -- "-${pm_pid}" 2>/dev/null ||
    sudo -n kill -0 -- "${pm_pid}" 2>/dev/null
}

stop_pm_logging() {
  local pm_pid="${ACTIVE_PM_PID}"
  local stop_status=0

  [[ -n "${pm_pid}" ]] || return 0
  # Clear first so a nested interrupt cannot stop this logger twice.
  ACTIVE_PM_PID=""
  ACTIVE_PM_CSV=""
  ACTIVE_PM_RUNTIME_LOG=""

  # setsid makes this pid the session leader. Signal that process group so
  # both sudo and agt_internal receive SIGTERM. Never SIGKILL agt_internal:
  # an uncatchable kill leaves the SMU PM interface dead until reboot.
  sudo -n kill -TERM -- "-${pm_pid}" 2>/dev/null ||
    sudo -n kill -TERM "${pm_pid}" 2>/dev/null || true
  for _ in {1..100}; do
    pm_logger_alive "${pm_pid}" || break
    sleep 0.1
  done
  if pm_logger_alive "${pm_pid}"; then
    echo "agt_internal pid ${pm_pid} is still running after SIGTERM." >&2
    echo "Do not SIGKILL it. That leaves the PM interface dead until reboot." >&2
    stop_status=1
  else
    wait "${pm_pid}" 2>/dev/null || true
  fi
  return "${stop_status}"
}

start_pm_logging() {
  local workload_log="$1"
  local pm_csv="${workload_log%.log}_pm.csv"
  local pm_runtime_log="${workload_log%.log}.pm.log"

  mkdir -p -- "$(dirname -- "${pm_csv}")"
  echo "--- PM logging: ${pm_csv} (-i=${PM_DEVICE_SELECTOR})"
  (
    exec setsid --wait sudo -n "${AGT_INTERNAL}" \
      -unilog=PM -unilogallgroups -unilogperiod=50 "-i=${PM_DEVICE_SELECTOR}" \
      "-unilogoutput=${pm_csv}"
  ) </dev/null >"${pm_runtime_log}" 2>&1 &
  ACTIVE_PM_PID=$!
  ACTIVE_PM_CSV="${pm_csv}"
  ACTIVE_PM_RUNTIME_LOG="${pm_runtime_log}"

  for _ in {1..300}; do
    if grep -Fq '[ ...START LOGGING... ]' "${pm_runtime_log}"; then
      return 0
    fi
    if ! pm_logger_alive "${ACTIVE_PM_PID}"; then
      echo "agt_internal exited before PM logging started." >&2
      wait "${ACTIVE_PM_PID}" 2>/dev/null || true
      ACTIVE_PM_PID=""
      return 1
    fi
    sleep 0.1
  done

  echo "Timed out waiting for agt_internal to start PM logging." >&2
  stop_pm_logging || true
  return 1
}

run_yaml() {
  local yaml_file="$1"
  local log_file="$2"
  local mode="$3"
  shift 3
  local mode_arg=("$@")
  local run_status=0
  local pm_csv_path=""
  local pm_record_args=()
  local pm_started=0
  local measured=0

  case "${mode}" in
    build-only)
      mode_arg+=(--build-only)
      ;;
    reuse)
      mode_arg+=(--reuse-build)
      measured=1
      ;;
    config)
      measured=1
      ;;
    *)
      echo "Unknown YAML run mode: ${mode}" >&2
      return 2
      ;;
  esac

  if [[ ${measured} -eq 1 && ( ${FORCE_PM_LOG} -eq 1 ||
        ( ${PM_LOG_MAF} -eq 1 && "${yaml_file}" == */maf/* ) ) ]]; then
    if ! start_pm_logging "${log_file}"; then
      return 1
    fi
    pm_started=1
  fi

  if [[ ${LIVE_OUTPUT} -eq 1 ]]; then
    (
      cd "${PROJECT_DIR}" || exit 1
      exec setsid --wait timeout --signal=TERM --kill-after=30s \
        "${YAML_TIMEOUT}" ./scripts/run-single-yaml.sh \
        "${CONFIG_FILE}" "${yaml_file}" "${mode_arg[@]}" "${YAML_GPU_ARGS[@]}" --live-output
    ) </dev/null >"${log_file}" 2>&1 &
  else
    (
      cd "${PROJECT_DIR}" || exit 1
      exec setsid --wait timeout --signal=TERM --kill-after=30s \
        "${YAML_TIMEOUT}" ./scripts/run-single-yaml.sh \
        "${CONFIG_FILE}" "${yaml_file}" "${mode_arg[@]}" "${YAML_GPU_ARGS[@]}"
    ) </dev/null >"${log_file}" 2>&1 &
  fi
  ACTIVE_RUN_PID=$!
  if [[ ${LIVE_OUTPUT} -eq 1 ]]; then
    tail --pid="${ACTIVE_RUN_PID}" -n +1 -s 0.2 -f "${log_file}" &
    ACTIVE_TAIL_PID=$!
  fi

  wait "${ACTIVE_RUN_PID}" || run_status=$?
  ACTIVE_RUN_PID=""
  if [[ -n "${ACTIVE_TAIL_PID}" ]]; then
    wait "${ACTIVE_TAIL_PID}" 2>/dev/null || true
    ACTIVE_TAIL_PID=""
  fi
  if [[ ${pm_started} -eq 1 ]]; then
    pm_csv_path="${ACTIVE_PM_CSV}"
    stop_pm_logging || true
    if [[ -f "${pm_csv_path}" ]]; then
      pm_record_args=(
        --output "${OUTPUT_DIR}"
        --log "${pm_csv_path}"
        --gpu "${GPU_INDEX}"
      )
      if [[ ${KEEP_PM_LOG} -eq 1 ]]; then
        pm_record_args+=(--keep-log)
      fi
      if ! python3 "${STATE_HELPER}" record-pm "${pm_record_args[@]}"; then
        echo "Could not process PM log; keeping ${pm_csv_path}" >&2
      fi
    else
      echo "PM CSV was not produced: ${pm_csv_path}" >&2
    fi
  fi
  if [[ ${LIVE_OUTPUT} -eq 0 ]]; then
    cat "${log_file}"
  fi
  return "${run_status}"
}

commit_source() {
  local commit="$1"
  local paths
  local changes_stinkytofu=0
  local changes_hipblaslt=0

  paths="$(git -C "${ROCM_REPO}" diff-tree --root -m --no-commit-id \
    --name-only -r "${commit}" -- shared/stinkytofu projects/hipblaslt)"
  [[ "${paths}" == *"shared/stinkytofu/"* ]] && changes_stinkytofu=1
  [[ "${paths}" == *"projects/hipblaslt/"* ]] && changes_hipblaslt=1

  if [[ ${changes_stinkytofu} -eq 1 && ${changes_hipblaslt} -eq 1 ]]; then
    echo "both"
  elif [[ ${changes_stinkytofu} -eq 1 ]]; then
    echo "stinkytofu"
  elif [[ ${changes_hipblaslt} -eq 1 ]]; then
    echo "hipblaslt"
  else
    echo "neither"
  fi
}

commit_matches_component() {
  local source="$1"

  case "${COMPONENT}" in
    stinkytofu)
      [[ "${source}" == "stinkytofu" || "${source}" == "both" ]]
      ;;
    hipblaslt)
      [[ "${source}" == "hipblaslt" || "${source}" == "both" ]]
      ;;
    either)
      [[ "${source}" != "neither" ]]
      ;;
  esac
}

yaml_revision_for_commit() {
  local commit="$1"

  if git -C "${ROCM_REPO}" merge-base --is-ancestor 9a9953849d8 "${commit}"; then
    echo "${HEAD_YAML_REVISION}"
  elif git -C "${ROCM_REPO}" merge-base --is-ancestor f2a6c23df523 "${commit}"; then
    echo "c394e5b"
  else
    echo "2065321"
  fi
}

prepare_no_validation_yaml() {
  local source="$1"
  local destination="$2"
  local temporary="${destination}.tmp"

  mkdir -p "$(dirname -- "${destination}")"
  if ! python3 - "${source}" "${temporary}" <<'PY'
import re
import sys
from pathlib import Path

source = Path(sys.argv[1])
destination = Path(sys.argv[2])
lines = source.read_text(encoding="utf-8").splitlines(keepends=True)
pattern = re.compile(r"^(\s*NumElementsToValidate\s*:\s*)[^#]*(#.*)?$")
found = False

for index, line in enumerate(lines):
    body = line.rstrip("\r\n")
    newline = line[len(body):]
    match = pattern.match(body)
    if match is None:
        continue
    comment = match.group(2)
    lines[index] = match.group(1) + "0" + (f" {comment}" if comment else "") + newline
    found = True

if not found:
    raise SystemExit(f"NumElementsToValidate not found in {source}")

destination.write_text("".join(lines), encoding="utf-8")
PY
  then
    rm -f -- "${temporary}"
    echo "Could not disable validation in YAML: ${source}" >&2
    return 1
  fi
  mv -- "${temporary}" "${destination}"
}

prepare_pm_maf_yaml() {
  local source="$1"
  local destination="$2"
  local temporary="${destination}.tmp"

  mkdir -p "$(dirname -- "${destination}")"
  if ! python3 - "${source}" "${temporary}" <<'PY'
import re
import sys
from pathlib import Path

source = Path(sys.argv[1])
destination = Path(sys.argv[2])
# Keep in sync with PM_MAF_SETTINGS in benchmark-jichang-state.py.
settings = {
    "bbs_tn_maf.yaml": {"NumWarmups": 100, "EnqueuesPerSync": 1000},
    "f8_tn_maf.yaml": {"NumWarmups": 160, "EnqueuesPerSync": 1600},
    "f8_tn_maf_henry.yaml": {"NumWarmups": 160, "EnqueuesPerSync": 1600},
    "mxf4_tn_maf.yaml": {"NumWarmups": 200, "EnqueuesPerSync": 2000},
    "mxf8_tn_maf.yaml": {"NumWarmups": 160, "EnqueuesPerSync": 1600},
    "mxf8_tn_maf_henry.yaml": {"NumWarmups": 160, "EnqueuesPerSync": 1600},
    "nvf4_tn_maf.yaml": {"NumWarmups": 200, "EnqueuesPerSync": 2000},
}
replacement_values = settings.get(source.name)
if replacement_values is None:
    raise SystemExit(f"No PM MAF settings for {source.name}")

lines = source.read_text(encoding="utf-8").splitlines(keepends=True)
found = {key: 0 for key in replacement_values}
for index, line in enumerate(lines):
    body = line.rstrip("\r\n")
    newline = line[len(body):]
    for key, value in replacement_values.items():
        match = re.match(rf"^(\s*{re.escape(key)}\s*:\s*)[^#]*(#.*)?$", body)
        if match is None:
            continue
        comment = match.group(2)
        lines[index] = (
            match.group(1) + str(value)
            + (f" {comment}" if comment else "") + newline
        )
        found[key] += 1
        break

missing_or_duplicate = [key for key, count in found.items() if count != 1]
if missing_or_duplicate:
    raise SystemExit(
        f"Expected exactly one {', '.join(missing_or_duplicate)} in {source}"
    )
destination.write_text("".join(lines), encoding="utf-8")
PY
  then
    rm -f -- "${temporary}"
    echo "Could not prepare PM MAF YAML: ${source}" >&2
    return 1
  fi
  mv -- "${temporary}" "${destination}"
}

warn_if_head_yaml_dirty() {
  local yaml="$1"
  local action="$2"
  local diff_status=0
  local head_short=""

  git -C "${PROJECT_DIR}" diff --quiet "${HEAD_YAML_REVISION}" -- "${yaml}" || diff_status=$?
  if [[ ${diff_status} -gt 1 ]]; then
    echo "Could not compare ${yaml} with HEAD ${HEAD_YAML_REVISION}." >&2
    return 1
  fi
  if [[ ${diff_status} -eq 1 ]]; then
    head_short="$(git -C "${PROJECT_DIR}" rev-parse --short=12 "${HEAD_YAML_REVISION}")"
    echo "Warning: ${yaml} differs from HEAD ${head_short}; ${action}." >&2
  fi
}

prepare_yamls() {
  local revision="$1"
  local yaml
  local destination
  local run_destination
  local no_validation_destination
  local temporary

  for yaml in "${TEST_YAMLS[@]}"; do
    destination="${OUTPUT_DIR}/yamls/${revision}/${yaml#examples/jichang/}"
    if [[ "${revision}" == "${HEAD_YAML_REVISION}" ]]; then
      if [[ -f "${destination}" ]]; then
        if ! warn_if_head_yaml_dirty "${yaml}" "reusing extracted copy ${destination}"; then
          return 1
        fi
      else
        if ! warn_if_head_yaml_dirty "${yaml}" "using the working tree copy"; then
          return 1
        fi
        mkdir -p "$(dirname -- "${destination}")"
        temporary="${destination}.tmp"
        cp -f -- "${PROJECT_DIR}/${yaml}" "${temporary}"
        mv -- "${temporary}" "${destination}"
      fi
    elif [[ ! -f "${destination}" ]]; then
      mkdir -p "$(dirname -- "${destination}")"
      temporary="${destination}.tmp"
      if ! git -C "${PROJECT_DIR}" show "${revision}:${yaml}" > "${temporary}"; then
        rm -f -- "${temporary}"
        echo "Could not load ${yaml} from benchmark revision ${revision}." >&2
        return 1
      fi
      mv -- "${temporary}" "${destination}"
    fi
    run_destination="${destination}"
    if [[ ${PM_LOG_MAF} -eq 1 && "${yaml}" == examples/jichang/maf/* ]]; then
      run_destination="${destination%.yaml}.pm-log-maf.yaml"
      if ! prepare_pm_maf_yaml "${destination}" "${run_destination}"; then
        return 1
      fi
    fi
    if [[ ${NO_VALIDATE} -eq 1 ||
          ( ${VALIDATE_FIRST_ONLY} -eq 1 && ${REPEAT_RUNS} -gt 1 ) ]]; then
      no_validation_destination="${run_destination%.yaml}.no-validation.yaml"
      if ! prepare_no_validation_yaml "${run_destination}" "${no_validation_destination}"; then
        return 1
      fi
    fi
  done
}

ORIGINAL_COMMIT=""
ORIGINAL_BRANCH=""
STASH_OID=""
PATCH_APPLIED=0
RANGE_MODE=0
RESTORED=0
ACTIVE_RUN_PID=""
ACTIVE_TAIL_PID=""
SIGNAL_CLEANUP=0

# Git checkout may invoke credential, SSH, or LFS helpers. Unattended runs must
# fail instead of stopping to read from a terminal.
export GIT_TERMINAL_PROMPT=0
export GCM_INTERACTIVE=Never
export GIT_ASKPASS=/bin/false
if [[ -z "${GIT_SSH_COMMAND:-}" ]]; then
  export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=yes"
fi

terminate_active_run() {
  # Stop the logger before the workload. The workload wait is several seconds,
  # and a second Ctrl+C during it used to exit before agt_internal was signaled.
  if [[ -n "${ACTIVE_PM_PID}" ]]; then
    stop_pm_logging || true
  fi
  if [[ -n "${ACTIVE_RUN_PID}" ]]; then
    kill -TERM -- "-${ACTIVE_RUN_PID}" 2>/dev/null || true
    sleep 5
    if kill -0 -- "-${ACTIVE_RUN_PID}" 2>/dev/null; then
      kill -KILL -- "-${ACTIVE_RUN_PID}" 2>/dev/null || true
    fi
    wait "${ACTIVE_RUN_PID}" 2>/dev/null || true
    ACTIVE_RUN_PID=""
  fi
  if [[ -n "${ACTIVE_TAIL_PID}" ]]; then
    kill -KILL "${ACTIVE_TAIL_PID}" 2>/dev/null || true
    wait "${ACTIVE_TAIL_PID}" 2>/dev/null || true
    ACTIVE_TAIL_PID=""
  fi
}

handle_signal() {
  local status="$1"
  [[ ${SIGNAL_CLEANUP} -eq 0 ]] || return 0
  SIGNAL_CLEANUP=1
  trap '' HUP INT TERM TSTP
  terminate_active_run
  exit "${status}"
}

session_get() {
  python3 "${STATE_HELPER}" session --output "${OUTPUT_DIR}" get --field "$1"
}

session_set() {
  python3 "${STATE_HELPER}" session --output "${OUTPUT_DIR}" set "$@" || exit 1
}

normalize_interrupted_session() {
  [[ -f "${OUTPUT_DIR}/git-session.json" ]] || return 0
  ORIGINAL_COMMIT="$(session_get original_commit)"
  ORIGINAL_BRANCH="$(session_get original_branch)"
  STASH_OID="$(session_get stash_oid)"
  if [[ "${STASH_OID}" == "pending" ]]; then
    stash_subject="$(git -C "${ROCM_REPO}" log -1 --format=%s refs/stash 2>/dev/null || true)"
    if [[ "${stash_subject}" == *"benchmark-jichang-commits automatic stash"* ]]; then
      STASH_OID="$(git -C "${ROCM_REPO}" rev-parse refs/stash)"
      session_set --stash-oid "${STASH_OID}"
    else
      echo "An interrupted automatic stash could not be identified safely; inspect ${ROCM_REPO}." >&2
      exit 1
    fi
  fi
  session_set --applied-commit "" --applied-diff-hash ""
}

restore_repository() {
  [[ ${RANGE_MODE} -eq 1 && ${RESTORED} -eq 0 ]] || return 0
  RESTORED=1
  trap - EXIT
  set +e

  if [[ ${PATCH_APPLIED} -eq 1 ]]; then
    git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null || return 1
    PATCH_APPLIED=0
  fi

  if [[ -n "${ORIGINAL_BRANCH}" ]]; then
    timeout --signal=TERM --kill-after=10s 10m \
      git -C "${ROCM_REPO}" checkout "${ORIGINAL_BRANCH}" \
      </dev/null >/dev/null || return 1
  else
    timeout --signal=TERM --kill-after=10s 10m \
      git -C "${ROCM_REPO}" checkout --detach "${ORIGINAL_COMMIT}" \
      </dev/null >/dev/null || return 1
  fi

  if [[ -n "${STASH_OID}" ]]; then
    if git -C "${ROCM_REPO}" stash apply "${STASH_OID}"; then
      if [[ "$(git -C "${ROCM_REPO}" rev-parse -q --verify refs/stash 2>/dev/null)" == "${STASH_OID}" ]]; then
        git -C "${ROCM_REPO}" stash drop stash@{0} >/dev/null
      else
        echo "Original changes restored, but their stash was not dropped: ${STASH_OID}" >&2
      fi
    else
      echo "WARNING: Could not reapply the original changes." >&2
      echo "They remain available in stash commit ${STASH_OID}." >&2
      return 1
    fi
  fi
  python3 "${STATE_HELPER}" session --output "${OUTPUT_DIR}" clear
}

COMMITS=()
if [[ -n "${START_COMMIT}" || ${#SELECTED_COMMITS[@]} -gt 0 ]]; then
  RANGE_MODE=1
  if [[ -f "${OUTPUT_DIR}/git-session.json" ]]; then
    normalize_interrupted_session
    if [[ -n "${STASH_OID}" ]] &&
       ! git -C "${ROCM_REPO}" cat-file -e "${STASH_OID}^{commit}" 2>/dev/null; then
      echo "Saved automatic stash no longer exists: ${STASH_OID}" >&2
      exit 1
    fi
  else
    ORIGINAL_COMMIT="$(git -C "${ROCM_REPO}" rev-parse HEAD)"
    ORIGINAL_BRANCH="$(git -C "${ROCM_REPO}" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
  fi

  COMMITS=()
  if [[ ${#SELECTED_COMMITS[@]} -gt 0 ]]; then
    for commit_ref in "${SELECTED_COMMITS[@]}"; do
      if ! resolved_commit="$(git -C "${ROCM_REPO}" rev-parse --verify "${commit_ref}^{commit}")"; then
        echo "Invalid commit: ${commit_ref}" >&2
        exit 2
      fi
      for existing_commit in "${COMMITS[@]}"; do
        if [[ "${existing_commit}" == "${resolved_commit}" ]]; then
          echo "Duplicate commit: ${commit_ref}" >&2
          exit 2
        fi
      done
      COMMITS+=("${resolved_commit}")
    done
  else
    if ! START_COMMIT="$(git -C "${ROCM_REPO}" rev-parse --verify "${START_COMMIT}^{commit}")"; then
      echo "Invalid start commit." >&2
      exit 2
    fi
    if ! END_COMMIT="$(git -C "${ROCM_REPO}" rev-parse --verify "${END_COMMIT}^{commit}")"; then
      echo "Invalid end commit." >&2
      exit 2
    fi
    if ! git -C "${ROCM_REPO}" merge-base --is-ancestor "${START_COMMIT}" "${END_COMMIT}"; then
      echo "Start commit is not an ancestor of end commit." >&2
      exit 2
    fi

    if commit_matches_component "$(commit_source "${START_COMMIT}")"; then
      COMMITS+=("${START_COMMIT}")
    fi
    case "${COMPONENT}" in
      stinkytofu)
        COMPONENT_PATHS=(shared/stinkytofu)
        ;;
      hipblaslt)
        COMPONENT_PATHS=(projects/hipblaslt)
        ;;
      either)
        COMPONENT_PATHS=(shared/stinkytofu projects/hipblaslt)
        ;;
    esac
    while IFS= read -r commit; do
      [[ -n "${commit}" ]] && COMMITS+=("${commit}")
    done < <(
      git -C "${ROCM_REPO}" rev-list --reverse --ancestry-path \
        "${START_COMMIT}..${END_COMMIT}" -- "${COMPONENT_PATHS[@]}"
    )

    if [[ ${#COMMITS[@]} -eq 0 ]]; then
      echo "No ${COMPONENT} commits found in the requested range." >&2
      exit 2
    fi
  fi

  if [[ ! -f "${OUTPUT_DIR}/git-session.json" ]]; then
    session_set --original-commit "${ORIGINAL_COMMIT}" --original-branch "${ORIGINAL_BRANCH}"
  fi
  if [[ -z "${STASH_OID}" ]] &&
     { ! git -C "${ROCM_REPO}" diff --quiet ||
       ! git -C "${ROCM_REPO}" diff --cached --quiet; }; then
    echo "Stashing tracked changes in ${ROCM_REPO}"
    session_set --stash-oid pending
    if ! git -C "${ROCM_REPO}" stash push -m "benchmark-jichang-commits automatic stash"; then
      session_set --stash-oid ""
      echo "Failed to stash repository changes." >&2
      exit 1
    fi
    STASH_OID="$(git -C "${ROCM_REPO}" rev-parse refs/stash)"
    session_set --stash-oid "${STASH_OID}"
  fi

  trap restore_repository EXIT
else
  if [[ -f "${OUTPUT_DIR}/git-session.json" ]]; then
    echo "This output directory has an interrupted managed Git session." >&2
    echo "Resume with the original --commit or --start/--end options." >&2
    exit 1
  fi
  COMMITS=("$(git -C "${ROCM_REPO}" rev-parse HEAD)")
fi

trap 'handle_signal 129' HUP
trap 'handle_signal 130' INT
trap 'handle_signal 143' TERM
trap 'handle_signal 148' TSTP

plan_args=()
for commit in "${COMMITS[@]}"; do
  plan_args+=(--commit "${commit}")
done
for test_name in "${TEST_NAMES[@]}"; do
  plan_args+=(--test "${test_name}")
done
python3 "${STATE_HELPER}" plan --output "${OUTPUT_DIR}" "${plan_args[@]}" || exit 1

# Materialize the full matrix before executing anything. A SIGKILL therefore
# leaves every selected pair either running, completed, or explicitly missing.
for commit in "${COMMITS[@]}"; do
  short_commit="$(git -C "${ROCM_REPO}" rev-parse --short=12 "${commit}")"
  source="$(commit_source "${commit}")"
  yaml_revision="$(yaml_revision_for_commit "${commit}")"
  for index in "${!TEST_NAMES[@]}"; do
    test_name="${TEST_NAMES[${index}]}"
    test_category="${TEST_YAMLS[${index}]#examples/jichang/}"
    test_category="${test_category%%/*}"
    if [[ "${test_category}" == "mab" ]]; then
      score_metric="gbps-bandwidth"
      score_unit="GB/s"
    else
      score_metric="gflops"
      score_unit="PFLOPS"
    fi
    python3 "${STATE_HELPER}" ensure --state "${RUN_STATE}" \
      --commit "${commit}" --short "${short_commit}" --source "${source}" \
      --yaml-revision "${yaml_revision}" --test "${test_name}" \
      --yaml "${TEST_YAMLS[${index}]}" --metric "${score_metric}" --unit "${score_unit}" ||
      exit 1
  done
done
regenerate_reports
python3 "${STATE_HELPER}" compare-asm --output "${OUTPUT_DIR}" || exit 1
regenerate_reports

die_if_interrupted() {
  local status="$1"
  local test_name="$2"
  if [[ ${status} -eq 124 || ${status} -eq 137 || ${status} -eq 129 ||
        ${status} -eq 130 || ${status} -eq 143 || ${status} -eq 148 ]]; then
    echo "${test_name}: interrupted or timed out; task remains pending" >&2
    exit "${status}"
  fi
}

task_pending() {
  local commit="$1"
  local test_name="$2"
  local answer
  answer="$(python3 "${STATE_HELPER}" pending --state "${RUN_STATE}" \
    --commit "${commit}" --test "${test_name}")" || exit 1
  [[ "${answer}" == "yes" ]]
}

commit_has_pending() {
  local commit="$1"
  local test_name
  for test_name in "${TEST_NAMES[@]}"; do
    if task_pending "${commit}" "${test_name}"; then
      return 0
    fi
  done
  return 1
}

yaml_for_test() {
  local revision="$1"
  local catalog="$2"
  local drop_validation="$3"
  local category="${catalog#examples/jichang/}"
  local path="${OUTPUT_DIR}/yamls/${revision}/${catalog#examples/jichang/}"
  category="${category%%/*}"
  if [[ ${PM_LOG_MAF} -eq 1 && "${category}" == "maf" ]]; then
    path="${path%.yaml}.pm-log-maf.yaml"
  fi
  if [[ "${drop_validation}" == "1" ]]; then
    path="${path%.yaml}.no-validation.yaml"
  fi
  printf '%s\n' "${path}"
}

kernels_ready() {
  local kernel_dir="$1"
  local yaml_file="$2"
  local base found
  base="$(basename "${yaml_file}" .yaml)"
  # --build-only writes ClientParameters.ini and does not write run.sh.
  # run.sh appears only when Tensile actually launches the client.
  found="$(find "${kernel_dir}/${base}.out/1_BenchmarkProblems" \
    \( -path '*/build/run.sh' -o -name 'ClientParameters.ini' \) \
    -type f -print -quit 2>/dev/null || true)"
  [[ -n "${found}" ]]
}

prepare_commit_checkout() {
  local commit="$1"
  local short_commit="$2"
  local setup_log

  [[ ${RANGE_MODE} -eq 1 ]] || return 0
  if [[ ${PATCH_APPLIED} -eq 1 ]]; then
    git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
    PATCH_APPLIED=0
  fi
  mkdir -p -- "${OUTPUT_DIR}/logs/${short_commit}"
  setup_log="${OUTPUT_DIR}/logs/${short_commit}/git-setup.log"
  if ! timeout --signal=TERM --kill-after=10s 10m \
       git -C "${ROCM_REPO}" checkout --detach "${commit}" \
       </dev/null >"${setup_log}" 2>&1; then
    echo "Git checkout failed for ${short_commit}; tasks remain not run." >&2
    cat "${setup_log}" >&2
    return 1
  fi
  if [[ -n "${PATCH_FILE}" ]]; then
    if ! timeout --signal=TERM --kill-after=10s 10m \
         git -C "${ROCM_REPO}" apply --3way --whitespace=nowarn "${PATCH_FILE}" \
         </dev/null >>"${setup_log}" 2>&1; then
      echo "Git patch apply failed for ${short_commit}; tasks remain not run." >&2
      cat "${setup_log}" >&2
      git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
      return 1
    fi
    PATCH_APPLIED=1
  fi
}

copy_commit_codebase() {
  local commit="$1"
  local short_commit="$2"
  local dest="${OUTPUT_DIR}/codebases/${short_commit}"
  local have patch

  mkdir -p -- "${OUTPUT_DIR}/codebases"
  if [[ -d "${dest}" ]]; then
    have="$(git -C "${dest}" rev-parse HEAD 2>/dev/null || true)"
    if [[ "${have}" != "${commit}" ]]; then
      echo "Existing codebase ${dest} is ${have:-not a checkout}, expected ${commit}." >&2
      return 1
    fi
  else
    echo "Copying ${short_commit} to ${dest}"
    # A previous run can leave the path registered after the directory is gone.
    git -C "${ROCM_REPO}" worktree prune
    if ! git -C "${ROCM_REPO}" worktree add --detach "${dest}" "${commit}"; then
      if ! git -C "${ROCM_REPO}" worktree add --force --detach "${dest}" "${commit}"; then
        echo "Could not copy codebase for ${short_commit}." >&2
        return 1
      fi
    fi
  fi
  if [[ -n "${PATCH_FILE}" && ! -f "${dest}/.benchmark-patch-applied" ]]; then
    patch="${PATCH_FILE}"
    if [[ "${patch}" != /* ]]; then
      patch="$(readlink -f -- "${patch}")"
    fi
    if ! git -C "${dest}" apply --3way --whitespace=nowarn "${patch}"; then
      echo "Git patch apply failed in codebase ${dest}." >&2
      return 1
    fi
    touch -- "${dest}/.benchmark-patch-applied"
  fi
}

build_saved_yaml() {
  local yaml_file="$1"
  local kernel_dir="$2"
  local log_file="$3"
  local test_name="$4"
  local run_status=0

  if kernels_ready "${kernel_dir}" "${yaml_file}"; then
    echo "--- ${test_name}: kernels already built ($(basename "${yaml_file}"))"
    return 0
  fi
  mkdir -p -- "${kernel_dir}" "$(dirname -- "${log_file}")"
  echo "--- ${test_name}: building $(basename "${yaml_file}")"
  run_yaml "${yaml_file}" "${log_file}" build-only \
    --run-dir "${kernel_dir}" --keep-container-out || run_status=$?
  die_if_interrupted "${run_status}" "${test_name}"
  if [[ ${run_status} -ne 0 ]] || ! kernels_ready "${kernel_dir}" "${yaml_file}"; then
    echo "--- ${test_name}: kernel build failed" >&2
    return 1
  fi
}

record_build_failure() {
  local commit="$1"
  local test_name="$2"
  local build_log="$3"
  local asm_dir="$4"
  local start_result asm_status

  start_result="$(python3 "${STATE_HELPER}" start --state "${RUN_STATE}" \
    --commit "${commit}" --test "${test_name}")" || exit 1
  if [[ "${start_result}" == "skip" ]]; then
    return 0
  fi
  if [[ -n "${build_log}" && -f "${build_log}" ]]; then
    mkdir -p -- "$(dirname -- "${OUTPUT_DIR}/${start_result}")"
    cp -- "${build_log}" "${OUTPUT_DIR}/${start_result}"
  fi
  asm_status="missing"
  if [[ -d "${asm_dir}/st" ]]; then
    asm_status="cached"
  fi
  finish_task "${commit}" "${test_name}" "execution-failed" 0 \
    "${asm_status}" "kernel build failed"
}

measure_saved_run() {
  local commit="$1"
  local short_commit="$2"
  local test_name="$3"
  local yaml="$4"
  local kernel_dir="$5"
  local attempt_log="$6"
  local run_index="$7"
  local score_metric="$8"
  local score_unit="$9"
  local log_file run_yaml_file run_status
  local sample_score sample_time_us sample_status sample_result

  if [[ ${run_index} -eq 1 ]]; then
    log_file="${OUTPUT_DIR}/${attempt_log}"
  else
    log_file="${OUTPUT_DIR}/${attempt_log%.log}.run-${run_index}.log"
  fi
  run_yaml_file="${yaml}"
  if [[ ${NO_VALIDATE} -eq 1 ||
        ( ${VALIDATE_FIRST_ONLY} -eq 1 && ${run_index} -gt 1 ) ]]; then
    run_yaml_file="${yaml%.yaml}.no-validation.yaml"
  fi
  mkdir -p -- "$(dirname -- "${log_file}")"
  echo "--- ${short_commit} ${test_name}: run ${run_index}/${REPEAT_RUNS}"
  run_status=0
  run_yaml "${run_yaml_file}" "${log_file}" reuse \
    --run-dir "${kernel_dir}" --keep-container-out || run_status=$?
  die_if_interrupted "${run_status}" "${test_name}"

  sample_score=""
  sample_time_us=""
  sample_status="execution-failed"
  if sample_result="$(extract_best_result "${log_file}" "${score_metric}")"; then
    IFS=$'\t' read -r sample_score sample_time_us <<< "${sample_result}"
    if [[ "${sample_score}" == *"*" ]]; then
      sample_status="validation-failed"
    elif [[ ${run_status} -eq 0 ]]; then
      sample_status="passed"
    fi
  fi

  python3 "${STATE_HELPER}" record-sample --output "${OUTPUT_DIR}" \
    --commit "${commit}" --test "${test_name}" --run "${run_index}" \
    --status "${sample_status}" --score "${sample_score}" \
    --time-us "${sample_time_us}" || exit 1

  if [[ -n "${sample_score}" ]]; then
    if [[ -n "${sample_time_us}" ]]; then
      echo "${short_commit} ${test_name}: run ${run_index} = ${sample_score} ${score_unit}, ${sample_time_us} us"
    else
      echo "${short_commit} ${test_name}: run ${run_index} = ${sample_score} ${score_unit}"
    fi
  else
    echo "${short_commit} ${test_name}: run ${run_index} produced no finite score" >&2
  fi
  return "${run_status}"
}

finish_saved_yaml() {
  local commit="$1"
  local short_commit="$2"
  local test_name="$3"
  local kernel_dir="$4"
  local score_metric="$5"
  local score_unit="$6"
  local failed_runs="$7"
  local asm_status asm_message
  local stats_line measured_count average best worst standard_deviation
  local best_score validation_failures sample_failures terminal_status message

  asm_status="missing"
  asm_message=""
  if [[ -d "${OUTPUT_DIR}/asm/${short_commit}/${test_name}/st" ]]; then
    asm_status="cached"
  else
    asm_message="generated st ASM could not be cached"
  fi

  stats_line="$(python3 "${STATE_HELPER}" sample-stats \
    --output "${OUTPUT_DIR}" --commit "${commit}" --test "${test_name}")" || exit 1
  IFS=$'\t' read -r measured_count average best worst standard_deviation \
    best_score validation_failures sample_failures <<< "${stats_line}"
  if [[ ${measured_count} -eq 0 ]]; then
    finish_task "${commit}" "${test_name}" "execution-failed" 0 \
      "${asm_status}" "no finite ${score_metric} value found in ${REPEAT_RUNS} run(s)"
    rm -rf -- "${kernel_dir}"
    return 0
  fi
  terminal_status="passed"
  message="${measured_count}/${REPEAT_RUNS} run(s) produced finite scores"
  if [[ ${validation_failures} -gt 0 ]]; then
    terminal_status="validation-failed"
    message="${message}; ${validation_failures} validation-failed run(s)"
  elif [[ ${failed_runs} -gt 0 ]]; then
    terminal_status="execution-failed"
    message="${message}; ${failed_runs} run(s) failed"
  fi
  if [[ -n "${asm_message}" ]]; then
    message="${message}; ${asm_message}"
  fi
  echo "${short_commit} ${test_name}: best=${best_score}, average=${average}, worst=${worst}, SD=${standard_deviation} ${score_unit}"
  finish_task "${commit}" "${test_name}" "${terminal_status}" "${best_score}" \
    "${asm_status}" "${message}"
  rm -rf -- "${kernel_dir}"
}

build_one_commit() {
  local commit_index="$1"
  local commit="${COMMITS[${commit_index}]}"
  local short_commit source yaml_revision index test_name catalog yaml
  local kernel_dir commit_log_dir commit_asm_dir previous_commit
  local previous_short_commit previous_asm_dir variant build_log failed
  local primary_log preflight_log preflight_asm_dir asm_match needs_build

  short_commit="$(git -C "${ROCM_REPO}" rev-parse --short=12 "${commit}")"
  if ! commit_has_pending "${commit}"; then
    echo "${short_commit}: all YAMLs already completed; skipping build"
    return 0
  fi
  source="$(commit_source "${commit}")"
  yaml_revision="$(yaml_revision_for_commit "${commit}")"
  echo
  echo "===== Building ${short_commit} (${source}; YAML revision ${yaml_revision}) ====="
  if ! prepare_yamls "${yaml_revision}"; then
    echo "YAML preparation failed for ${short_commit}; tasks remain not run." >&2
    return 1
  fi
  needs_build=0
  for index in "${!TEST_NAMES[@]}"; do
    test_name="${TEST_NAMES[${index}]}"
    if ! task_pending "${commit}" "${test_name}"; then
      continue
    fi
    catalog="${TEST_YAMLS[${index}]}"
    yaml="$(yaml_for_test "${yaml_revision}" "${catalog}" 0)"
    kernel_dir="${OUTPUT_DIR}/kernels/${short_commit}/${test_name}"
    if [[ ${SKIP_IDENTICAL_ASM} -eq 1 && ${commit_index} -gt 0 ]]; then
      previous_short_commit="$(git -C "${ROCM_REPO}" rev-parse --short=12 \
        "${COMMITS[$((commit_index - 1))]}")"
      if [[ -d "${OUTPUT_DIR}/asm/${previous_short_commit}/${test_name}/st" ]] &&
         ! kernels_ready "${kernel_dir}" "${yaml}"; then
        needs_build=1
      fi
    fi
    if [[ ${NO_VALIDATE} -eq 1 ]]; then
      if ! kernels_ready "${kernel_dir}" "${yaml%.yaml}.no-validation.yaml"; then
        needs_build=1
      fi
    else
      if ! kernels_ready "${kernel_dir}" "${yaml}"; then
        needs_build=1
      fi
      if [[ ${VALIDATE_FIRST_ONLY} -eq 1 && ${REPEAT_RUNS} -gt 1 ]] &&
         ! kernels_ready "${kernel_dir}" "${yaml%.yaml}.no-validation.yaml"; then
        needs_build=1
      fi
    fi
  done
  if [[ ${needs_build} -eq 1 ]]; then
    if ! prepare_commit_checkout "${commit}" "${short_commit}"; then
      return 1
    fi
  else
    echo "${short_commit}: kernels already built; leaving the repository checkout unchanged"
  fi

  commit_log_dir="${OUTPUT_DIR}/logs/${short_commit}"
  mkdir -p -- "${commit_log_dir}"
  commit_asm_dir="${OUTPUT_DIR}/asm/${short_commit}"
  previous_commit=""
  previous_short_commit=""
  previous_asm_dir=""
  if [[ ${SKIP_IDENTICAL_ASM} -eq 1 && ${commit_index} -gt 0 ]]; then
    previous_commit="${COMMITS[$((commit_index - 1))]}"
    previous_short_commit="$(git -C "${ROCM_REPO}" rev-parse --short=12 "${previous_commit}")"
    previous_asm_dir="${OUTPUT_DIR}/asm/${previous_short_commit}"
  fi

  for index in "${!TEST_NAMES[@]}"; do
    test_name="${TEST_NAMES[${index}]}"
    catalog="${TEST_YAMLS[${index}]}"
    if ! task_pending "${commit}" "${test_name}"; then
      continue
    fi
    yaml="$(yaml_for_test "${yaml_revision}" "${catalog}" 0)"
    kernel_dir="${OUTPUT_DIR}/kernels/${short_commit}/${test_name}"

    if [[ -n "${previous_commit}" && -d "${previous_asm_dir}/${test_name}/st" ]]; then
      preflight_log="${commit_log_dir}/${test_name}.asm-check.log"
      echo "--- ${test_name}: checking generated ASM against ${previous_short_commit}"
      if ! build_saved_yaml "${yaml}" "${kernel_dir}" "${preflight_log}" "${test_name}"; then
        record_build_failure "${commit}" "${test_name}" "${preflight_log}" \
          "${commit_asm_dir}/${test_name}"
        continue
      fi
      preflight_asm_dir="${commit_asm_dir}/${test_name}/st"
      if [[ ! -d "${preflight_asm_dir}" ]]; then
        cache_generated_asm "${preflight_log}" "${preflight_asm_dir}" || true
      fi
      if [[ -d "${preflight_asm_dir}" ]]; then
        asm_match="$(python3 "${STATE_HELPER}" asm-status \
          --left "${previous_asm_dir}/${test_name}/st" \
          --right "${preflight_asm_dir}")" || return 1
        if [[ "${asm_match}" == "yes" ]]; then
          if python3 "${STATE_HELPER}" reuse --state "${RUN_STATE}" \
               --source-commit "${previous_commit}" --target-commit "${commit}" \
               --test "${test_name}" \
               --message "ASM identical to ${previous_short_commit}; reused its score"; then
            rm -rf -- "${preflight_asm_dir}"
            mkdir -p -- "$(dirname -- "${preflight_asm_dir}")"
            cp -a -- "${previous_asm_dir}/${test_name}/st" "${preflight_asm_dir}"
            rm -rf -- "${kernel_dir}"
            echo "${test_name}: ASM identical; reused ${previous_short_commit} score"
            continue
          fi
        fi
      fi
    fi

    failed=0
    primary_log=""
    while IFS= read -r variant; do
      build_log="${commit_log_dir}/${test_name}.$(basename "${variant}" .yaml).build.log"
      if [[ -z "${primary_log}" ]]; then
        primary_log="${build_log}"
      fi
      if ! build_saved_yaml "${variant}" "${kernel_dir}" "${build_log}" "${test_name}"; then
        failed=1
        break
      fi
    done < <(
      if [[ ${NO_VALIDATE} -eq 1 ]]; then
        printf '%s\n' "${yaml%.yaml}.no-validation.yaml"
      else
        printf '%s\n' "${yaml}"
        if [[ ${VALIDATE_FIRST_ONLY} -eq 1 && ${REPEAT_RUNS} -gt 1 ]]; then
          printf '%s\n' "${yaml%.yaml}.no-validation.yaml"
        fi
      fi
    )
    if [[ ${failed} -eq 1 ]]; then
      record_build_failure "${commit}" "${test_name}" "${build_log}" \
        "${commit_asm_dir}/${test_name}"
      continue
    fi
    if [[ ! -d "${commit_asm_dir}/${test_name}/st" && -n "${primary_log}" ]]; then
      cache_generated_asm "${primary_log}" "${commit_asm_dir}/${test_name}/st" || true
    fi
  done
}

run_grouped_commits() {
  local commit_index commit short_commit index test_name catalog
  local yaml_revision yaml kernel_dir score_metric score_unit
  local start_result run_index slot
  local active_commits active_short_commits active_yamls active_kernel_dirs
  local active_logs active_failed_runs

  echo
  echo "===== Copying a codebase for each commit ====="
  for commit_index in "${!COMMITS[@]}"; do
    commit="${COMMITS[${commit_index}]}"
    short_commit="$(git -C "${ROCM_REPO}" rev-parse --short=12 "${commit}")"
    if ! commit_has_pending "${commit}"; then
      echo "${short_commit}: all YAMLs already completed; not copying"
      continue
    fi
    copy_commit_codebase "${commit}" "${short_commit}" || exit 1
  done

  echo
  echo "===== Building kernels for every commit ====="
  for commit_index in "${!COMMITS[@]}"; do
    build_one_commit "${commit_index}" || exit 1
  done

  echo
  echo "===== Running each YAML across commits ====="
  for index in "${!TEST_NAMES[@]}"; do
    test_name="${TEST_NAMES[${index}]}"
    catalog="${TEST_YAMLS[${index}]}"
    if [[ "${catalog#examples/jichang/}" == mab/* ]]; then
      score_metric="gbps-bandwidth"
      score_unit="GB/s"
    else
      score_metric="gflops"
      score_unit="PFLOPS"
    fi
    echo
    echo "===== ${test_name} across ${#COMMITS[@]} commits ====="
    active_commits=()
    active_short_commits=()
    active_yamls=()
    active_kernel_dirs=()
    active_logs=()
    active_failed_runs=()
    for commit_index in "${!COMMITS[@]}"; do
      commit="${COMMITS[${commit_index}]}"
      if ! task_pending "${commit}" "${test_name}"; then
        continue
      fi
      short_commit="$(git -C "${ROCM_REPO}" rev-parse --short=12 "${commit}")"
      yaml_revision="$(yaml_revision_for_commit "${commit}")"
      yaml="$(yaml_for_test "${yaml_revision}" "${catalog}" 0)"
      kernel_dir="${OUTPUT_DIR}/kernels/${short_commit}/${test_name}"
      if ! kernels_ready "${kernel_dir}" "${yaml}" &&
         ! kernels_ready "${kernel_dir}" "${yaml%.yaml}.no-validation.yaml"; then
        record_build_failure "${commit}" "${test_name}" "" \
          "${OUTPUT_DIR}/asm/${short_commit}/${test_name}"
        continue
      fi
      start_result="$(python3 "${STATE_HELPER}" start --state "${RUN_STATE}" \
        --commit "${commit}" --test "${test_name}")" || exit 1
      if [[ "${start_result}" == "skip" ]]; then
        echo "--- ${short_commit} ${test_name}: already completed, skipping"
        continue
      fi
      active_commits+=("${commit}")
      active_short_commits+=("${short_commit}")
      active_yamls+=("${yaml}")
      active_kernel_dirs+=("${kernel_dir}")
      active_logs+=("${start_result}")
      active_failed_runs+=(0)
    done

    for ((run_index = 1; run_index <= REPEAT_RUNS; run_index++)); do
      for slot in "${!active_commits[@]}"; do
        if ! measure_saved_run "${active_commits[${slot}]}" \
             "${active_short_commits[${slot}]}" "${test_name}" \
             "${active_yamls[${slot}]}" "${active_kernel_dirs[${slot}]}" \
             "${active_logs[${slot}]}" "${run_index}" \
             "${score_metric}" "${score_unit}"; then
          active_failed_runs[${slot}]=$((active_failed_runs[slot] + 1))
        fi
      done
    done

    for slot in "${!active_commits[@]}"; do
      finish_saved_yaml "${active_commits[${slot}]}" \
        "${active_short_commits[${slot}]}" "${test_name}" \
        "${active_kernel_dirs[${slot}]}" "${score_metric}" "${score_unit}" \
        "${active_failed_runs[${slot}]}"
    done
  done
}

if [[ ${#COMMITS[@]} -gt 1 ]]; then
  run_grouped_commits
else
for commit_index in "${!COMMITS[@]}"; do
  commit="${COMMITS[${commit_index}]}"
  short_commit="$(git -C "${ROCM_REPO}" rev-parse --short=12 "${commit}")"
  source="$(commit_source "${commit}")"
  yaml_revision="$(yaml_revision_for_commit "${commit}")"
  echo
  echo "===== Testing ${short_commit} (${source}; YAML revision ${yaml_revision}) ====="

  pending_args=()
  for test_name in "${TEST_NAMES[@]}"; do
    pending_args+=(--test "${test_name}")
  done
  commit_pending="$(python3 "${STATE_HELPER}" pending \
    --state "${RUN_STATE}" --commit "${commit}" "${pending_args[@]}")" || exit 1
  if [[ "${commit_pending}" == "no" ]]; then
    echo "All selected YAMLs already completed; skipping commit."
    continue
  fi

  if [[ ${RANGE_MODE} -eq 1 ]]; then
    if [[ ${PATCH_APPLIED} -eq 1 ]]; then
      git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
      PATCH_APPLIED=0
    fi

    commit_log_dir="${OUTPUT_DIR}/logs/${short_commit}"
    mkdir -p "${commit_log_dir}"
    setup_log="${commit_log_dir}/git-setup.log"
    if ! timeout --signal=TERM --kill-after=10s 10m \
         git -C "${ROCM_REPO}" checkout --detach "${commit}" \
         </dev/null >"${setup_log}" 2>&1; then
      echo "Git checkout failed for ${short_commit}; tasks remain not run." >&2
      cat "${setup_log}" >&2
      exit 1
    fi

    if [[ -n "${PATCH_FILE}" ]]; then
      if ! timeout --signal=TERM --kill-after=10s 10m \
           git -C "${ROCM_REPO}" apply --3way --whitespace=nowarn "${PATCH_FILE}" \
           </dev/null >>"${setup_log}" 2>&1; then
        echo "Git patch apply failed for ${short_commit}; tasks remain not run." >&2
        cat "${setup_log}" >&2
        git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
        exit 1
      fi
      PATCH_APPLIED=1
    fi
  fi

  if ! prepare_yamls "${yaml_revision}"; then
    echo "YAML preparation failed for ${short_commit}; tasks remain not run." >&2
    exit 1
  fi

  commit_log_dir="${OUTPUT_DIR}/logs/${short_commit}"
  mkdir -p "${commit_log_dir}"
  commit_asm_dir="${OUTPUT_DIR}/asm/${short_commit}"
  previous_commit=""
  previous_short_commit=""
  previous_asm_dir=""
  if [[ ${SKIP_IDENTICAL_ASM} -eq 1 && ${commit_index} -gt 0 ]]; then
    previous_commit="${COMMITS[$((commit_index - 1))]}"
    previous_short_commit="$(git -C "${ROCM_REPO}" rev-parse --short=12 "${previous_commit}")"
    previous_asm_dir="${OUTPUT_DIR}/asm/${previous_short_commit}"
  fi

  for index in "${!TEST_NAMES[@]}"; do
    test_name="${TEST_NAMES[${index}]}"
    yaml="${OUTPUT_DIR}/yamls/${yaml_revision}/${TEST_YAMLS[${index}]#examples/jichang/}"
    test_category="${TEST_YAMLS[${index}]#examples/jichang/}"
    test_category="${test_category%%/*}"
    if [[ ${PM_LOG_MAF} -eq 1 && "${test_category}" == "maf" ]]; then
      yaml="${yaml%.yaml}.pm-log-maf.yaml"
    fi
    if [[ "${test_category}" == "mab" ]]; then
      score_metric="gbps-bandwidth"
      score_unit="GB/s"
    else
      score_metric="gflops"
      score_unit="PFLOPS"
    fi

    start_result="$(python3 "${STATE_HELPER}" start --state "${RUN_STATE}" \
      --commit "${commit}" --test "${test_name}")" || exit 1
    if [[ "${start_result}" == "skip" ]]; then
      echo "--- ${test_name}: already completed, skipping"
      continue
    fi

    if [[ -n "${previous_commit}" &&
          -d "${previous_asm_dir}/${test_name}/st" ]]; then
      preflight_log="${commit_log_dir}/${test_name}.asm-check.log"
      echo "--- ${test_name}: checking generated ASM against ${previous_short_commit}"
      preflight_status=0
      run_yaml "${yaml}" "${preflight_log}" build-only || preflight_status=$?
      if [[ ${preflight_status} -eq 124 || ${preflight_status} -eq 137 ||
            ${preflight_status} -eq 129 || ${preflight_status} -eq 130 ||
            ${preflight_status} -eq 143 || ${preflight_status} -eq 148 ]]; then
        echo "${test_name}: ASM check interrupted or timed out; task remains pending" >&2
        exit "${preflight_status}"
      fi

      preflight_asm_dir="${commit_asm_dir}/${test_name}/st"
      if [[ ${preflight_status} -eq 0 ]] &&
         cache_generated_asm "${preflight_log}" "${preflight_asm_dir}"; then
        asm_match="$(python3 "${STATE_HELPER}" asm-status \
          --left "${previous_asm_dir}/${test_name}/st" \
          --right "${preflight_asm_dir}")" || exit 1
        if [[ "${asm_match}" == "yes" ]]; then
          if python3 "${STATE_HELPER}" reuse --state "${RUN_STATE}" \
               --source-commit "${previous_commit}" --target-commit "${commit}" \
               --test "${test_name}" \
               --message "ASM identical to ${previous_short_commit}; reused its score"; then
            rm -rf -- "${preflight_asm_dir}"
            mkdir -p -- "$(dirname -- "${preflight_asm_dir}")"
            cp -a -- "${previous_asm_dir}/${test_name}/st" "${preflight_asm_dir}"
            echo "${test_name}: ASM identical; reused ${previous_short_commit} score"
            continue
          fi
        fi
      fi
    fi

    asm_status="missing"
    asm_message=""
    sample_count=0
    failed_runs=0
    validation_failed_runs=0
    for ((run_index = 1; run_index <= REPEAT_RUNS; run_index++)); do
      if [[ ${run_index} -eq 1 ]]; then
        log_file="${OUTPUT_DIR}/${start_result}"
      else
        log_file="${OUTPUT_DIR}/${start_result%.log}.run-${run_index}.log"
      fi
      run_yaml_file="${yaml}"
      if [[ ${NO_VALIDATE} -eq 1 ||
            ( ${VALIDATE_FIRST_ONLY} -eq 1 && ${run_index} -gt 1 ) ]]; then
        run_yaml_file="${yaml%.yaml}.no-validation.yaml"
      fi
      mkdir -p "$(dirname -- "${log_file}")"
      echo "--- ${test_name}: run ${run_index}/${REPEAT_RUNS}"
      run_status=0
      run_yaml "${run_yaml_file}" "${log_file}" config || run_status=$?

      if [[ ${run_status} -eq 124 || ${run_status} -eq 137 ||
            ${run_status} -eq 129 || ${run_status} -eq 130 ||
            ${run_status} -eq 143 || ${run_status} -eq 148 ]]; then
        echo "${test_name}: interrupted or timed out; task remains pending" >&2
        exit "${run_status}"
      fi

      if cache_generated_asm "${log_file}" "${commit_asm_dir}/${test_name}/st"; then
        asm_status="cached"
        asm_message=""
      else
        asm_message="generated st ASM could not be cached"
      fi

      sample_score=""
      sample_time_us=""
      sample_status="execution-failed"
      if sample_result="$(extract_best_result "${log_file}" "${score_metric}")"; then
        IFS=$'\t' read -r sample_score sample_time_us <<< "${sample_result}"
        sample_count=$((sample_count + 1))
        if [[ "${sample_score}" == *"*" ]]; then
          sample_status="validation-failed"
          validation_failed_runs=$((validation_failed_runs + 1))
        elif [[ ${run_status} -eq 0 ]]; then
          sample_status="passed"
        fi
      fi
      if [[ ${run_status} -ne 0 ]]; then
        failed_runs=$((failed_runs + 1))
      fi

      python3 "${STATE_HELPER}" record-sample --output "${OUTPUT_DIR}" \
        --commit "${commit}" --test "${test_name}" --run "${run_index}" \
        --status "${sample_status}" --score "${sample_score}" \
        --time-us "${sample_time_us}" || exit 1

      if [[ -n "${sample_score}" ]]; then
        if [[ -n "${sample_time_us}" ]]; then
          echo "${test_name}: run ${run_index} = ${sample_score} ${score_unit}, ${sample_time_us} us"
        else
          echo "${test_name}: run ${run_index} = ${sample_score} ${score_unit}"
        fi
      else
        echo "${test_name}: run ${run_index} produced no finite score" >&2
      fi
    done

    if [[ ${sample_count} -eq 0 ]]; then
      terminal_status="execution-failed"
      message="no finite ${score_metric} value found in ${REPEAT_RUNS} run(s)"
      finish_task "${commit}" "${test_name}" "${terminal_status}" 0 \
        "${asm_status}" "${message}"
      continue
    fi

    stats_line="$(python3 "${STATE_HELPER}" sample-stats \
      --output "${OUTPUT_DIR}" --commit "${commit}" --test "${test_name}")" || exit 1
    IFS=$'\t' read -r measured_count average best worst standard_deviation \
      best_score validation_failures sample_failures <<< "${stats_line}"
    terminal_status="passed"
    message="${measured_count}/${REPEAT_RUNS} run(s) produced finite scores"
    if [[ ${validation_failures} -gt 0 ]]; then
      terminal_status="validation-failed"
      message="${message}; ${validation_failures} validation-failed run(s)"
    elif [[ ${failed_runs} -gt 0 ]]; then
      terminal_status="execution-failed"
      message="${message}; ${failed_runs} run(s) failed"
    fi
    if [[ -n "${asm_message}" ]]; then
      message="${message}; ${asm_message}"
    fi

    echo "${test_name}: best=${best_score}, average=${average}, worst=${worst}, SD=${standard_deviation} ${score_unit}"
    finish_task "${commit}" "${test_name}" "${terminal_status}" "${best_score}" \
      "${asm_status}" "${message}"
  done
done
fi
python3 "${STATE_HELPER}" compare-asm --output "${OUTPUT_DIR}" || exit 1
regenerate_reports

restore_status=0
if [[ ${RANGE_MODE} -eq 1 ]]; then
  restore_repository || restore_status=$?
fi

echo
echo "Results: ${RESULTS_CSV}"
echo "Summary: ${SUMMARY_FILE}"
echo "Time summary: ${TIME_SUMMARY_FILE}"
if [[ -f "${SUMMARY_FILE}" ]]; then
  python3 "${RESULT_HELPER}" show "${SUMMARY_FILE}"
else
  echo "No commits could be tested."
fi

if [[ -s "${FAILURES_CSV}" ]] && [[ "$(wc -l < "${FAILURES_CSV}")" -gt 1 ]]; then
  echo "Failures: ${FAILURES_CSV}"
fi

exit "${restore_status}"
