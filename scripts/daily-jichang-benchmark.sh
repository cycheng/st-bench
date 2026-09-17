#!/usr/bin/env bash

set -euo pipefail

# The script is installed under <st-codegen-test>/scripts, so this resolves to
# /home/cycheng2/st-codegen-test on the remote machine and to the corresponding
# local checkout when tested elsewhere.
PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ROCM_REPO="/home/cycheng2/rocm-libraries"
REMOTE_REF="refs/remotes/origin/develop"
DAILY_DIR="${PROJECT_DIR}/benchmark-results/daily"
CURSOR_FILE="${DAILY_DIR}/last-commit"
LOCK_FILE="${DAILY_DIR}/.lock"
TODAY="$(date -u +%Y%m%d)"
OUTPUT_DIR="${DAILY_DIR}/${TODAY}"

export HOME="/home/cycheng2"
export PATH="/usr/local/bin:/usr/bin:/bin"

mkdir -p -- "${DAILY_DIR}"
exec 9>"${LOCK_FILE}"
flock -n 9 || exit 0

if ! git -C "${ROCM_REPO}" fetch --prune origin develop; then
  echo "Failed to fetch origin/develop." >&2
  exit 1
fi

END_COMMIT="$(git -C "${ROCM_REPO}" rev-parse "${REMOTE_REF}")"

if [[ -s "${CURSOR_FILE}" ]]; then
  START_COMMIT="$(<"${CURSOR_FILE}")"
  git -C "${ROCM_REPO}" cat-file -e "${START_COMMIT}^{commit}"
else
  cutoff="$(date -u -d 'yesterday 00:00:00' '+%Y-%m-%dT%H:%M:%SZ')"
  START_COMMIT="$(
    git -C "${ROCM_REPO}" rev-list -1 --before="${cutoff}" "${END_COMMIT}"
  )"
  if [[ -z "${START_COMMIT}" ]]; then
    echo "Could not find a baseline commit before yesterday." >&2
    exit 1
  fi
fi

if ! git -C "${ROCM_REPO}" merge-base --is-ancestor \
    "${START_COMMIT}" "${END_COMMIT}"; then
  echo "Saved cursor is not an ancestor of origin/develop." >&2
  echo "Cursor: ${START_COMMIT}" >&2
  echo "HEAD:   ${END_COMMIT}" >&2
  exit 1
fi

mapfile -t COMMITS < <(
  git -C "${ROCM_REPO}" rev-list --reverse \
    "${START_COMMIT}..${END_COMMIT}" \
    -- projects/hipblaslt shared/stinkytofu
)

if [[ ${#COMMITS[@]} -eq 0 ]]; then
  echo "No new hipblaslt or stinkytofu commits."
  exit 0
fi

# Include the cursor as an ASM baseline. This intentionally reruns that one
# commit in a new daily output directory so --skip-identical-asm can compare
# the first new commit against it.
ARGS=(
  --repo "${ROCM_REPO}"
  --config "${PROJECT_DIR}/examples/test-silicon-rel.cfg"
  --output-dir "${OUTPUT_DIR}"
  --repeat 5
  --skip-identical-asm
  --commit "${START_COMMIT}"
)
for commit in "${COMMITS[@]}"; do
  ARGS+=(--commit "${commit}")
done

"${PROJECT_DIR}/scripts/benchmark-jichang-commits.sh" "${ARGS[@]}"

last_index=$((${#COMMITS[@]} - 1))
last_commit="${COMMITS[${last_index}]}"
temporary_cursor="${CURSOR_FILE}.tmp.$$"
printf '%s\n' "${last_commit}" > "${temporary_cursor}"
mv -f -- "${temporary_cursor}" "${CURSOR_FILE}"

echo "Updated cursor to ${last_commit}"
