#!/usr/bin/env python3
"""
Scan the asm/ folder for test logs and report compile-time warnings emitted by:
  - StinkyBuildImplicitDependencyPass  (prefix: "[BuildImplicitDep] WARNING:")
  - AsmVerifierPass                    (messages of the form
        Instruction '<content>
        ' operand <n> has register width <X>, expected <Y>
        Instruction '<content>
        ' operand <n> has register type '<X>', expected '<Y>'
    )

For each test directory (e.g. asm/f32_gfx1250_reduced) that contains a
<test>.log file, the script reports:
  * A summary listing of tests that have any warnings.
  * A per-test, de-duplicated breakdown of every unique BuildImplicitDep and
    AsmVerifier warning found in the log.

Usage:
  scripts/check_asm_warnings.py [--asm-dir PATH] [--output FILE] [--json]
                                [--tests name [name ...]]

Defaults:
  --asm-dir = <repo>/asm   (relative to this script's parent directory)
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path


BUILD_IMPL_DEP_RE = re.compile(r"^\[BuildImplicitDep\] WARNING:.*$")

# AsmVerifier warnings start with a line like: "Instruction '..."
# The Instruction literal may span multiple lines (because the embedded IR
# text can contain newlines).  The closing line always starts with a single
# quote followed by " operand " and contains either "has register width" or
# "has register type" plus ", expected".
ASM_VERIFIER_START_RE = re.compile(r"^Instruction '")
ASM_VERIFIER_END_RE = re.compile(
    r"^'\s*operand\s+\S+\s+has\s+register\s+(?:width|type)\b.*\bexpected\b"
)


@dataclass
class TestReport:
    name: str
    log_path: Path
    build_impl_dep: list[str] = field(default_factory=list)
    asm_verifier: list[tuple[str, int]] = field(default_factory=list)

    @property
    def has_issue(self) -> bool:
        return bool(self.build_impl_dep or self.asm_verifier)

    @property
    def asm_verifier_total(self) -> int:
        return sum(count for _, count in self.asm_verifier)


def _dedupe_preserve_order(items: list[str]) -> list[str]:
    seen: set[str] = set()
    out: list[str] = []
    for item in items:
        if item in seen:
            continue
        seen.add(item)
        out.append(item)
    return out


# Normalizers for register operands so two AsmVerifier warnings that point at
# "the same instruction" modulo register indices collapse into one entry.
#
# Examples:
#   v[16:23]  -> v[?:?]
#   v[4]      -> v[?]
#   v132      -> v?
#   s[12:15]  -> s[?:?]
#   s7        -> s?
#   acc[0:3]  -> acc[?:?]
_REG_RANGE_RE = re.compile(r"\b([vsa]|acc)\[(\d+):(\d+)\]")
_REG_SINGLE_BRACKET_RE = re.compile(r"\b([vsa]|acc)\[(\d+)\]")
_REG_BARE_RE = re.compile(r"\b([vsa])(\d+)\b")


def _normalize_instruction(text: str) -> str:
    text = _REG_RANGE_RE.sub(r"\1[?:?]", text)
    text = _REG_SINGLE_BRACKET_RE.sub(r"\1[?]", text)
    text = _REG_BARE_RE.sub(r"\1?", text)
    return text


def _dedupe_asm_verifier(items: list[str]) -> list[tuple[str, int]]:
    """Dedupe AsmVerifier warnings by register-normalized form.

    Returns a list of ``(representative_message, occurrence_count)`` in the
    order of first appearance.
    """
    order: list[str] = []
    first: dict[str, str] = {}
    counts: dict[str, int] = {}
    for raw in items:
        key = _normalize_instruction(raw)
        if key not in first:
            first[key] = raw
            counts[key] = 1
            order.append(key)
        else:
            counts[key] += 1
    return [(first[k], counts[k]) for k in order]


def parse_log(log_path: Path) -> tuple[list[str], list[tuple[str, int]]]:
    """Return (unique BuildImplicitDep warnings, deduped AsmVerifier warnings).

    AsmVerifier warnings are deduped by register-normalized form; each entry
    is ``(representative_message, occurrence_count)``.
    """
    build_impl_dep: list[str] = []
    asm_verifier: list[str] = []

    try:
        text = log_path.read_text(encoding="utf-8", errors="replace")
    except OSError as exc:
        print(f"warning: failed to read {log_path}: {exc}", file=sys.stderr)
        return [], []

    lines = text.splitlines()
    i = 0
    n = len(lines)

    while i < n:
        line = lines[i]

        if BUILD_IMPL_DEP_RE.match(line):
            build_impl_dep.append(line.rstrip())
            i += 1
            continue

        if ASM_VERIFIER_START_RE.match(line):
            # Accumulate until we find the closing line.  Cap the window to
            # avoid run-away parsing on malformed input.
            chunk = [line.rstrip()]
            j = i + 1
            limit = min(n, i + 200)
            while j < limit:
                cur = lines[j].rstrip()
                chunk.append(cur)
                if ASM_VERIFIER_END_RE.match(cur):
                    break
                j += 1
            if j < limit and ASM_VERIFIER_END_RE.match(lines[j].rstrip()):
                asm_verifier.append("\n".join(chunk))
                i = j + 1
                continue
            # Not a real AsmVerifier warning; move past the opening line.
            i += 1
            continue

        i += 1

    return _dedupe_preserve_order(build_impl_dep), _dedupe_asm_verifier(asm_verifier)


def discover_tests(asm_dir: Path, filter_names: list[str] | None = None) -> list[TestReport]:
    reports: list[TestReport] = []
    if not asm_dir.is_dir():
        raise FileNotFoundError(f"asm directory not found: {asm_dir}")

    allow = set(filter_names) if filter_names else None

    for entry in sorted(asm_dir.iterdir()):
        if not entry.is_dir():
            continue
        if allow is not None and entry.name not in allow:
            continue
        log_path = entry / f"{entry.name}.log"
        if not log_path.is_file():
            continue
        reports.append(TestReport(name=entry.name, log_path=log_path))

    return reports


def render_text(reports: list[TestReport], asm_dir: Path) -> str:
    lines: list[str] = []
    lines.append(f"Scanned {len(reports)} test(s) under {asm_dir}")
    lines.append("")

    problems = [r for r in reports if r.has_issue]

    lines.append("=" * 80)
    lines.append("SUMMARY")
    lines.append("=" * 80)
    if not problems:
        lines.append("No tests with BuildImplicitDep or AsmVerifier warnings.")
    else:
        lines.append(f"{len(problems)} test(s) have warnings:")
        for r in problems:
            lines.append(
                f"  - {r.name:<32} "
                f"BuildImplicitDep={len(r.build_impl_dep):<3} "
                f"AsmVerifier={len(r.asm_verifier):<3} "
                f"(raw {r.asm_verifier_total})"
            )
    lines.append("")

    if not problems:
        return "\n".join(lines) + "\n"

    lines.append("=" * 80)
    lines.append("DETAILS")
    lines.append("=" * 80)
    for r in problems:
        lines.append("")
        lines.append(f"### {r.name}")
        lines.append(f"log: {r.log_path}")

        lines.append("")
        lines.append(f"[BuildImplicitDep] unique messages: {len(r.build_impl_dep)}")
        for msg in r.build_impl_dep:
            lines.append(f"  {msg}")

        lines.append("")
        lines.append(
            f"AsmVerifier unique warnings: {len(r.asm_verifier)} "
            f"(raw occurrences: {r.asm_verifier_total}, "
            f"deduped by register-normalized instruction)"
        )
        for idx, (msg, count) in enumerate(r.asm_verifier, 1):
            header = f"  [{idx}]" if count == 1 else f"  [{idx}] (x{count})"
            lines.append(header)
            for sub in msg.splitlines():
                lines.append(f"    {sub}")

        lines.append("-" * 80)

    return "\n".join(lines) + "\n"


def render_json(reports: list[TestReport]) -> str:
    payload = {
        "summary": [
            {
                "name": r.name,
                "build_impl_dep_count": len(r.build_impl_dep),
                "asm_verifier_unique_count": len(r.asm_verifier),
                "asm_verifier_raw_count": r.asm_verifier_total,
            }
            for r in reports
            if r.has_issue
        ],
        "details": {
            r.name: {
                "log": str(r.log_path),
                "build_impl_dep": r.build_impl_dep,
                "asm_verifier": [
                    {"message": msg, "count": count}
                    for msg, count in r.asm_verifier
                ],
            }
            for r in reports
            if r.has_issue
        },
    }
    return json.dumps(payload, indent=2)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    default_asm_dir = (Path(__file__).resolve().parent.parent / "asm").resolve()
    parser.add_argument(
        "--asm-dir",
        type=Path,
        default=default_asm_dir,
        help=f"Path to the asm folder (default: {default_asm_dir})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=None,
        help="Write the report to FILE instead of stdout.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit a JSON report instead of the human-readable text report.",
    )
    parser.add_argument(
        "--tests",
        nargs="+",
        default=None,
        help="Limit the scan to the given test directory names.",
    )
    args = parser.parse_args(argv)

    reports = discover_tests(args.asm_dir.resolve(), args.tests)
    for r in reports:
        r.build_impl_dep, r.asm_verifier = parse_log(r.log_path)

    if args.json:
        body = render_json(reports)
    else:
        body = render_text(reports, args.asm_dir.resolve())

    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(body, encoding="utf-8")
        print(f"Wrote report to {args.output}")
    else:
        sys.stdout.write(body)

    return 0 if not any(r.has_issue for r in reports) else 1


if __name__ == "__main__":
    raise SystemExit(main())
