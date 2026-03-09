#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Compare asm folder pairs:
  <root>/<case>/orig  vs  <root>/<case>/st

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

for folder in "${ASM_ROOT}"/*/; do
  [[ -d "${folder}" ]] || continue
  folder="${folder%/}"
  folder_name="$(basename "${folder}")"
  orig_dir="${folder}/orig"
  st_dir="${folder}/st"

  if [[ ! -d "${orig_dir}" || ! -d "${st_dir}" ]]; then
    ((skipped_folders++))
    if [[ ! -d "${orig_dir}" && ! -d "${st_dir}" ]]; then
      skipped_folder_list+=("${folder_name} (missing orig and st)")
    elif [[ ! -d "${orig_dir}" ]]; then
      skipped_folder_list+=("${folder_name} (missing orig)")
    else
      skipped_folder_list+=("${folder_name} (missing st)")
    fi
    continue
  fi

  ((total_folders++))

  orig_count=$(find "${orig_dir}" -type f \( -name "*.s" -o -name "*.asm" \) | wc -l)
  st_count=$(find "${st_dir}" -type f \( -name "*.s" -o -name "*.asm" \) | wc -l)
  total_asm_files=$((total_asm_files + orig_count + st_count))

  echo "=========================================="
  echo "Comparing: ${folder_name}"
  echo "Files: ${orig_count} (orig) + ${st_count} (st)"
  echo "=========================================="

  set +e
  if [[ ${SIDE_BY_SIDE} -eq 1 ]]; then
    diff -y --suppress-common-lines -W 200 -b "${orig_dir}" "${st_dir}"
  else
    diff -qr -b "${orig_dir}" "${st_dir}"
  fi
  diff_status=$?
  set -e

  if [[ ${diff_status} -eq 0 ]]; then
    ((no_diff_folders++))
    no_diff_folder_list+=("${folder_name}")
  elif [[ ${diff_status} -eq 1 ]]; then
    ((diff_folders++))
    diff_folder_list+=("${folder_name}")
  else
    echo "Error while diffing ${folder_name}"
  fi

  echo
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
