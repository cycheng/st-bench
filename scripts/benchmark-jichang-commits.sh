#!/usr/bin/env bash

set -uo pipefail

usage() {
  cat <<'EOF'
Benchmark the Jichang MAB, MAF, and medium YAMLs, optionally across a
rocm-libraries commit range.

Usage:
  scripts/benchmark-jichang-commits.sh [options]

Options:
  --start <commit>       First range boundary (inclusive; requires --end).
  --end <commit>         Last range boundary (inclusive; requires --start).
  --config <file>        run-single-yaml config (default: examples/test.cfg).
  --repo <dir>           rocm-libraries repository (default: ~/rocm-libraries).
  --output-dir <dir>     Result directory (default: benchmark-results/<time>).
  --category <name>      Only run mab, maf, or medium.
  --yaml <file>          Only run one YAML, relative to examples/jichang
                         (for example: maf/f8_tn_maf.yaml).
  --component <name>     Range commits from stinkytofu, hipblaslt, or either
                         (default: either).
  -h, --help             Show this help.

Without --start/--end, test the current checkout once and do not change or
stash the repository.

In range mode, commits that modify shared/stinkytofu, projects/hipblaslt, or
both are tested. The source column identifies which component each commit
changes.

YAML compatibility is selected automatically for each rocm-libraries commit:
  before f2a6c23df523:  st-codegen-test revision 2065321
  f2a6c23df523 onward: st-codegen-test revision c394e5b
  3941c087f7 onward:   st-codegen-test revision 6f82feb

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
CATEGORY=""
ONLY_YAML=""
COMPONENT="either"

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
    --category)
      [[ $# -ge 2 ]] || { echo "Missing value for --category" >&2; exit 2; }
      CATEGORY="$2"
      shift 2
      ;;
    --yaml)
      [[ $# -ge 2 ]] || { echo "Missing value for --yaml" >&2; exit 2; }
      ONLY_YAML="$2"
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
if [[ -n "${CATEGORY}" ]] &&
   [[ "${CATEGORY}" != "mab" && "${CATEGORY}" != "maf" && "${CATEGORY}" != "medium" ]]; then
  echo "--category must be mab, maf, or medium." >&2
  exit 2
fi
if [[ "${COMPONENT}" != "stinkytofu" &&
      "${COMPONENT}" != "hipblaslt" &&
      "${COMPONENT}" != "either" ]]; then
  echo "--component must be stinkytofu, hipblaslt, or either." >&2
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
if ! git -C "${PROJECT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Benchmark project is not a Git repository: ${PROJECT_DIR}" >&2
  exit 2
fi

ALL_TEST_NAMES=(
  mab-bf16 mab-bf16-m64 mab-FP8 mab-MXFP8 mab-MXFP4 mab-NVFP4
  maf-bf16 maf-FP8 maf-MXFP8 maf-MXFP4 maf-NVFP4
  medium-bf16 medium-FP8-FP4 medium-FP8 medium-MXFP8 medium-MXFP4
)
ALL_TEST_YAMLS=(
  examples/jichang/mab/bbs_tn_mab.yaml
  examples/jichang/mab/bbs_tn_m_64_mab.yaml
  examples/jichang/mab/f8_tn_mab.yaml
  examples/jichang/mab/mxf8_tn_mab.yaml
  examples/jichang/mab/mxf4_tn_mab.yaml
  examples/jichang/mab/nvf4_tn_mab.yaml
  examples/jichang/maf/bbs_tn_maf.yaml
  examples/jichang/maf/f8_tn_maf.yaml
  examples/jichang/maf/mxf8_tn_maf.yaml
  examples/jichang/maf/mxf4_tn_maf.yaml
  examples/jichang/maf/nvf4_tn_maf.yaml
  examples/jichang/medium/bbs_tn_medium.yaml
  examples/jichang/medium/f8_f4_tn.yaml
  examples/jichang/medium/f8_tn_medium.yaml
  examples/jichang/medium/mxf8_tn_medium.yaml
  examples/jichang/medium/mxf4_tn_medium.yaml
)

if [[ -n "${ONLY_YAML}" ]]; then
  ONLY_YAML="${ONLY_YAML#./}"
  ONLY_YAML="${ONLY_YAML#examples/jichang/}"
  ONLY_YAML="examples/jichang/${ONLY_YAML}"
fi

TEST_NAMES=()
TEST_YAMLS=()
for index in "${!ALL_TEST_NAMES[@]}"; do
  yaml="${ALL_TEST_YAMLS[${index}]}"
  yaml_category="${yaml#examples/jichang/}"
  yaml_category="${yaml_category%%/*}"
  [[ -z "${CATEGORY}" || "${yaml_category}" == "${CATEGORY}" ]] || continue
  [[ -z "${ONLY_YAML}" || "${yaml}" == "${ONLY_YAML}" ]] || continue
  TEST_NAMES+=("${ALL_TEST_NAMES[${index}]}")
  TEST_YAMLS+=("${yaml}")
done

if [[ ${#TEST_YAMLS[@]} -eq 0 ]]; then
  if [[ -n "${ONLY_YAML}" ]]; then
    echo "Unknown YAML or YAML excluded by --category: ${ONLY_YAML}" >&2
  else
    echo "No YAMLs selected." >&2
  fi
  exit 2
fi

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
  "commit-id,source,$(IFS=,; echo "${TEST_NAMES[*]}")" > "${RESULTS_CSV}"
printf '%s\n' 'commit-id,source,reason' > "${FAILURES_CSV}"

update_result_and_summary() {
  local commit="$1"
  local source="$2"
  local result_index="$3"
  local value="$4"

  python3 "${RESULT_HELPER}" update \
    --results "${RESULTS_CSV}" \
    --summary "${SUMMARY_FILE}" \
    --commit "${commit}" \
    --source "${source}" \
    --index "${result_index}" \
    --value "${value}"
}

csv_escape() {
  local value="${1//\"/\"\"}"
  printf '"%s"' "${value}"
}

record_failure() {
  local commit="$1"
  local source="$2"
  local reason="$3"
  printf '%s,%s,' "${commit}" "${source}" >> "${FAILURES_CSV}"
  csv_escape "${reason}" >> "${FAILURES_CSV}"
  printf '\n' >> "${FAILURES_CSV}"
  echo "${commit}: ${reason}" >&2
}

extract_max_pflops() {
  python3 "${RESULT_HELPER}" extract "$1"
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

  if git -C "${ROCM_REPO}" merge-base --is-ancestor 3941c087f7 "${commit}"; then
    echo "6f82feb"
  elif git -C "${ROCM_REPO}" merge-base --is-ancestor f2a6c23df523 "${commit}"; then
    echo "c394e5b"
  else
    echo "2065321"
  fi
}

prepare_yamls() {
  local revision="$1"
  local yaml
  local destination
  local temporary

  for yaml in "${TEST_YAMLS[@]}"; do
    destination="${OUTPUT_DIR}/yamls/${revision}/${yaml#examples/jichang/}"
    if [[ ! -f "${destination}" ]]; then
      mkdir -p "$(dirname -- "${destination}")"
      temporary="${destination}.tmp"
      if ! git -C "${PROJECT_DIR}" show "${revision}:${yaml}" > "${temporary}"; then
        rm -f -- "${temporary}"
        echo "Could not load ${yaml} from benchmark revision ${revision}." >&2
        return 1
      fi
      mv -- "${temporary}" "${destination}"
    fi
  done
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
  source="$(commit_source "${commit}")"
  yaml_revision="$(yaml_revision_for_commit "${commit}")"
  echo
  echo "===== Testing ${short_commit} (${source}; YAML revision ${yaml_revision}) ====="

  if [[ ${RANGE_MODE} -eq 1 ]]; then
    if [[ ${STASH_APPLIED} -eq 1 ]]; then
      git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
      STASH_APPLIED=0
    fi

    if ! git -C "${ROCM_REPO}" checkout --detach "${commit}" >/dev/null 2>&1; then
      record_failure "${short_commit}" "${source}" "git checkout failed"
      continue
    fi

    if [[ -n "${STASH_OID}" ]]; then
      if ! git -C "${ROCM_REPO}" stash apply "${STASH_OID}" >/dev/null 2>&1; then
        record_failure "${short_commit}" "${source}" "git stash apply failed"
        git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
        STASH_APPLIED=0
        continue
      fi
      STASH_APPLIED=1
    fi
  fi

  if ! prepare_yamls "${yaml_revision}"; then
    record_failure "${short_commit}" "${source}" \
      "could not prepare YAML revision ${yaml_revision}"
    continue
  fi

  commit_log_dir="${OUTPUT_DIR}/logs/${short_commit}"
  mkdir -p "${commit_log_dir}"
  update_result_and_summary "${short_commit}" "${source}" -1 0

  for index in "${!TEST_NAMES[@]}"; do
    test_name="${TEST_NAMES[${index}]}"
    yaml="${OUTPUT_DIR}/yamls/${yaml_revision}/${TEST_YAMLS[${index}]#examples/jichang/}"
    log_file="${commit_log_dir}/${test_name}.log"

    echo "--- ${test_name}: ${TEST_YAMLS[${index}]}"
    if ! (
      cd "${PROJECT_DIR}" &&
      ./scripts/run-single-yaml.sh "${CONFIG_FILE}" "${yaml}"
    ) 2>&1 | tee "${log_file}"; then
      record_failure "${short_commit}" "${source}" \
        "${test_name}: YAML execution failed"
      update_result_and_summary "${short_commit}" "${source}" "${index}" 0
      continue
    fi

    if ! pflops="$(extract_max_pflops "${log_file}")"; then
      record_failure "${short_commit}" "${source}" \
        "${test_name}: no finite gflops value found"
      update_result_and_summary "${short_commit}" "${source}" "${index}" 0
      continue
    fi
    echo "${test_name}: ${pflops} PFLOPS"
    update_result_and_summary \
      "${short_commit}" "${source}" "${index}" "${pflops}"
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
