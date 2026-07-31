#!/usr/bin/env python3
"""
Parse Gfx1250HazardPass xcnt insertion statistics from StinkyTofu test logs.

Each xcnt record in <asm-dir>/<yaml>/<yaml>.log is associated with an assembly
file in <asm-dir>/<yaml>/st by its one-based write order.  That order matches
`ls -alrt`: ascending modification time, then filename for equal timestamps.

Usage:
  scripts/parse_xcnt_stats.py [PATH] [--tensor-load-to-lds]
                              [--top N] [--sort METRIC]
                              [--warning-summary]

PATH may be an asm root (for all yamls), a single yaml directory, or a log
file.  It defaults to this repository's asm/ directory.

Examples:
  # Report every parsed kernel from every yaml below asm/.
  scripts/parse_xcnt_stats.py asm

  # Report every kernel in one yaml directory.
  scripts/parse_xcnt_stats.py asm/1024_vgpr_gfx1250

  # Only kernels that used tensor_load_to_lds.
  scripts/parse_xcnt_stats.py asm --tensor-load-to-lds

  # Top 25 kernels across all yamls by a selected metric.
  scripts/parse_xcnt_stats.py asm --top 25 --sort noLoadLoopBody

  # Group non-repairable SMEM self-overwrite warnings across all yamls.
  scripts/parse_xcnt_stats.py asm --warning-summary

METRIC is one of: total, loopWithPrefetch, noLoadLoopBody, outsideRegions,
atomic, smem, flat, foreverSleep, scalarPrefetch, vgprMsb.
"""

from __future__ import annotations

import argparse
from collections import defaultdict
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path


XCNT_DRAINS_RE = re.compile(r"\[Gfx1250HazardPass\]\s+xcnt drains:\s*(.*)$")
XCNT_RULES_RE = re.compile(r"\[Gfx1250HazardPass\]\s+xcnt drain rules:\s*(.*)$")
TENSOR_LOAD_RE = re.compile(r"\[Gfx1250HazardPass\]\s+tensor_load_to_lds:\s*(.*)$")
KEY_VALUE_RE = re.compile(r"(\w+)=(-?\d+)")
SELF_OVERWRITE_RE = re.compile(
    r'\[Gfx1250HazardPass\]\s+warning:\s+SMEM instruction "([^"]+)" '
    r'in block "([^"]+)" overwrites one of its own source registers; '
    r"s_wait_xcnt cannot repair this register allocation"
)
KERNEL_NAME_RE = re.compile(r"^\.protected\s+(\S+)")

DRAIN_METRICS = ("total", "loopWithPrefetch", "noLoadLoopBody", "outsideRegions")
RULE_METRICS = ("atomic", "smem", "flat", "foreverSleep", "scalarPrefetch", "vgprMsb")
SORT_METRICS = DRAIN_METRICS + RULE_METRICS


@dataclass
class SelfOverwrite:
    instruction: str
    block: str


@dataclass
class XcntRecord:
    yaml: str
    log_path: Path
    record_id: int
    drains: dict[str, int]
    rules: dict[str, int] = field(default_factory=dict)
    tensor_load_to_lds: str = "missing"
    overwrites: list[SelfOverwrite] = field(default_factory=list)
    asm_path: Path | None = None
    kernel_name: str = "<unmapped>"

    @property
    def uses_tensor_load_to_lds(self) -> bool:
        return self.tensor_load_to_lds.strip().lower() != "not used"

    def metric(self, name: str) -> int:
        return self.drains.get(name, self.rules.get(name, 0))


def parse_key_values(text: str) -> dict[str, int]:
    return {key: int(value) for key, value in KEY_VALUE_RE.findall(text)}


def parse_log(log_path: Path, yaml: str) -> list[XcntRecord]:
    records: list[XcntRecord] = []
    pending_overwrites: list[SelfOverwrite] = []
    current: XcntRecord | None = None

    for line in log_path.read_text(encoding="utf-8", errors="replace").splitlines():
        overwrite = SELF_OVERWRITE_RE.search(line)
        if overwrite:
            pending_overwrites.append(
                SelfOverwrite(instruction=overwrite.group(1), block=overwrite.group(2))
            )
            continue

        drains = XCNT_DRAINS_RE.search(line)
        if drains:
            current = XcntRecord(
                yaml=yaml,
                log_path=log_path,
                record_id=len(records) + 1,
                drains=parse_key_values(drains.group(1)),
                overwrites=pending_overwrites,
            )
            records.append(current)
            pending_overwrites = []
            continue

        if current is None:
            continue

        rules = XCNT_RULES_RE.search(line)
        if rules:
            current.rules = parse_key_values(rules.group(1))
            continue

        tensor_load = TENSOR_LOAD_RE.search(line)
        if tensor_load:
            current.tensor_load_to_lds = tensor_load.group(1).strip()
            current = None

    return records


def ls_alrt_order(st_dir: Path) -> list[Path]:
    """Return .s files in the same order as `ls -alrt st/`."""
    return sorted(
        st_dir.glob("*.s"),
        key=lambda path: (path.stat().st_mtime_ns, path.name),
    )


def read_kernel_name(asm_path: Path) -> str:
    with asm_path.open(encoding="utf-8", errors="replace") as asm_file:
        for _ in range(64):
            line = asm_file.readline()
            if not line:
                break
            match = KERNEL_NAME_RE.match(line)
            if match:
                return match.group(1)
    return "<kernel name not found>"


def map_asm_files(records: list[XcntRecord], st_dir: Path) -> list[str]:
    asm_files = ls_alrt_order(st_dir) if st_dir.is_dir() else []
    for record, asm_path in zip(records, asm_files):
        record.asm_path = asm_path
        record.kernel_name = read_kernel_name(asm_path)

    issues: list[str] = []
    if len(records) != len(asm_files):
        issues.append(
            f"{records[0].yaml if records else st_dir.parent.name}: "
            f"{len(records)} xcnt record(s), {len(asm_files)} .s file(s) in {st_dir}"
        )
    return issues


def logs_from_path(path: Path) -> list[Path]:
    if path.is_file():
        return [path]

    direct_logs = sorted(path.glob("*.log"))
    if direct_logs:
        return direct_logs

    logs: list[Path] = []
    for child in sorted(path.iterdir()):
        if child.is_dir():
            logs.extend(sorted(child.glob("*.log")))
    return logs


def load_records(path: Path) -> tuple[list[XcntRecord], list[str]]:
    records: list[XcntRecord] = []
    mapping_issues: list[str] = []
    for log_path in logs_from_path(path):
        yaml = log_path.parent.name
        parsed = parse_log(log_path, yaml)
        mapping_issues.extend(map_asm_files(parsed, log_path.parent / "st"))
        records.extend(parsed)
    return records, mapping_issues


def format_stats(record: XcntRecord) -> list[str]:
    drain_fields = ", ".join(
        f"{metric}={record.drains.get(metric, 0)}" for metric in DRAIN_METRICS
    )
    rule_fields = ", ".join(
        f"{metric}={record.rules.get(metric, 0)}" for metric in RULE_METRICS
    )
    return [
        f"  xcnt drains: {drain_fields}",
        f"  xcnt drain rules: {rule_fields}",
        f"  tensor_load_to_lds: {record.tensor_load_to_lds}",
    ]


def print_record(record: XcntRecord) -> None:
    asm_name = record.asm_path.name if record.asm_path else "<unmapped>"
    print(f"{record.yaml}")
    print(f"  {record.record_id} {asm_name}  {record.kernel_name}")
    print("\n".join(format_stats(record)))
    print(f"  self-overwrite warnings: {len(record.overwrites)}")
    for warning in record.overwrites:
        print(f"    {warning.block} with {warning.instruction}")
    print()


def print_top(records: list[XcntRecord], top: int, metric: str) -> None:
    ranked = sorted(
        records,
        key=lambda record: (record.metric(metric), record.yaml, -record.record_id),
        reverse=True,
    )[:top]
    print(f"Top {len(ranked)} kernels by {metric}:")
    for rank, record in enumerate(ranked, 1):
        asm_name = record.asm_path.name if record.asm_path else "<unmapped>"
        print(
            f"{rank:>3}. {record.yaml}  id={record.record_id}  {asm_name}  "
            f"{metric}={record.metric(metric)}  {record.kernel_name}"
        )
    print()


def print_warning_summary(records: list[XcntRecord]) -> None:
    """Group each SMEM self-overwrite root cause by affected yaml and kernel."""
    causes: dict[tuple[str, str], dict[str, set[int]]] = defaultdict(
        lambda: defaultdict(set)
    )
    for record in records:
        for warning in record.overwrites:
            causes[(warning.block, warning.instruction)][record.yaml].add(record.record_id)

    if not causes:
        print("No non-repairable SMEM self-overwrite warnings found.")
        return

    print("Non-repairable SMEM self-overwrite warning summary:")
    for (block, instruction), yaml_kernels in sorted(
        causes.items(),
        key=lambda item: (
            -sum(len(kernel_ids) for kernel_ids in item[1].values()),
            item[0],
        ),
    ):
        yaml_names = sorted(yaml_kernels)
        kernel_count = sum(len(kernel_ids) for kernel_ids in yaml_kernels.values())
        print(f"\nRoot cause: {block} with {instruction}")
        print(f"  Number of yamls: {len(yaml_names)}; {', '.join(yaml_names)}")
        print(f"  Total kernels: {kernel_count}")
        print("  Per yaml:")
        for yaml in yaml_names:
            print(f"    {yaml}: {len(yaml_kernels[yaml])} kernel(s)")
    print()


def main() -> None:
    repo_root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "path",
        nargs="?",
        type=Path,
        default=repo_root / "asm",
        help="An asm root, one yaml directory, or one .log file (default: %(default)s)",
    )
    parser.add_argument(
        "--tensor-load-to-lds",
        action="store_true",
        help='Only include records whose "tensor_load_to_lds" value is not "not used".',
    )
    parser.add_argument(
        "--top",
        type=int,
        metavar="N",
        help="Show only the top N records using --sort (N must be positive).",
    )
    parser.add_argument(
        "--sort",
        choices=SORT_METRICS,
        default="total",
        help="Metric for --top (default: total).",
    )
    parser.add_argument(
        "--warning-summary",
        action="store_true",
        help="Group SMEM self-overwrite warnings by block and instruction.",
    )
    args = parser.parse_args()

    if not args.path.exists():
        parser.error(f"path does not exist: {args.path}")
    if args.top is not None and args.top <= 0:
        parser.error("--top must be positive")
    if args.warning_summary and args.top is not None:
        parser.error("--warning-summary cannot be combined with --top")

    records, mapping_issues = load_records(args.path)
    if args.tensor_load_to_lds:
        records = [record for record in records if record.uses_tensor_load_to_lds]

    if not records:
        filter_description = " matching the requested filter" if args.tensor_load_to_lds else ""
        raise SystemExit(f"No xcnt records found{filter_description}.")

    if args.warning_summary:
        print_warning_summary(records)
    elif args.top is None:
        for record in records:
            print_record(record)
    else:
        print_top(records, args.top, args.sort)

    if mapping_issues:
        print("Assembly mapping warnings:", file=sys.stderr)
        for issue in mapping_issues:
            print(f"  {issue}", file=sys.stderr)


if __name__ == "__main__":
    main()
