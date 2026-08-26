#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Compare asm folder pairs.

Mode 1 (default): Compare orig vs st within the same root
  scripts/diff-asm.sh [--asm-root <dir>] [--side-by-side] [--ignore-cluster-label-hash]

Mode 2 (cross-compare): Compare across two different top folders
  scripts/diff-asm.sh --left <dir> --right <dir> [--left-sub orig|st] [--right-sub orig|st] [--side-by-side] [--ignore-cluster-label-hash]

  Examples:
    # asm0/A/orig vs asm1/A/orig
    scripts/diff-asm.sh --left asm0 --right asm1

    # asm0/A/orig vs asm1/A/st
    scripts/diff-asm.sh --left asm0 --right asm1 --right-sub st

    # asm0/A/st vs asm1/A/st
    scripts/diff-asm.sh --left asm0 --right asm1 --left-sub st --right-sub st

Options:
  --asm-root <dir>     Root directory that contains case folders (default: ./asm)
  --left <dir>         Left root directory (enables cross-compare mode)
  --right <dir>        Right root directory (enables cross-compare mode)
  --left-sub <name>    Subfolder to use from left root (default: orig)
  --right-sub <name>   Subfolder to use from right root (default: orig)
  --side-by-side       Use side-by-side diff output (default: recursive brief diff)
  --ignore-cluster-label-hash
                       Ignore random 16-character hashes in cluster barrier labels
  -h, --help           Show help
EOF
}

ASM_ROOT="./asm"
SIDE_BY_SIDE=0
LEFT_ROOT=""
RIGHT_ROOT=""
LEFT_SUB="orig"
RIGHT_SUB="orig"
IGNORE_CLUSTER_LABEL_HASH=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --asm-root) ASM_ROOT="$2"; shift 2 ;;
    --left) LEFT_ROOT="$2"; shift 2 ;;
    --right) RIGHT_ROOT="$2"; shift 2 ;;
    --left-sub) LEFT_SUB="$2"; shift 2 ;;
    --right-sub) RIGHT_SUB="$2"; shift 2 ;;
    --side-by-side) SIDE_BY_SIDE=1; shift ;;
    --ignore-cluster-label-hash) IGNORE_CLUSTER_LABEL_HASH=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

CROSS_MODE=0
if [[ -n "${LEFT_ROOT}" || -n "${RIGHT_ROOT}" ]]; then
  if [[ -z "${LEFT_ROOT}" || -z "${RIGHT_ROOT}" ]]; then
    echo "Error: both --left and --right must be specified for cross-compare mode" >&2
    exit 1
  fi
  for dir in "${LEFT_ROOT}" "${RIGHT_ROOT}"; do
    if [[ ! -d "${dir}" ]]; then
      echo "Error: directory does not exist: ${dir}" >&2
      exit 1
    fi
  done
  CROSS_MODE=1
else
  if [[ ! -d "${ASM_ROOT}" ]]; then
    echo "Error: asm root does not exist: ${ASM_ROOT}" >&2
    exit 1
  fi
fi

total_folders=0
diff_folders=0
no_diff_folders=0
skipped_folders=0
total_asm_files=0

diff_folder_list=()
no_diff_folder_list=()
skipped_folder_list=()

run_diff() {
  local left_dir="$1"
  local right_dir="$2"
  local label="$3"
  local diff_left="${left_dir}"
  local diff_right="${right_dir}"
  local temp_dir=""

  if [[ ${IGNORE_CLUSTER_LABEL_HASH} -eq 1 ]]; then
    temp_dir=$(mktemp -d)
    mkdir -p "${temp_dir}/left" "${temp_dir}/right"
    cp -a "${left_dir}/." "${temp_dir}/left/"
    cp -a "${right_dir}/." "${temp_dir}/right/"

    # Normalize only the random portion while preserving the rest of each line.
    find "${temp_dir}/left" "${temp_dir}/right" -type f \( -name "*.s" -o -name "*.asm" \) \
      -exec perl -pi -e 's/(label_skipCBPreSignal_(?:LCL_)?)[A-Za-z0-9]{16}/$1<hash>/g' {} +

    diff_left="${temp_dir}/left"
    diff_right="${temp_dir}/right"
  fi

  set +e
  if [[ ${SIDE_BY_SIDE} -eq 1 ]]; then
    diff -y --suppress-common-lines -W 200 -b --exclude=manifest.txt "${diff_left}" "${diff_right}"
  else
    diff -qr -b --exclude=manifest.txt "${diff_left}" "${diff_right}"
  fi
  diff_status=$?
  set -e

  [[ -z "${temp_dir}" ]] || rm -rf "${temp_dir}"

  if [[ ${diff_status} -eq 0 ]]; then
    echo "No differences found in ${label}"
    ((no_diff_folders+=1))
    no_diff_folder_list+=("${label}")
  elif [[ ${diff_status} -eq 1 ]]; then
    echo "Differences found in ${label}"
    ((diff_folders+=1))
    diff_folder_list+=("${label}")
  else
    echo "Error while diffing ${label}"
  fi
  echo
}

count_asm_files() {
  find "$1" -type f \( -name "*.s" -o -name "*.asm" \) | wc -l
}

# --- Mode 1: orig vs st within the same root ---
process_case_folder() {
  local folder="$1"
  local folder_name="$2"
  local orig_dir="${folder}/orig"
  local st_dir="${folder}/st"
  local missing

  if [[ ! -d "${orig_dir}" || ! -d "${st_dir}" ]]; then
    if [[ ! -d "${orig_dir}" && ! -d "${st_dir}" ]]; then
      missing="orig and st directories not found"
    elif [[ ! -d "${orig_dir}" ]]; then
      missing="orig directory not found"
    else
      missing="st directory not found"
    fi
    echo "Skipping ${folder_name}: ${missing}"
    echo
    ((skipped_folders+=1))
    skipped_folder_list+=("${folder_name} (${missing})")
    return
  fi

  ((total_folders+=1))
  local orig_count; orig_count=$(count_asm_files "${orig_dir}")
  local st_count; st_count=$(count_asm_files "${st_dir}")
  total_asm_files=$((total_asm_files + orig_count + st_count))

  echo "=========================================="
  echo "Comparing: ${folder_name}"
  echo "Files: ${orig_count} (orig) + ${st_count} (st)"
  echo "=========================================="

  run_diff "${orig_dir}" "${st_dir}" "${folder_name}"
}

# --- Mode 2: cross-compare across two top folders ---
process_cross_folder() {
  local case_name="$1"
  local left_dir="${LEFT_ROOT}/${case_name}/${LEFT_SUB}"
  local right_dir="${RIGHT_ROOT}/${case_name}/${RIGHT_SUB}"
  local missing_parts=()

  [[ ! -d "${left_dir}" ]] && missing_parts+=("${left_dir}")
  [[ ! -d "${right_dir}" ]] && missing_parts+=("${right_dir}")

  if [[ ${#missing_parts[@]} -gt 0 ]]; then
    echo "Skipping ${case_name}: missing ${missing_parts[*]}"
    echo
    ((skipped_folders+=1))
    skipped_folder_list+=("${case_name} (missing ${missing_parts[*]})")
    return
  fi

  ((total_folders+=1))
  local left_count; left_count=$(count_asm_files "${left_dir}")
  local right_count; right_count=$(count_asm_files "${right_dir}")
  total_asm_files=$((total_asm_files + left_count + right_count))

  local left_label; left_label="$(basename "${LEFT_ROOT}")/${case_name}/${LEFT_SUB}"
  local right_label; right_label="$(basename "${RIGHT_ROOT}")/${case_name}/${RIGHT_SUB}"

  echo "=========================================="
  echo "Comparing: ${case_name}"
  echo "  Left:  ${left_label} (${left_count} files)"
  echo "  Right: ${right_label} (${right_count} files)"
  echo "=========================================="

  run_diff "${left_dir}" "${right_dir}" "${case_name}"
}

if [[ ${CROSS_MODE} -eq 1 ]]; then
  # Collect case folder names from both roots
  declare -A seen_cases
  for root in "${LEFT_ROOT}" "${RIGHT_ROOT}"; do
    for folder in "${root}"/*/; do
      [[ -d "${folder}" ]] || continue
      name="$(basename "${folder%/}")"
      [[ "${name}" == "orig" || "${name}" == "st" ]] && continue
      seen_cases["${name}"]=1
    done
  done

  # Also handle the case where orig/st sit directly under the root (no case subfolder)
  if [[ -d "${LEFT_ROOT}/${LEFT_SUB}" && -d "${RIGHT_ROOT}/${RIGHT_SUB}" ]]; then
    # Check if these are leaf dirs (no case subfolders), treat root itself as a single case
    has_case_folders=0
    for folder in "${LEFT_ROOT}"/*/; do
      [[ -d "${folder}" ]] || continue
      name="$(basename "${folder%/}")"
      [[ "${name}" == "orig" || "${name}" == "st" ]] && continue
      has_case_folders=1
      break
    done
    if [[ ${has_case_folders} -eq 0 ]]; then
      ((total_folders+=1))
      left_count=$(count_asm_files "${LEFT_ROOT}/${LEFT_SUB}")
      right_count=$(count_asm_files "${RIGHT_ROOT}/${RIGHT_SUB}")
      total_asm_files=$((total_asm_files + left_count + right_count))

      left_label="$(basename "${LEFT_ROOT}")/${LEFT_SUB}"
      right_label="$(basename "${RIGHT_ROOT}")/${RIGHT_SUB}"

      echo "=========================================="
      echo "Comparing (single root):"
      echo "  Left:  ${left_label} (${left_count} files)"
      echo "  Right: ${right_label} (${right_count} files)"
      echo "=========================================="

      run_diff "${LEFT_ROOT}/${LEFT_SUB}" "${RIGHT_ROOT}/${RIGHT_SUB}" "$(basename "${LEFT_ROOT}") vs $(basename "${RIGHT_ROOT}")"
    fi
  fi

  for case_name in $(printf '%s\n' "${!seen_cases[@]}" | sort); do
    process_cross_folder "${case_name}"
  done
else
  if [[ -d "${ASM_ROOT}/orig" || -d "${ASM_ROOT}/st" ]]; then
    process_case_folder "${ASM_ROOT}" "$(basename "${ASM_ROOT}")"
  fi

  for folder in "${ASM_ROOT}"/*/; do
    [[ -d "${folder}" ]] || continue
    folder="${folder%/}"
    folder_name="$(basename "${folder}")"
    [[ "${folder_name}" == "orig" || "${folder_name}" == "st" ]] && continue
    process_case_folder "${folder}" "${folder_name}"
  done
fi

echo "=========================================="
echo "STATISTICS"
echo "=========================================="
echo "Total folders processed: ${total_folders}"
echo "  - Folders with differences: ${diff_folders}"
echo "  - Folders with no differences: ${no_diff_folders}"
echo "Total ASM files: ${total_asm_files}"
echo "Folders skipped: ${skipped_folders}"
echo
echo "Folders with differences: ${diff_folder_list[*]:-(none)}"
echo "Folders with no differences: ${no_diff_folder_list[*]:-(none)}"
echo "Skipped folders: ${skipped_folder_list[*]:-(none)}"
echo "Diff comparison completed."
