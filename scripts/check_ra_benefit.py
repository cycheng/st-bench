#!/usr/bin/env python3
"""
Scan asm/ test logs and report Register Allocation (RA) benefit numbers
emitted by EstimateRegisterUsagePass.

For every test directory under ``asm/`` that contains ``<name>/<name>.log``,
this script:

  * Parses every ``[EstimateRegisterUsage] kernel="kernel_name"`` block.
    Each block represents one valid solution and may include:
      - basicBlocks
      - MacroTile=MTxxxxxxxxx (optional - may be missing)
      - MatrixInstruction=[...] (optional)
      - LdsNumBytes (optional)
      - "VGPR:  peakLive=...  maxIdxTouched=...  declared=...  metadataFix=... raGain=...  potentialSaving=... (PCT%)"
      - "SGPR:  ..." (same shape)

  * Parses every ``Tensile::WARNING: ... overflowed resources. ...`` line.
    Each warning embeds the kernel name (which contains ``_MTxxxx_``) plus
    ``errorCode=N, msg="...", vgprs=N, sgprs=N``.

  * Associates each overflow warning with the EstimateRegisterUsage block
    whose ``VGPR.declared == warning.vgprs`` and
    ``SGPR.declared == warning.sgprs``.  In practice the overflow line is
    emitted right before the block it describes, but we match on the
    declared values so the script is robust to layout changes.

The per-yaml report lists every solution and, if the solution overflowed
also prints the overflow line.  A per-yaml summary lists the top-N and
down-N solutions by VGPR potentialSaving and by SGPR potentialSaving.

Optionally, ``--top-output`` and ``--down-output`` write summary-only
files containing just the per-yaml top / down rankings (handy for quick
review without scrolling through every block).  Use ``--global-top`` to
make those files rank across all yamls combined instead of per yaml.

Usage:
  scripts/check_ra_benefit.py [--asm-dir PATH] [--output FILE]
                              [--top-output FILE] [--down-output FILE]
                              [--global-top]
                              [--tests name [name ...]] [--top N] [--json]

Defaults:
  --asm-dir = <repo>/asm   (relative to this script's parent directory)
  --output  = <repo>/ra_benefit_report.txt
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field, asdict
from pathlib import Path


# --- Regexes ----------------------------------------------------------------

ESTIMATE_HEADER_RE = re.compile(r'^\[EstimateRegisterUsage\] kernel="[^"]*"\s*$')
BASIC_BLOCKS_RE = re.compile(r"^\s*basicBlocks=(\d+)\s*$")
MACRO_TILE_RE = re.compile(r"^\s*MacroTile=(MT\d+x\d+x\d+)\b(.*)$")
MATRIX_INSTR_RE = re.compile(r"^\s*MatrixInstruction=\[([^\]]+)\]\s*$")
LDS_BYTES_RE = re.compile(r"^\s*LdsNumBytes=(\d+)\s*$")

# "  VGPR:  peakLive=135  maxIdxTouched=194  declared=220  metadataFix=26 ..."
REG_STATS_RE = re.compile(
    r"^\s*(VGPR|SGPR):\s+"
    r"peakLive=(\d+)\s+"
    r"maxIdxTouched=(\d+)\s+"
    r"declared=(\d+)\s+"
    r"metadataFix=(-?\d+)\s+"
    r"raGain=(-?\d+)\s+"
    r"potentialSaving=(-?\d+)\s*"
    r"\(([-0-9.eE+]+)%\)\s*$"
)

# "Tensile::WARNING: ... overflowed resources. errorCode=N, msg=\"...\", vgprs=N, sgprs=N"
# May be prefixed by a backspace ('\x08') and/or a single progress char like
# '/' '|' '-' '\' as we sometimes see in the raw logs.
OVERFLOW_RE = re.compile(
    r'Tensile::WARNING:\s+(\S+)\s+overflowed\s+resources\.\s+'
    r'errorCode=(\S+?),\s*msg="([^"]*)",\s*vgprs=(\d+),\s*sgprs=(\d+)'
)

MT_IN_KERNEL_RE = re.compile(r"_MT(\d+x\d+x\d+)(?:_|$)")
LEGEND_END_RE = re.compile(r"^\s*potentialSaving\s*=\s*declared\b")


# --- Data classes ----------------------------------------------------------


@dataclass
class RegStats:
    kind: str  # "VGPR" or "SGPR"
    peakLive: int
    maxIdxTouched: int
    declared: int
    metadataFix: int
    raGain: int
    potentialSaving: int
    potentialSavingPct: float

    @property
    def short(self) -> str:
        return (
            f"{self.kind}:  peakLive={self.peakLive}  "
            f"maxIdxTouched={self.maxIdxTouched}  "
            f"declared={self.declared}  "
            f"metadataFix={self.metadataFix}  "
            f"raGain={self.raGain}  "
            f"potentialSaving={self.potentialSaving} "
            f"({self.potentialSavingPct:g}%)"
        )


@dataclass
class Overflow:
    kernel: str
    mt: str | None
    error_code: str
    msg: str
    vgprs: int
    sgprs: int
    raw: str  # the entire warning line, trimmed

    @property
    def short(self) -> str:
        return (
            f'overflowed resources.  errorCode={self.error_code}, '
            f'msg="{self.msg}", vgprs={self.vgprs}, sgprs={self.sgprs}'
        )


@dataclass
class Solution:
    index: int  # 1-based, per log
    line_no: int  # 1-based location of the [EstimateRegisterUsage] header
    basic_blocks: int | None = None
    macro_tile: str | None = None
    matrix_instruction: str | None = None
    lds_num_bytes: int | None = None
    vgpr: RegStats | None = None
    sgpr: RegStats | None = None
    overflow: Overflow | None = None

    @property
    def display_mt(self) -> str:
        if self.macro_tile:
            return self.macro_tile
        if self.overflow and self.overflow.mt:
            return self.overflow.mt
        return "MT?"


@dataclass
class LogReport:
    name: str
    log_path: Path
    solutions: list[Solution] = field(default_factory=list)
    orphan_overflows: list[Overflow] = field(default_factory=list)


# --- Parsing ---------------------------------------------------------------


def _parse_solution_block(lines: list[str], start: int) -> tuple[Solution, int]:
    """Parse one [EstimateRegisterUsage] block starting at ``start``.

    Returns the populated :class:`Solution` and the index of the first line
    after the block (the line *after* the Legend's ``potentialSaving`` line,
    or after the VGPR/SGPR pair if the legend is missing).
    """
    sol = Solution(index=-1, line_no=start + 1)
    n = len(lines)
    i = start + 1
    # The body is small (handful of lines).  Cap a hard upper bound so we
    # never run away if the log is truncated.
    upper = min(n, start + 25)
    seen_legend_end = False
    while i < upper:
        line = lines[i]
        if ESTIMATE_HEADER_RE.match(line):
            # New block - stop here.
            break
        if LEGEND_END_RE.match(line):
            seen_legend_end = True
            i += 1
            break
        m = BASIC_BLOCKS_RE.match(line)
        if m:
            sol.basic_blocks = int(m.group(1))
            i += 1
            continue
        m = MACRO_TILE_RE.match(line)
        if m:
            sol.macro_tile = m.group(1)
            i += 1
            continue
        m = MATRIX_INSTR_RE.match(line)
        if m:
            sol.matrix_instruction = m.group(1).strip()
            i += 1
            continue
        m = LDS_BYTES_RE.match(line)
        if m:
            sol.lds_num_bytes = int(m.group(1))
            i += 1
            continue
        m = REG_STATS_RE.match(line)
        if m:
            stats = RegStats(
                kind=m.group(1),
                peakLive=int(m.group(2)),
                maxIdxTouched=int(m.group(3)),
                declared=int(m.group(4)),
                metadataFix=int(m.group(5)),
                raGain=int(m.group(6)),
                potentialSaving=int(m.group(7)),
                potentialSavingPct=float(m.group(8)),
            )
            if stats.kind == "VGPR":
                sol.vgpr = stats
            else:
                sol.sgpr = stats
            i += 1
            continue
        i += 1
    # If we did not see the legend end line we still return the block as-is.
    _ = seen_legend_end
    return sol, i


def _find_next_warning_in_window(lines: list[str], start: int, end: int) -> Overflow | None:
    """Look for a Tensile overflow warning in the window ``[start, end)``."""
    for j in range(start, min(end, len(lines))):
        m = OVERFLOW_RE.search(lines[j])
        if not m:
            continue
        kernel = m.group(1)
        mt_match = MT_IN_KERNEL_RE.search(kernel)
        mt = ("MT" + mt_match.group(1)) if mt_match else None
        # vgprs / sgprs default to 0 if the regex group is empty - guard with int().
        return Overflow(
            kernel=kernel,
            mt=mt,
            error_code=m.group(2),
            msg=m.group(3),
            vgprs=int(m.group(4)),
            sgprs=int(m.group(5)),
            raw=lines[j].strip(),
        )
    return None


def parse_log(log_path: Path) -> LogReport:
    try:
        text = log_path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        print(f"warning: failed to read {log_path}: {exc}", file=sys.stderr)
        return LogReport(name=log_path.stem, log_path=log_path)

    lines = text.splitlines()
    n = len(lines)

    report = LogReport(name=log_path.stem, log_path=log_path)

    # First pass: identify all [EstimateRegisterUsage] header positions.
    header_indices: list[int] = []
    for i, ln in enumerate(lines):
        if ESTIMATE_HEADER_RE.match(ln):
            header_indices.append(i)

    # Parse the body of each block.
    solutions: list[Solution] = []
    block_ends: list[int] = []  # 0-based first line AFTER each block
    for k, start in enumerate(header_indices):
        sol, end_idx = _parse_solution_block(lines, start)
        sol.index = k + 1
        solutions.append(sol)
        block_ends.append(end_idx)

    # Collect every overflow warning along with its line index for matching.
    overflows: list[tuple[int, Overflow]] = []
    for i in range(n):
        m = OVERFLOW_RE.search(lines[i])
        if not m:
            continue
        kernel = m.group(1)
        mt_match = MT_IN_KERNEL_RE.search(kernel)
        mt = ("MT" + mt_match.group(1)) if mt_match else None
        overflows.append(
            (
                i,
                Overflow(
                    kernel=kernel,
                    mt=mt,
                    error_code=m.group(2),
                    msg=m.group(3),
                    vgprs=int(m.group(4)),
                    sgprs=int(m.group(5)),
                    raw=lines[i].strip(),
                ),
            )
        )

    # Match overflow warnings to solutions.  Strategy:
    #   1. Prefer the solution whose VGPR.declared == warning.vgprs and
    #      SGPR.declared == warning.sgprs.  Among those, pick the one
    #      closest to the warning by line number that has not already been
    #      claimed.
    #   2. Fallback: attach to the next un-claimed block after the warning.
    used_solution_ids: set[int] = set()
    for warn_line, warn in overflows:
        # Build candidates ordered by abs(distance) from the warning.
        candidates_exact: list[tuple[int, int]] = []  # (distance, sol_index)
        candidates_partial: list[tuple[int, int]] = []
        for idx, sol in enumerate(solutions):
            if idx in used_solution_ids:
                continue
            if not sol.vgpr or not sol.sgpr:
                continue
            dist = abs(sol.line_no - 1 - warn_line)
            if sol.vgpr.declared == warn.vgprs and sol.sgpr.declared == warn.sgprs:
                candidates_exact.append((dist, idx))
            elif sol.vgpr.declared == warn.vgprs or sol.sgpr.declared == warn.sgprs:
                candidates_partial.append((dist, idx))

        chosen = None
        if candidates_exact:
            candidates_exact.sort()
            chosen = candidates_exact[0][1]
        elif candidates_partial:
            candidates_partial.sort()
            chosen = candidates_partial[0][1]
        else:
            # Final fallback: first un-claimed block after the warning.
            for idx, sol in enumerate(solutions):
                if idx in used_solution_ids:
                    continue
                if sol.line_no - 1 > warn_line:
                    chosen = idx
                    break

        if chosen is not None:
            solutions[chosen].overflow = warn
            used_solution_ids.add(chosen)
        else:
            report.orphan_overflows.append(warn)

    report.solutions = solutions
    return report


# --- Reporting -------------------------------------------------------------


def _fmt_lds(b: int | None) -> str:
    return "" if b is None else f"  LdsNumBytes={b}"


def _render_solution(sol: Solution) -> list[str]:
    out: list[str] = []
    header = f"  [#{sol.index}] {sol.display_mt}"
    if sol.basic_blocks is not None:
        header += f"  basicBlocks={sol.basic_blocks}"
    if sol.matrix_instruction:
        header += f"  MatrixInstruction=[{sol.matrix_instruction}]"
    header += _fmt_lds(sol.lds_num_bytes)
    out.append(header)
    if sol.vgpr:
        out.append(f"    {sol.vgpr.short}")
    else:
        out.append("    VGPR:  <missing>")
    if sol.sgpr:
        out.append(f"    {sol.sgpr.short}")
    else:
        out.append("    SGPR:  <missing>")
    if sol.overflow:
        out.append(f"    {sol.overflow.short}")
    return out


def _rank_top_down(
    sols: list[Solution], kind: str, k: int = 3
) -> tuple[list[Solution], list[Solution]]:
    """Return ``(top_k, down_k)`` solutions ranked by potentialSaving for ``kind``."""

    def key_fn(s: Solution) -> int:
        stats = s.vgpr if kind == "VGPR" else s.sgpr
        return stats.potentialSaving if stats is not None else -10**9

    valid = [s for s in sols if (s.vgpr if kind == "VGPR" else s.sgpr) is not None]
    valid.sort(key=key_fn, reverse=True)
    top = valid[:k]
    down = list(reversed(valid[-k:]))  # smallest first
    return top, down


def _render_rank_entry(
    sol: Solution, kind: str, *, owner: str | None = None
) -> str:
    stats = sol.vgpr if kind == "VGPR" else sol.sgpr
    prefix = f"[{owner}] " if owner else ""
    if stats is None:
        return f"    {prefix}[#{sol.index}] {sol.display_mt}  (no {kind} info)"
    suffix = ""
    if sol.overflow:
        suffix = f"  [OVERFLOW: {sol.overflow.msg}]"
    return (
        f"    {prefix}[#{sol.index}] {sol.display_mt}  "
        f"potentialSaving={stats.potentialSaving} "
        f"({stats.potentialSavingPct:g}%)  "
        f"peakLive={stats.peakLive}  declared={stats.declared}{suffix}"
    )


def render_report(reports: list[LogReport], top_n: int = 3) -> str:
    out: list[str] = []
    out.append("=" * 80)
    out.append(f"Register Allocation Benefit Report  ({len(reports)} test(s))")
    out.append("=" * 80)
    out.append("")
    out.append("Legend (per the original log):")
    out.append("    peakLive        = peak simultaneously-live physical regs (CFG dataflow)")
    out.append("    maxIdxTouched   = max(reg.idx + reg.num); minimum legal amdhsa_next_free_*")
    out.append("    declared        = amdhsa_next_free_* read from the kernel descriptor")
    out.append("    metadataFix     = declared - maxIdxTouched   (free win, no codegen change)")
    out.append("    raGain          = maxIdxTouched - peakLive   (saving a real RA could give)")
    out.append("    potentialSaving = declared - peakLive        (overall headroom)")
    out.append("")

    for r in reports:
        out.append("=" * 80)
        out.append(f"### {r.name}")
        out.append(f"log: {r.log_path}")
        out.append(f"solutions: {len(r.solutions)}")
        if r.orphan_overflows:
            out.append(f"orphan overflow warnings: {len(r.orphan_overflows)}")
        out.append("-" * 80)

        if not r.solutions:
            out.append("  (no [EstimateRegisterUsage] blocks found)")
            for w in r.orphan_overflows:
                out.append(f"  ! {w.mt or 'MT?'}: {w.short}")
            out.append("")
            continue

        for sol in r.solutions:
            out.extend(_render_solution(sol))
            out.append("")

        for w in r.orphan_overflows:
            out.append(f"  ! unmatched overflow: {w.mt or 'MT?'}: {w.short}")
        if r.orphan_overflows:
            out.append("")

        # Summary -----------------------------------------------------
        out.append(f"--- Summary for {r.name} ---")
        for kind in ("VGPR", "SGPR"):
            top, down = _rank_top_down(r.solutions, kind, top_n)
            out.append(f"  Top {len(top)} {kind} potentialSaving:")
            if not top:
                out.append("    (none)")
            for s in top:
                out.append(_render_rank_entry(s, kind))
            out.append(f"  Down {len(down)} {kind} potentialSaving:")
            if not down:
                out.append("    (none)")
            for s in down:
                out.append(_render_rank_entry(s, kind))
        out.append("")

    return "\n".join(out) + "\n"


def render_json(reports: list[LogReport], top_n: int = 3) -> str:
    payload: list[dict] = []
    for r in reports:
        solutions_json = []
        for sol in r.solutions:
            entry: dict = {
                "index": sol.index,
                "line_no": sol.line_no,
                "macro_tile": sol.macro_tile,
                "macro_tile_display": sol.display_mt,
                "basic_blocks": sol.basic_blocks,
                "matrix_instruction": sol.matrix_instruction,
                "lds_num_bytes": sol.lds_num_bytes,
                "vgpr": asdict(sol.vgpr) if sol.vgpr else None,
                "sgpr": asdict(sol.sgpr) if sol.sgpr else None,
                "overflow": asdict(sol.overflow) if sol.overflow else None,
            }
            solutions_json.append(entry)

        summary: dict = {}
        for kind in ("VGPR", "SGPR"):
            top, down = _rank_top_down(r.solutions, kind, top_n)
            summary[kind] = {
                "top": [s.index for s in top],
                "down": [s.index for s in down],
            }

        payload.append(
            {
                "name": r.name,
                "log": str(r.log_path),
                "solutions": solutions_json,
                "orphan_overflows": [asdict(o) for o in r.orphan_overflows],
                "summary": summary,
            }
        )

    return json.dumps(payload, indent=2)


def _render_summary_only(
    reports: list[LogReport], *, which: str, top_n: int, header_label: str
) -> str:
    """Render a summary-only file ('top' or 'down') with per-yaml rankings.

    ``which`` is ``'top'`` or ``'down'``.
    """
    assert which in ("top", "down")
    out: list[str] = []
    out.append("=" * 80)
    out.append(
        f"Register Allocation Benefit - {header_label} {top_n} "
        f"potentialSaving per yaml  ({len(reports)} test(s))"
    )
    out.append("=" * 80)
    out.append("")

    for r in reports:
        out.append(f"### {r.name}")
        out.append(f"log: {r.log_path}")
        if not r.solutions:
            out.append("  (no [EstimateRegisterUsage] blocks found)")
            out.append("")
            continue
        for kind in ("VGPR", "SGPR"):
            top, down = _rank_top_down(r.solutions, kind, top_n)
            picked = top if which == "top" else down
            label = "Top" if which == "top" else "Down"
            out.append(f"  {label} {len(picked)} {kind} potentialSaving:")
            if not picked:
                out.append("    (none)")
            for s in picked:
                out.append(_render_rank_entry(s, kind))
        out.append("")

    return "\n".join(out) + "\n"


def _render_global_summary(
    reports: list[LogReport], *, which: str, top_n: int, header_label: str
) -> str:
    """Render a global ranking across all yamls combined."""
    assert which in ("top", "down")
    out: list[str] = []
    out.append("=" * 80)
    out.append(
        f"Register Allocation Benefit - GLOBAL {header_label} {top_n} "
        f"potentialSaving across {len(reports)} test(s)"
    )
    out.append("=" * 80)
    out.append("")

    # Build (owner, solution) pairs once for each kind.
    for kind in ("VGPR", "SGPR"):
        all_pairs: list[tuple[str, Solution]] = []
        for r in reports:
            for s in r.solutions:
                stats = s.vgpr if kind == "VGPR" else s.sgpr
                if stats is None:
                    continue
                all_pairs.append((r.name, s))

        all_pairs.sort(
            key=lambda p: (
                (p[1].vgpr if kind == "VGPR" else p[1].sgpr).potentialSaving  # type: ignore[union-attr]
            ),
            reverse=True,
        )
        if which == "top":
            picked = all_pairs[:top_n]
        else:
            picked = list(reversed(all_pairs[-top_n:]))  # smallest first

        label = "Top" if which == "top" else "Down"
        out.append(f"{label} {len(picked)} {kind} potentialSaving (global):")
        if not picked:
            out.append("    (none)")
        for owner, s in picked:
            out.append(_render_rank_entry(s, kind, owner=owner))
        out.append("")

    return "\n".join(out) + "\n"


# --- Driver ----------------------------------------------------------------


def discover_tests(asm_dir: Path, filter_names: list[str] | None = None) -> list[LogReport]:
    if not asm_dir.is_dir():
        raise FileNotFoundError(f"asm directory not found: {asm_dir}")

    allow = set(filter_names) if filter_names else None
    reports: list[LogReport] = []
    for entry in sorted(asm_dir.iterdir()):
        if not entry.is_dir():
            continue
        if allow is not None and entry.name not in allow:
            continue
        log_path = entry / f"{entry.name}.log"
        if not log_path.is_file():
            continue
        reports.append(LogReport(name=entry.name, log_path=log_path))
    return reports


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    script_dir = Path(__file__).resolve().parent
    default_asm_dir = (script_dir.parent / "asm").resolve()
    default_output = (script_dir.parent / "ra_benefit_report.txt").resolve()
    parser.add_argument(
        "--asm-dir",
        type=Path,
        default=default_asm_dir,
        help=f"Path to the asm folder (default: {default_asm_dir})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=default_output,
        help=f"Write the report to FILE (default: {default_output}). "
        "Use '-' to print to stdout.",
    )
    parser.add_argument(
        "--top-output",
        type=Path,
        default=None,
        help="Also write a summary-only file containing the per-yaml TOP "
        "potentialSaving entries. Use '-' for stdout.",
    )
    parser.add_argument(
        "--down-output",
        type=Path,
        default=None,
        help="Also write a summary-only file containing the per-yaml DOWN "
        "(lowest) potentialSaving entries. Use '-' for stdout.",
    )
    parser.add_argument(
        "--global-top",
        action="store_true",
        help="When writing --top-output / --down-output, rank globally "
        "across all yamls instead of per-yaml.",
    )
    parser.add_argument(
        "--tests",
        nargs="+",
        default=None,
        help="Limit the scan to the given test directory names.",
    )
    parser.add_argument(
        "--top",
        type=int,
        default=3,
        help="Number of entries to show in the top/down summary (default: 3).",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit a JSON report instead of the text report.",
    )
    args = parser.parse_args(argv)

    reports = discover_tests(args.asm_dir.resolve(), args.tests)
    for r in reports:
        parsed = parse_log(r.log_path)
        r.solutions = parsed.solutions
        r.orphan_overflows = parsed.orphan_overflows

    if args.json:
        body = render_json(reports, top_n=args.top)
    else:
        body = render_report(reports, top_n=args.top)

    if str(args.output) == "-":
        sys.stdout.write(body)
    else:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(body, encoding="utf-8")
        print(f"Wrote report to {args.output}")
        print(
            f"Parsed {sum(len(r.solutions) for r in reports)} solution(s) across "
            f"{len(reports)} test(s)."
        )

    def _emit_summary_file(which: str, path: Path | None) -> None:
        if path is None:
            return
        header_label = "TOP" if which == "top" else "DOWN"
        if args.global_top:
            body_ = _render_global_summary(
                reports, which=which, top_n=args.top, header_label=header_label
            )
        else:
            body_ = _render_summary_only(
                reports, which=which, top_n=args.top, header_label=header_label
            )
        if str(path) == "-":
            sys.stdout.write(body_)
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(body_, encoding="utf-8")
            scope = "global" if args.global_top else "per-yaml"
            print(f"Wrote {scope} {which} summary to {path}")

    _emit_summary_file("top", args.top_output)
    _emit_summary_file("down", args.down_output)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
