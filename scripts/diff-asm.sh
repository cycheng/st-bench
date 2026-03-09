#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Compare asm folder pairs:
  1) <root>/orig vs <root>/st
  2) <root>/<case>/orig vs <root>/<case>/st

Usage:
  scripts/diff-asm.sh [--asm-root <dir>] [--side-by-side]

Options:
  --asm-root <dir>     Root directory that contains case folders (default: ./asm)
  --side-by-side       Use side-by-side diff output (default: recursive brief diff)
  -h, --help           Show help
EOF
}

ASM_ROOT="./asm"
SIDE_BY_SIDE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --asm-root) ASM_ROOT="$2"; shift 2 ;;
    --side-by-side) SIDE_BY_SIDE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -d "${ASM_ROOT}" ]]; then
  echo "Error: asm root does not exist: ${ASM_ROOT}" >&2
  exit 1
fi

total_folders=0
diff_folders=0
no_diff_folders=0
skipped_folders=0
total_asm_files=0

diff_folder_list=()
no_diff_folder_list=()
skipped_folder_list=()

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
  orig_count=$(find "${orig_dir}" -type f \( -name "*.s" -o -name "*.asm" \) | wc -l)
  st_count=$(find "${st_dir}" -type f \( -name "*.s" -o -name "*.asm" \) | wc -l)
  total_asm_files=$((total_asm_files + orig_count + st_count))

  echo "=========================================="
  echo "Comparing: ${folder_name}"
  echo "Files: ${orig_count} (orig) + ${st_count} (st)"
  echo "=========================================="

  set +e
  if [[ ${SIDE_BY_SIDE} -eq 1 ]]; then
    (cd "${folder}" && diff -y --suppress-common-lines -W 200 -b orig st)
  else
    diff -qr -b "${orig_dir}" "${st_dir}"
  fi
  diff_status=$?
  set -e

  if [[ ${diff_status} -eq 0 ]]; then
    echo "No differences found in ${folder_name}"
    ((no_diff_folders+=1))
    no_diff_folder_list+=("${folder_name}")
  elif [[ ${diff_status} -eq 1 ]]; then
    echo "Differences found in ${folder_name}"
    ((diff_folders+=1))
    diff_folder_list+=("${folder_name}")
  else
    echo "Error while diffing ${folder_name}"
  fi
  echo
}

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
