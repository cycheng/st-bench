#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${1:-${PROJECT_DIR}/examples/test-silicon-rel.cfg}"
RUNNER="${RUN_SINGLE_YAML:-${SCRIPT_DIR}/run-single-yaml.sh}"
RUNS=1

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Config file not found: ${CONFIG_FILE}" >&2
  exit 1
fi

if [[ ! -x "${RUNNER}" ]]; then
  echo "Runner is missing or not executable: ${RUNNER}" >&2
  exit 1
fi

declare -a MAB_NAMES=()
declare -a MAF_NAMES=()
declare -a MEDIUM_NAMES=()
declare -A SCORES=()

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

extract_score() {
  local metric="$1"
  shift

  python3 - "${metric}" "$@" <<'PY'
import csv
import math
import sys

metric = sys.argv[1]
best_time = None
best_score = None

for log_name in sys.argv[2:]:
    with open(log_name, encoding="utf-8", errors="replace", newline="") as stream:
        header = None
        for line in stream:
            try:
                row = next(csv.reader([line]))
            except csv.Error:
                continue

            normalized = [field.strip().lower() for field in row]
            required = {"validation", "time-us", "gflops", "gbps-bandwidth"}
            if required.issubset(normalized):
                header = normalized
                continue
            if header is None:
                continue

            try:
                time_us = float(row[header.index("time-us")])
                score = float(row[header.index(metric)])
            except (ValueError, IndexError):
                continue
            if not math.isfinite(time_us) or not math.isfinite(score):
                continue

            if best_time is None or time_us < best_time:
                best_time = time_us
                best_score = score

if best_score is None:
    raise SystemExit(1)

print(f"{best_score:.9g}")
PY
}

for category in mab maf medium; do
  metric="gbps-bandwidth"
  [[ "${category}" != "mab" ]] && metric="gflops"

  while IFS= read -r -d '' yaml; do
    name="$(basename -- "${yaml}" .yaml)"
    key="${category}/${name}"
    logs=()

    for ((run = 1; run <= RUNS; run++)); do
      log="${TMP_DIR}/${category}-${name}-${run}.log"
      logs+=("${log}")
      echo "=== ${category}/${name}: run ${run}/${RUNS} ===" >&2

      run_status=0
      if "${RUNNER}" "${CONFIG_FILE}" "${yaml}" --live-output \
          2>&1 | tee "${log}" >&2; then
        :
      else
        run_status="${PIPESTATUS[0]}"
      fi
      if [[ "${run_status}" -ne 0 ]]; then
        echo "warning: run failed with status ${run_status}" >&2
      fi
    done

    if score="$(extract_score "${metric}" "${logs[@]}")"; then
      SCORES["${key}"]="${score}"
    else
      SCORES["${key}"]="NA"
      echo "warning: no finite ${metric} result for ${category}/${name}" >&2
    fi

    case "${category}" in
      mab) MAB_NAMES+=("${name}") ;;
      maf) MAF_NAMES+=("${name}") ;;
      medium) MEDIUM_NAMES+=("${name}") ;;
    esac
  done < <(find "${PROJECT_DIR}/examples/jichang/${category}" \
    -maxdepth 1 -type f -name '*.yaml' -print0 | sort -z)
done

headers=("result")
values=("best")
for name in "${MAB_NAMES[@]}"; do
  headers+=("mab-${name}")
  values+=("${SCORES[mab/${name}]}")
done
for name in "${MAF_NAMES[@]}"; do
  headers+=("maf-${name}")
  values+=("${SCORES[maf/${name}]}")
done
for name in "${MEDIUM_NAMES[@]}"; do
  headers+=("medium-${name}")
  values+=("${SCORES[medium/${name}]}")
done

declare -a WIDTHS=()
for index in "${!headers[@]}"; do
  width="${#headers[index]}"
  (( ${#values[index]} > width )) && width="${#values[index]}"
  WIDTHS+=("${width}")
done

for index in "${!headers[@]}"; do
  (( index > 0 )) && printf '   '
  printf '%-*s' "${WIDTHS[index]}" "${headers[index]}"
done
printf '\n'
for index in "${!values[@]}"; do
  (( index > 0 )) && printf '   '
  if (( index == 0 )); then
    printf '%-*s' "${WIDTHS[index]}" "${values[index]}"
  else
    printf '%*s' "${WIDTHS[index]}" "${values[index]}"
  fi
done
printf '\n'
