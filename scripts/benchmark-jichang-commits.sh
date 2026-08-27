#!/usr/bin/env bash

set -uo pipefail

usage() {
  cat <<'EOF'
Benchmark the Jichang MAF and medium YAMLs, optionally across a commit range.

Usage:
  scripts/benchmark-jichang-commits.sh [options]

Options:
  --start <commit>       First range boundary (inclusive; requires --end).
  --end <commit>         Last range boundary (inclusive; requires --start).
  --config <file>        run-single-yaml config (default: examples/test.cfg).
  --repo <dir>           rocm-libraries repository (default: ~/rocm-libraries).
  --output-dir <dir>     Result directory (default: benchmark-results/<time>).
  -h, --help             Show this help.

Without --start/--end, test the current checkout once and do not change or
stash the repository.

In range mode, only commits that modify shared/stinkytofu are tested.

Output:
  results.csv             Tested commits and maximum PFLOPS per YAML.
  summary.txt             Human-readable table, updated after every YAML.
  failures.csv            YAML failures and skipped-commit reasons.
  logs/<commit>/<test>.log

PFLOPS is calculated as max(gflops) / 1000 for each YAML.
A YAML that fails or has no finite gflops value is recorded as 0, and the
remaining YAMLs for that commit are still run.
EOF
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
RESULT_HELPER="${SCRIPT_DIR}/benchmark-jichang-results.py"
CONFIG_FILE="${PROJECT_DIR}/examples/test.cfg"
ROCM_REPO="${HOME}/rocm-libraries"
OUTPUT_DIR="${PROJECT_DIR}/benchmark-results/$(date +%Y%m%d-%H%M%S)"
START_COMMIT=""
END_COMMIT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
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
    --output-dir)
      [[ $# -ge 2 ]] || { echo "Missing value for --output-dir" >&2; exit 2; }
      OUTPUT_DIR="$2"
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

CONFIG_FILE="$(readlink -f -- "${CONFIG_FILE}")"
ROCM_REPO="$(readlink -f -- "${ROCM_REPO}")"
OUTPUT_DIR="$(readlink -m -- "${OUTPUT_DIR}")"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Config file not found: ${CONFIG_FILE}" >&2
  exit 2
fi
if [[ ! -f "${RESULT_HELPER}" ]]; then
  echo "Result helper not found: ${RESULT_HELPER}" >&2
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

TEST_NAMES=(
  maf-bf16 maf-FP8 maf-MXFP8 maf-MXFP4 maf-NVFP4
  medium-bf16 medium-FP8 medium-MXFP8 medium-MXFP4
)
TEST_YAMLS=(
  examples/jichang/maf/bbs_tn_maf.yaml
  examples/jichang/maf/f8_tn_maf.yaml
  examples/jichang/maf/mxf8_tn_maf.yaml
  examples/jichang/maf/mxf4_tn_maf.yaml
  examples/jichang/maf/nvf4_tn_maf.yaml
  examples/jichang/medium/bbs_tn_medium.yaml
  examples/jichang/medium/f8_tn_medium.yaml
  examples/jichang/medium/mxf8_tn_medium.yaml
  examples/jichang/medium/mxf4_tn_medium.yaml
)

for yaml in "${TEST_YAMLS[@]}"; do
  if [[ ! -f "${PROJECT_DIR}/${yaml}" ]]; then
    echo "YAML file not found: ${PROJECT_DIR}/${yaml}" >&2
    exit 2
  fi
done

mkdir -p "${OUTPUT_DIR}/logs"
RESULTS_CSV="${OUTPUT_DIR}/results.csv"
SUMMARY_FILE="${OUTPUT_DIR}/summary.txt"
FAILURES_CSV="${OUTPUT_DIR}/failures.csv"
printf '%s\n' \
  'commit-id,maf-bf16,maf-FP8,maf-MXFP8,maf-MXFP4,maf-NVFP4,medium-bf16,medium-FP8,medium-MXFP8,medium-MXFP4' \
  > "${RESULTS_CSV}"
printf '%s\n' 'commit-id,reason' > "${FAILURES_CSV}"

update_result_and_summary() {
  local commit="$1"
  local result_index="$2"
  local value="$3"

  python3 "${RESULT_HELPER}" update \
    --results "${RESULTS_CSV}" \
    --summary "${SUMMARY_FILE}" \
    --commit "${commit}" \
    --index "${result_index}" \
    --value "${value}"
}

csv_escape() {
  local value="${1//\"/\"\"}"
  printf '"%s"' "${value}"
}

record_failure() {
  local commit="$1"
  local reason="$2"
  printf '%s,' "${commit}" >> "${FAILURES_CSV}"
  csv_escape "${reason}" >> "${FAILURES_CSV}"
  printf '\n' >> "${FAILURES_CSV}"
  echo "${commit}: ${reason}" >&2
}

extract_max_pflops() {
  python3 "${RESULT_HELPER}" extract "$1"
}

ORIGINAL_COMMIT=""
ORIGINAL_BRANCH=""
STASH_OID=""
STASH_APPLIED=0
RANGE_MODE=0
RESTORED=0

restore_repository() {
  [[ ${RANGE_MODE} -eq 1 && ${RESTORED} -eq 0 ]] || return 0
  RESTORED=1
  trap - EXIT
  set +e

  if [[ ${STASH_APPLIED} -eq 1 ]]; then
    git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
    STASH_APPLIED=0
  fi

  if [[ -n "${ORIGINAL_BRANCH}" ]]; then
    git -C "${ROCM_REPO}" checkout "${ORIGINAL_BRANCH}" >/dev/null
  else
    git -C "${ROCM_REPO}" checkout --detach "${ORIGINAL_COMMIT}" >/dev/null
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
}

COMMITS=()
if [[ -n "${START_COMMIT}" ]]; then
  RANGE_MODE=1
  ORIGINAL_COMMIT="$(git -C "${ROCM_REPO}" rev-parse HEAD)"
  ORIGINAL_BRANCH="$(git -C "${ROCM_REPO}" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"

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

  COMMITS=()
  if [[ -n "$(git -C "${ROCM_REPO}" diff-tree --root --no-commit-id \
    --name-only -r "${START_COMMIT}" -- shared/stinkytofu)" ]]; then
    COMMITS+=("${START_COMMIT}")
  fi
  while IFS= read -r commit; do
    [[ -n "${commit}" ]] && COMMITS+=("${commit}")
  done < <(
    git -C "${ROCM_REPO}" rev-list --reverse --ancestry-path \
      "${START_COMMIT}..${END_COMMIT}" -- shared/stinkytofu
  )

  if [[ ${#COMMITS[@]} -eq 0 ]]; then
    echo "No commits in the requested range modify shared/stinkytofu." >&2
    exit 2
  fi

  if ! git -C "${ROCM_REPO}" diff --quiet ||
     ! git -C "${ROCM_REPO}" diff --cached --quiet; then
    echo "Stashing tracked changes in ${ROCM_REPO}"
    if ! git -C "${ROCM_REPO}" stash push -m "benchmark-jichang-commits automatic stash"; then
      echo "Failed to stash repository changes." >&2
      exit 1
    fi
    STASH_OID="$(git -C "${ROCM_REPO}" rev-parse refs/stash)"
  fi

  trap restore_repository EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
else
  COMMITS=("$(git -C "${ROCM_REPO}" rev-parse HEAD)")
fi

for commit in "${COMMITS[@]}"; do
  short_commit="$(git -C "${ROCM_REPO}" rev-parse --short=12 "${commit}")"
  echo
  echo "===== Testing ${short_commit} ====="

  if [[ ${RANGE_MODE} -eq 1 ]]; then
    if [[ ${STASH_APPLIED} -eq 1 ]]; then
      git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
      STASH_APPLIED=0
    fi

    if ! git -C "${ROCM_REPO}" checkout --detach "${commit}" >/dev/null 2>&1; then
      record_failure "${short_commit}" "git checkout failed"
      continue
    fi

    if [[ -n "${STASH_OID}" ]]; then
      if ! git -C "${ROCM_REPO}" stash apply "${STASH_OID}" >/dev/null 2>&1; then
        record_failure "${short_commit}" "git stash apply failed"
        git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
        STASH_APPLIED=0
        continue
      fi
      STASH_APPLIED=1
    fi
  fi

  commit_log_dir="${OUTPUT_DIR}/logs/${short_commit}"
  mkdir -p "${commit_log_dir}"
  update_result_and_summary "${short_commit}" -1 0

  for index in "${!TEST_NAMES[@]}"; do
    test_name="${TEST_NAMES[${index}]}"
    yaml="${PROJECT_DIR}/${TEST_YAMLS[${index}]}"
    log_file="${commit_log_dir}/${test_name}.log"

    echo "--- ${test_name}: ${TEST_YAMLS[${index}]}"
    if ! (
      cd "${PROJECT_DIR}" &&
      ./scripts/run-single-yaml.sh "${CONFIG_FILE}" "${yaml}"
    ) 2>&1 | tee "${log_file}"; then
      record_failure "${short_commit}" "${test_name}: YAML execution failed"
      update_result_and_summary "${short_commit}" "${index}" 0
      continue
    fi

    if ! pflops="$(extract_max_pflops "${log_file}")"; then
      record_failure "${short_commit}" "${test_name}: no finite gflops value found"
      update_result_and_summary "${short_commit}" "${index}" 0
      continue
    fi
    echo "${test_name}: ${pflops} PFLOPS"
    update_result_and_summary "${short_commit}" "${index}" "${pflops}"
  done
done

restore_status=0
if [[ ${RANGE_MODE} -eq 1 ]]; then
  restore_repository || restore_status=$?
fi

echo
echo "Results: ${RESULTS_CSV}"
echo "Summary: ${SUMMARY_FILE}"
if [[ -f "${SUMMARY_FILE}" ]]; then
  python3 "${RESULT_HELPER}" show "${SUMMARY_FILE}"
else
  echo "No commits could be tested."
fi

if [[ -s "${FAILURES_CSV}" ]] && [[ "$(wc -l < "${FAILURES_CSV}")" -gt 1 ]]; then
  echo "Failures: ${FAILURES_CSV}"
fi

exit "${restore_status}"
