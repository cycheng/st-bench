#!/usr/bin/env python3
"""
Parse Gfx1250HazardPass xcnt insertion statistics from StinkyTofu test logs.

Each xcnt record in <asm-dir>/<yaml>/<yaml>.log is associated with an assembly
file in <asm-dir>/<yaml>/st by its one-based write order.  That order matches
`ls -alrt`: ascending modification time, then filename for equal timestamps.

The pass reports one record as up to three scopes: "whole kernel" always, plus
the "kernel body"/"helper functions" split when the kernel calls helpers.  All
filtering and sorting here uses the whole-kernel numbers; the split is shown as
extra lines.  Logs written before the split existed carry no scope prefix and
are read as whole-kernel records.

Usage:
  scripts/parse_xcnt_stats.py [PATH] [--has-rule RULE]
                              [--tensor-load-to-lds | --no-tensor-load-to-lds]
                              [--top N] [--sort METRIC]
                              [--rule-summary] [--yaml-summary]
                              [--warning-summary]

PATH may be an asm root (for all yamls), a single yaml directory, or a log
file.  It defaults to this repository's asm/ directory.

Examples:
  # Report every parsed kernel from every yaml below asm/.
  scripts/parse_xcnt_stats.py asm

  # Report every kernel in one yaml directory.
  scripts/parse_xcnt_stats.py asm/1024_vgpr_gfx1250

  # Only kernels that used tensor_load_to_lds (or only those that did not).
  scripts/parse_xcnt_stats.py asm --tensor-load-to-lds
  scripts/parse_xcnt_stats.py asm --no-tensor-load-to-lds

  # Top 25 kernels across all yamls by a selected metric.
  scripts/parse_xcnt_stats.py asm --top 25 --sort other

  # Which drain rules fire at all, and over how many kernels and yamls.
  scripts/parse_xcnt_stats.py asm --rule-summary

  # Per yaml, how many kernels need no xcnt drain at all.
  scripts/parse_xcnt_stats.py asm --yaml-summary

  # Worst kernels among those that drain for a reason other than vgprMsb.
  scripts/parse_xcnt_stats.py asm --has-rule smem --top 25 --sort smem

  # Group non-repairable SMEM self-overwrite warnings across all yamls.
  scripts/parse_xcnt_stats.py asm --warning-summary

METRIC is one of: total, loop+matrix, loop, matrix, other, atomic, smem,
flat, foreverSleep, scalarPrefetch, vgprMsb.  RULE is one of the six rule
names in that list.
"""

from __future__ import annotations

import argparse
from collections import defaultdict
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path


XCNT_DRAINS_RE = re.compile(r"\[Gfx1250HazardPass\]\s+(.*?)xcnt drains:\s*(.*)$")
XCNT_RULES_RE = re.compile(r"\[Gfx1250HazardPass\]\s+(.*?)xcnt drain rules:\s*(.*)$")
TENSOR_LOAD_RE = re.compile(r"\[Gfx1250HazardPass\]\s+(.*?)tensor_load_to_lds:\s*(.*)$")
KEY_VALUE_RE = re.compile(r"([^=,\s]+)=(-?\d+)")
SELF_OVERWRITE_RE = re.compile(
    r'\[Gfx1250HazardPass\]\s+warning:\s+SMEM instruction "([^"]+)" '
    r'in block "([^"]+)" overwrites one of its own source registers; '
    r"s_wait_xcnt cannot repair this register allocation"
)
KERNEL_NAME_RE = re.compile(r"^\.protected\s+(\S+)")

DRAIN_METRICS = (
    "total",
    "loop+matrix",
    "loop",
    "matrix",
    "other",
)
RULE_METRICS = ("atomic", "smem", "flat", "foreverSleep", "scalarPrefetch", "vgprMsb")
SORT_METRICS = DRAIN_METRICS + RULE_METRICS

WHOLE_KERNEL = "whole kernel"
KERNEL_BODY = "kernel body"
HELPER_FUNCTIONS = "helper functions"
SCOPE_ORDER = (WHOLE_KERNEL, KERNEL_BODY, HELPER_FUNCTIONS)


@dataclass
class SelfOverwrite:
    instruction: str
    block: str


@dataclass
class ScopeStats:
    """The three log lines the pass prints for one scope of one kernel."""

    drains: dict[str, int] = field(default_factory=dict)
    rules: dict[str, int] = field(default_factory=dict)
    tensor_load_to_lds: str = "missing"


@dataclass
class XcntRecord:
    yaml: str
    log_path: Path
    record_id: int
    scopes: dict[str, ScopeStats] = field(default_factory=dict)
    overwrites: list[SelfOverwrite] = field(default_factory=list)
    asm_path: Path | None = None
    kernel_name: str = "<unmapped>"

    def scope(self, name: str) -> ScopeStats:
        return self.scopes.setdefault(name, ScopeStats())

    @property
    def whole_kernel(self) -> ScopeStats:
        return self.scopes.get(WHOLE_KERNEL, ScopeStats())

    @property
    def drains(self) -> dict[str, int]:
        return self.whole_kernel.drains

    @property
    def rules(self) -> dict[str, int]:
        return self.whole_kernel.rules

    @property
    def tensor_load_to_lds(self) -> str:
        return self.whole_kernel.tensor_load_to_lds

    def ordered_scopes(self) -> list[tuple[str, ScopeStats]]:
        known = [name for name in SCOPE_ORDER if name in self.scopes]
        unknown = sorted(set(self.scopes).difference(SCOPE_ORDER))
        return [(name, self.scopes[name]) for name in known + unknown]

    @property
    def uses_tensor_load_to_lds(self) -> bool:
        return self.tensor_load_to_lds.strip().lower() != "not used"

    def metric(self, name: str) -> int:
        return self.drains.get(name, self.rules.get(name, 0))


def parse_key_values(text: str) -> dict[str, int]:
    return {key: int(value) for key, value in KEY_VALUE_RE.findall(text)}


def parse_scope(prefix: str) -> str:
    """Logs older than the body/helper split print no scope: those are totals."""
    return prefix.strip() or WHOLE_KERNEL


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
            scope = parse_scope(drains.group(1))
            # Every kernel reports its whole-kernel scope first, so that line is
            # what separates one kernel's report from the next.
            if scope == WHOLE_KERNEL or current is None:
                current = XcntRecord(
                    yaml=yaml,
                    log_path=log_path,
                    record_id=len(records) + 1,
                    overwrites=pending_overwrites,
                )
                records.append(current)
                pending_overwrites = []
            current.scope(scope).drains = parse_key_values(drains.group(2))
            continue

        if current is None:
            continue

        rules = XCNT_RULES_RE.search(line)
        if rules:
            current.scope(parse_scope(rules.group(1))).rules = parse_key_values(rules.group(2))
            continue

        tensor_load = TENSOR_LOAD_RE.search(line)
        if tensor_load:
            current.scope(parse_scope(tensor_load.group(1))).tensor_load_to_lds = (
                tensor_load.group(2).strip()
            )

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


def ordered_metric_names(
    metric_dicts: list[dict[str, int]], preferred_order: tuple[str, ...]
) -> tuple[str, ...]:
    """Order present metrics predictably while preserving future log fields."""
    present = {metric for metrics in metric_dicts for metric in metrics}
    known = tuple(metric for metric in preferred_order if metric in present)
    unknown = tuple(sorted(present.difference(preferred_order)))
    return known + unknown


def format_metrics(
    values: dict[str, int], preferred_order: tuple[str, ...], omit_zero: bool
) -> str:
    fields = [
        f"{metric}={values.get(metric, 0)}"
        for metric in ordered_metric_names([values], preferred_order)
        if not omit_zero or values.get(metric, 0) != 0
    ]
    return ", ".join(fields) or "(all zero)"


def format_scope(
    scope: str,
    stats: ScopeStats,
    omit_zero: bool = False,
    with_tensor_load: bool = True,
    note: str = "",
) -> list[str]:
    label = f"{scope}{note}"
    lines = [
        f"  {label} xcnt drains: {format_metrics(stats.drains, DRAIN_METRICS, omit_zero)}",
        f"  {label} xcnt drain rules: {format_metrics(stats.rules, RULE_METRICS, omit_zero)}",
    ]
    if with_tensor_load:
        lines.append(f"  {label} tensor_load_to_lds: {stats.tensor_load_to_lds}")
    return lines


def scope_is_empty(stats: ScopeStats, with_tensor_load: bool) -> bool:
    if any(stats.drains.values()) or any(stats.rules.values()):
        return False
    # A scope that runs a tensor load without needing a drain is still worth
    # showing, but only where the tensor load line is reported at all.
    if with_tensor_load:
        return stats.tensor_load_to_lds.strip().lower() in ("not used", "missing")
    return True


def format_stats(
    record: XcntRecord, omit_zero: bool = False, with_tensor_load: bool = True
) -> list[str]:
    scopes = record.ordered_scopes()
    body = record.scopes.get(KERNEL_BODY)
    helpers = record.scopes.get(HELPER_FUNCTIONS)
    note = ""

    # Whole kernel is body plus helpers, so an empty half leaves the other half
    # a verbatim copy of the whole-kernel lines.
    if body is not None and helpers is not None:
        body_empty = scope_is_empty(body, with_tensor_load)
        helpers_empty = scope_is_empty(helpers, with_tensor_load)
        if body_empty or helpers_empty:
            scopes = [(scope, stats) for scope, stats in scopes if scope == WHOLE_KERNEL]
            if not body_empty:
                note = " (all from kernel body)"
            elif not helpers_empty:
                note = " (all from helper functions)"

    lines: list[str] = []
    for scope, stats in scopes:
        lines.extend(
            format_scope(
                scope, stats, omit_zero, with_tensor_load, note if scope == WHOLE_KERNEL else ""
            )
        )
    return lines


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
    drain_metrics = ordered_metric_names(
        [record.drains for record in records], DRAIN_METRICS
    )
    rule_metrics = ordered_metric_names([record.rules for record in records], RULE_METRICS)
    print(f"Top {len(ranked)} kernels by whole-kernel {metric}:")
    print(f"Drain regions (zero values omitted below): {', '.join(drain_metrics)}")
    print(f"Drain rules (zero values omitted below): {', '.join(rule_metrics)}")
    print()
    for rank, record in enumerate(ranked, 1):
        asm_name = record.asm_path.name if record.asm_path else "<unmapped>"
        print(
            f"{rank:>3}. {record.yaml}  id={record.record_id}  {asm_name}  "
            f"{metric}={record.metric(metric)}  {record.kernel_name}"
        )
        # Keep top-N output actionable: show the complete drain and rule
        # breakdown, rather than only the metric used for ranking.
        print("\n".join(format_stats(record, omit_zero=True, with_tensor_load=False)))
        print()


def print_rule_summary(records: list[XcntRecord]) -> None:
    """Show which drain rules actually fire, and how widely."""
    rule_metrics = ordered_metric_names([record.rules for record in records], RULE_METRICS)
    drains: dict[str, int] = defaultdict(int)
    kernels: dict[str, int] = defaultdict(int)
    yamls: dict[str, set[str]] = defaultdict(set)

    for record in records:
        for rule in rule_metrics:
            count = record.rules.get(rule, 0)
            if count == 0:
                continue
            drains[rule] += count
            kernels[rule] += 1
            yamls[rule].add(record.yaml)

    print(f"Drain rule summary over {len(records)} kernels:")
    print(f"  {'rule':<16}{'drains':>10}{'kernels':>10}{'yamls':>8}")
    for rule in sorted(rule_metrics, key=lambda name: -drains[name]):
        print(f"  {rule:<16}{drains[rule]:>10}{kernels[rule]:>10}{len(yamls[rule]):>8}")

    silent = [rule for rule in rule_metrics if drains[rule] == 0]
    if silent:
        print(f"Rules that never fire: {', '.join(silent)}")
    print()


def print_yaml_summary(records: list[XcntRecord]) -> None:
    """Per yaml, how many kernels need no drain at all."""
    kernels: dict[str, int] = defaultdict(int)
    drain_free: dict[str, int] = defaultdict(int)
    drains: dict[str, int] = defaultdict(int)

    for record in records:
        total = record.metric("total")
        kernels[record.yaml] += 1
        drains[record.yaml] += total
        if total == 0:
            drain_free[record.yaml] += 1

    free_total = sum(drain_free.values())
    print(f"Per-yaml summary over {len(records)} kernels in {len(kernels)} yamls:")
    print(f"  {'yaml':<34}{'kernels':>9}{'no drain':>10}{'drains':>10}")
    for yaml in sorted(kernels, key=lambda name: (-drain_free[name], name)):
        print(
            f"  {yaml:<34}{kernels[yaml]:>9}{drain_free[yaml]:>10}{drains[yaml]:>10}"
        )

    share = free_total / len(records) * 100 if records else 0.0
    print(f"Kernels needing no xcnt drain: {free_total} of {len(records)} ({share:.1f}%)")
    print(f"Yamls where every kernel is drain free: {sum(1 for y in kernels if drain_free[y] == kernels[y])}")
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
    tensor_load = parser.add_mutually_exclusive_group()
    tensor_load.add_argument(
        "--tensor-load-to-lds",
        action="store_true",
        help='Only include records whose "tensor_load_to_lds" value is not "not used".',
    )
    tensor_load.add_argument(
        "--no-tensor-load-to-lds",
        action="store_true",
        help="Only include records that did not use tensor_load_to_lds.",
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
        help="Whole-kernel metric for --top (default: total).",
    )
    parser.add_argument(
        "--has-rule",
        action="append",
        choices=RULE_METRICS,
        metavar="RULE",
        help="Only include kernels with a non-zero drain from RULE (repeatable).",
    )
    parser.add_argument(
        "--rule-summary",
        action="store_true",
        help="Report which drain rules fire, with drain, kernel, and yaml counts.",
    )
    parser.add_argument(
        "--yaml-summary",
        action="store_true",
        help="Per yaml, report kernel count, kernels needing no drain, and total drains.",
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
    summaries = sum([args.rule_summary, args.yaml_summary, args.warning_summary])
    if summaries > 1:
        parser.error("--rule-summary, --yaml-summary, and --warning-summary are exclusive")
    if summaries and args.top is not None:
        parser.error("a summary cannot be combined with --top")

    records, mapping_issues = load_records(args.path)
    if args.tensor_load_to_lds:
        records = [record for record in records if record.uses_tensor_load_to_lds]
    if args.no_tensor_load_to_lds:
        records = [record for record in records if not record.uses_tensor_load_to_lds]
    if args.has_rule:
        records = [
            record
            for record in records
            if any(record.rules.get(rule, 0) for rule in args.has_rule)
        ]

    if not records:
        filtered = args.tensor_load_to_lds or args.no_tensor_load_to_lds or args.has_rule
        filter_description = " matching the requested filter" if filtered else ""
        raise SystemExit(f"No xcnt records found{filter_description}.")

    if args.rule_summary:
        print_rule_summary(records)
    elif args.yaml_summary:
        print_yaml_summary(records)
    elif args.warning_summary:
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
