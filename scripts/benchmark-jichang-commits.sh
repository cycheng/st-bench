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
changes. When at least two commits are selected, asm-same reports whether each
commit's complete generated st ASM matches the previously tested commit.

YAML compatibility is selected automatically for each rocm-libraries commit:
  before f2a6c23df523:  st-codegen-test revision 2065321
  f2a6c23df523 onward: st-codegen-test revision c394e5b
  3941c087f7 onward:   st-codegen-test revision 6f82feb

Output:
  run-state.csv           Atomic resumable task ledger (source of truth).
  results.csv             Tested commits and maximum score per YAML.
  summary.txt             Human-readable table, updated after every YAML.
  failures.csv            YAML failures and skipped-commit reasons.
  asm-summary.csv         Per-commit-pair and per-YAML ASM comparison counts.
  asm-file-comparisons.csv
                           Exact status and hashes for every ASM file.
  logs/<commit>/<test>.attempt-N.log
  asm/<commit>/<test>/st  Cached generated ASM used for comparison.
  asm-diffs/<pair>/<test>/<file>.diff
                           Unified diffs for changed ASM files.

Reusing --output-dir resumes that run. Completed YAMLs, including failures,
are skipped; interrupted running YAMLs receive a new attempt log.

MAB scores use max(gbps-bandwidth) in GB/s. MAF and medium scores use
max(gflops) / 1000 in PFLOPS.
A score followed by * came from a row whose validation field is FAILED, so the
measured performance is shown but its output was incorrect. A YAML with no
finite value for its metric is recorded as 0, and the remaining YAMLs still
run.
EOF
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
RESULT_HELPER="${SCRIPT_DIR}/benchmark-jichang-results.py"
STATE_HELPER="${SCRIPT_DIR}/benchmark-jichang-state.py"
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

ALL_TEST_NAMES=(
  mab-bf16 mab-bf16-m64 mab-FP8 mab-MXFP8 mab-MXFP4 mab-NVFP4
  maf-bf16 maf-FP8 maf-MXFP8 maf-MXFP4 maf-NVFP4
  medium-bf16 medium-FP8 medium-MXFP8 medium-MXFP4
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

if ! python3 "${STATE_HELPER}" init \
  --output "${OUTPUT_DIR}" --config "${CONFIG_FILE}" --repo "${ROCM_REPO}"; then
  exit 1
fi
mkdir -p "${OUTPUT_DIR}/logs"
RUN_STATE="${OUTPUT_DIR}/run-state.csv"
RESULTS_CSV="${OUTPUT_DIR}/results.csv"
SUMMARY_FILE="${OUTPUT_DIR}/summary.txt"
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

extract_max_score() {
  python3 "${RESULT_HELPER}" extract "$1" --metric "$2"
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

tracked_diff_hash() {
  git -C "${ROCM_REPO}" diff --binary HEAD | sha256sum | awk '{print $1}'
}

session_get() {
  python3 "${STATE_HELPER}" session --output "${OUTPUT_DIR}" get --field "$1"
}

session_set() {
  python3 "${STATE_HELPER}" session --output "${OUTPUT_DIR}" set "$@" || exit 1
}

normalize_interrupted_session() {
  local applied_commit
  local expected_hash
  local actual_hash

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
  applied_commit="$(session_get applied_commit)"
  expected_hash="$(session_get applied_diff_hash)"
  if [[ -n "${applied_commit}" ]]; then
    actual_hash="$(tracked_diff_hash)"
    if [[ "$(git -C "${ROCM_REPO}" rev-parse HEAD)" != "${applied_commit}" ||
          -z "${expected_hash}" || "${actual_hash}" != "${expected_hash}" ]]; then
      echo "Interrupted benchmark left tracked changes that do not demonstrably match its saved automatic stash." >&2
      echo "Inspect ${ROCM_REPO}; the preserved stash is ${STASH_OID:-unknown}. Refusing to reset anything." >&2
      exit 1
    fi
    git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
    session_set --applied-commit "" --applied-diff-hash ""
  elif ! git -C "${ROCM_REPO}" diff --quiet ||
       ! git -C "${ROCM_REPO}" diff --cached --quiet; then
    echo "ROCm repository has unmatched tracked changes; refusing to resume." >&2
    exit 1
  fi
}

restore_repository() {
  [[ ${RANGE_MODE} -eq 1 && ${RESTORED} -eq 0 ]] || return 0
  RESTORED=1
  trap - EXIT
  set +e

  if [[ ${STASH_APPLIED} -eq 1 ]]; then
    local expected_hash
    expected_hash="$(session_get applied_diff_hash)"
    if [[ -z "${expected_hash}" || "$(tracked_diff_hash)" != "${expected_hash}" ]]; then
      echo "WARNING: tracked changes no longer match the automatic stash; not resetting them." >&2
      return 1
    fi
    git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null || return 1
    STASH_APPLIED=0
    session_set --applied-commit "" --applied-diff-hash ""
  fi

  if [[ -n "${ORIGINAL_BRANCH}" ]]; then
    git -C "${ROCM_REPO}" checkout "${ORIGINAL_BRANCH}" >/dev/null || return 1
  else
    git -C "${ROCM_REPO}" checkout --detach "${ORIGINAL_COMMIT}" >/dev/null || return 1
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
if [[ -n "${START_COMMIT}" ]]; then
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
  trap 'exit 130' INT
  trap 'exit 143' TERM
else
  if [[ -f "${OUTPUT_DIR}/git-session.json" ]]; then
    echo "This output directory has an interrupted range-mode Git session." >&2
    echo "Resume with --start and --end so the repository can be recovered safely." >&2
    exit 1
  fi
  COMMITS=("$(git -C "${ROCM_REPO}" rev-parse HEAD)")
fi

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
    if [[ ${STASH_APPLIED} -eq 1 ]]; then
      expected_hash="$(session_get applied_diff_hash)"
      if [[ -z "${expected_hash}" || "$(tracked_diff_hash)" != "${expected_hash}" ]]; then
        echo "Tracked changes no longer match the saved automatic stash; refusing to reset." >&2
        exit 1
      fi
      git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
      STASH_APPLIED=0
      session_set --applied-commit "" --applied-diff-hash ""
    fi

    if ! git -C "${ROCM_REPO}" checkout --detach "${commit}" >/dev/null 2>&1; then
      for test_name in "${TEST_NAMES[@]}"; do
        start_result="$(python3 "${STATE_HELPER}" start --state "${RUN_STATE}" \
          --commit "${commit}" --test "${test_name}")" || exit 1
        [[ "${start_result}" == "skip" ]] && continue
        finish_task "${commit}" "${test_name}" execution-failed 0 missing "git checkout failed"
      done
      continue
    fi

    if [[ -n "${STASH_OID}" ]]; then
      if ! git -C "${ROCM_REPO}" stash apply "${STASH_OID}" >/dev/null 2>&1; then
        git -C "${ROCM_REPO}" reset --hard HEAD >/dev/null
        STASH_APPLIED=0
        for test_name in "${TEST_NAMES[@]}"; do
          start_result="$(python3 "${STATE_HELPER}" start --state "${RUN_STATE}" \
            --commit "${commit}" --test "${test_name}")" || exit 1
          [[ "${start_result}" == "skip" ]] && continue
          finish_task "${commit}" "${test_name}" execution-failed 0 missing "git stash apply failed"
        done
        continue
      fi
      STASH_APPLIED=1
      session_set --applied-commit "${commit}" --applied-diff-hash "$(tracked_diff_hash)"
    fi
  fi

  if ! prepare_yamls "${yaml_revision}"; then
    for test_name in "${TEST_NAMES[@]}"; do
      start_result="$(python3 "${STATE_HELPER}" start --state "${RUN_STATE}" \
        --commit "${commit}" --test "${test_name}")" || exit 1
      [[ "${start_result}" == "skip" ]] && continue
      finish_task "${commit}" "${test_name}" execution-failed 0 missing \
        "could not prepare YAML revision ${yaml_revision}"
    done
    continue
  fi

  commit_log_dir="${OUTPUT_DIR}/logs/${short_commit}"
  mkdir -p "${commit_log_dir}"
  commit_asm_dir="${OUTPUT_DIR}/asm/${short_commit}"

  for index in "${!TEST_NAMES[@]}"; do
    test_name="${TEST_NAMES[${index}]}"
    yaml="${OUTPUT_DIR}/yamls/${yaml_revision}/${TEST_YAMLS[${index}]#examples/jichang/}"
    test_category="${TEST_YAMLS[${index}]#examples/jichang/}"
    test_category="${test_category%%/*}"
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
    log_file="${OUTPUT_DIR}/${start_result}"
    mkdir -p "$(dirname -- "${log_file}")"
    echo "--- ${test_name}: ${TEST_YAMLS[${index}]}"
    (
      cd "${PROJECT_DIR}" &&
      ./scripts/run-single-yaml.sh "${CONFIG_FILE}" "${yaml}"
    ) 2>&1 | tee "${log_file}"
    run_status="${PIPESTATUS[0]}"

    if ! score="$(extract_max_score "${log_file}" "${score_metric}")"; then
      if [[ ${run_status} -ne 0 ]]; then
        terminal_status="execution-failed"
        message="YAML execution failed with no finite ${score_metric} value"
      else
        terminal_status="no-score"
        message="no finite ${score_metric} value found"
      fi
      finish_task "${commit}" "${test_name}" "${terminal_status}" 0 missing "${message}"
      continue
    fi

    terminal_status="passed"
    message=""
    if [[ "${score}" == *"*" ]]; then
      terminal_status="validation-failed"
      message="validation failed (score marked *)"
    fi

    if [[ ${run_status} -ne 0 ]]; then
      if [[ "${terminal_status}" == "passed" ]]; then
        terminal_status="execution-failed"
        message="YAML execution failed after reporting a score"
      fi
      asm_status="missing"
    elif cache_generated_asm "${log_file}" "${commit_asm_dir}/${test_name}/st"; then
      asm_status="cached"
    else
      asm_status="missing"
      if [[ -z "${message}" ]]; then
        message="generated st ASM could not be cached"
      else
        message="${message}; generated st ASM could not be cached"
      fi
    fi

    echo "${test_name}: ${score} ${score_unit}"
    finish_task "${commit}" "${test_name}" "${terminal_status}" "${score}" \
      "${asm_status}" "${message}"
  done
done
python3 "${STATE_HELPER}" compare-asm --output "${OUTPUT_DIR}" || exit 1
regenerate_reports

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
