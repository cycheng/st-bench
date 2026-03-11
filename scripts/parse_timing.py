#!/usr/bin/env python3
"""
Parse StinkyTofu compile-time logs and report:
  - Top kernels by A = (1a) + (1b) + (2)
  - Top kernels by B% = A / Rocisa::str(moduleKernelBody)
  - Distribution stats and histograms
"""

from __future__ import annotations

import argparse
import re
from dataclasses import dataclass, field
from pathlib import Path
from statistics import mean


@dataclass
class KernelTiming:
    idx: int
    t_1a: float
    t_1b: float
    t_2: float
    t_rocisa: float
    t_3: float
    t_total: float

    @property
    def a_time(self) -> float:
        return self.t_1a + self.t_1b + self.t_2

    @property
    def b_pct(self) -> float:
        if self.t_rocisa <= 0:
            return float("inf") if self.a_time > 0 else 0.0
        return 100.0 * self.a_time / self.t_rocisa


PATTERNS = {
    "1a": re.compile(r"StinkyTofu \(1a\) toStinkyTofuModule: ([\d.]+)s"),
    "1b": re.compile(r"StinkyTofu \(1b\) runOptimizationPipeline: ([\d.]+)s"),
    "2": re.compile(r"StinkyTofu \(2\) emitAssembly: ([\d.]+)s"),
    "rocisa": re.compile(r"Rocisa::str\(moduleKernelBody\): ([\d.]+)s"),
    "3": re.compile(r"StinkyTofu \(3\) debug file write: ([\d.]+)s"),
    "0": re.compile(r"StinkyTofu \(0\) total: ([\d.]+)s"),
}


def parse_log(path: Path) -> list[KernelTiming]:
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    kernels: list[KernelTiming] = []
    idx = 0
    i = 0

    while i < len(lines):
        m1a = PATTERNS["1a"].search(lines[i])
        if not m1a:
            i += 1
            continue

        # Timing lines are not always strictly contiguous and newer logs may
        # omit stage (1b). Scan forward until we close this kernel block at (0).
        t_1a = float(m1a.group(1))
        t_1b = 0.0
        t_2 = None
        t_rocisa = None
        t_3 = None
        t_total = None

        j = i + 1
        while j < len(lines):
            line = lines[j]

            m1b = PATTERNS["1b"].search(line)
            if m1b:
                t_1b = float(m1b.group(1))

            m2 = PATTERNS["2"].search(line)
            if m2:
                t_2 = float(m2.group(1))

            mro = PATTERNS["rocisa"].search(line)
            if mro:
                t_rocisa = float(mro.group(1))

            m3 = PATTERNS["3"].search(line)
            if m3:
                t_3 = float(m3.group(1))

            m0 = PATTERNS["0"].search(line)
            if m0:
                t_total = float(m0.group(1))
                break

            # Next kernel started before seeing a closing (0): abandon this one.
            if PATTERNS["1a"].search(line):
                break

            j += 1

        if all(v is not None for v in (t_2, t_rocisa, t_3, t_total)):
            idx += 1
            kernels.append(
                KernelTiming(
                    idx=idx,
                    t_1a=t_1a,
                    t_1b=t_1b,
                    t_2=t_2,
                    t_rocisa=t_rocisa,
                    t_3=t_3,
                    t_total=t_total,
                )
            )
            i = j + 1
        else:
            i += 1

    return kernels


@dataclass
class TestCaseResult:
    name: str
    log_path: Path
    kernels: list[KernelTiming] = field(default_factory=list)

    @property
    def num_kernels(self) -> int:
        return len(self.kernels)

    @property
    def total_a(self) -> float:
        return sum(k.a_time for k in self.kernels)

    @property
    def max_a(self) -> float:
        return max((k.a_time for k in self.kernels), default=0.0)

    @property
    def mean_a(self) -> float:
        return mean(k.a_time for k in self.kernels) if self.kernels else 0.0

    @property
    def total_rocisa(self) -> float:
        return sum(k.t_rocisa for k in self.kernels)

    @property
    def total_time(self) -> float:
        return sum(k.t_total for k in self.kernels)

    @property
    def mean_b_pct(self) -> float:
        finite = [k.b_pct for k in self.kernels if k.b_pct != float("inf")]
        return mean(finite) if finite else 0.0


def discover_testcases(asm_dir: Path) -> list[TestCaseResult]:
    results: list[TestCaseResult] = []
    for child in sorted(asm_dir.iterdir()):
        if not child.is_dir():
            continue
        logs = list(child.glob("*.log"))
        if not logs:
            continue
        log_path = logs[0]
        name = child.name
        kernels = parse_log(log_path)
        results.append(TestCaseResult(name=name, log_path=log_path, kernels=kernels))
    return results


def print_testcase_summary_table(results: list[TestCaseResult]) -> None:
    hdr = f"{'TestCase':<30} {'Kernels':>7} {'Sum(A)':>10} {'Max(A)':>10} {'Mean(A)':>10} {'Mean(B%)':>10} {'Sum(Total)':>12}"
    sep = "-" * len(hdr)
    print(sep)
    print(hdr)
    print(sep)
    for r in results:
        if not r.kernels:
            print(f"{r.name:<30} {'(no kernels)':>7}")
            continue
        print(
            f"{r.name:<30} {r.num_kernels:>7} "
            f"{r.total_a:>9.4f}s {r.max_a:>9.4f}s {r.mean_a:>9.4f}s "
            f"{r.mean_b_pct:>9.2f}% {r.total_time:>11.4f}s"
        )
    print(sep)


def print_overall_summary(results: list[TestCaseResult]) -> None:
    all_kernels = [k for r in results for k in r.kernels]
    valid = [r for r in results if r.kernels]
    if not all_kernels:
        print("  No kernels found across all testcases.")
        return

    grand_total_a = sum(k.a_time for k in all_kernels)
    grand_total_time = sum(k.t_total for k in all_kernels)
    a_vals = sorted(k.a_time for k in all_kernels)
    b_vals = sorted(k.b_pct for k in all_kernels if k.b_pct != float("inf"))

    print(f"  Testcases scanned:   {len(results)}")
    print(f"  Testcases with data: {len(valid)}")
    print(f"  Total kernels:       {len(all_kernels)}")
    print(f"  Grand total (A):     {grand_total_a:.4f}s")
    print(f"  Grand total (0):     {grand_total_time:.4f}s")
    print()
    print(f"  (A) across all kernels:")
    print(f"    Min:  {a_vals[0]:.4f}s")
    print(f"    Max:  {a_vals[-1]:.4f}s")
    print(f"    Mean: {mean(a_vals):.4f}s")
    print(f"    P50:  {percentile(a_vals, 0.50):.4f}s")
    print(f"    P90:  {percentile(a_vals, 0.90):.4f}s")
    print(f"    P95:  {percentile(a_vals, 0.95):.4f}s")
    print()
    print_histogram(a_vals, [(0, 0.05), (0.05, 0.1), (0.1, 0.2), (0.2, 0.3), (0.3, 0.5), (0.5, 1.0), (1.0, float("inf"))], "s")
    print()

    if b_vals:
        inf_count = len(all_kernels) - len(b_vals)
        print(f"  (B)% across all kernels:")
        if inf_count:
            print(f"    Excluded inf values: {inf_count}")
        print(f"    Min:  {b_vals[0]:.2f}%")
        print(f"    Max:  {b_vals[-1]:.2f}%")
        print(f"    Mean: {mean(b_vals):.2f}%")
        print(f"    P50:  {percentile(b_vals, 0.50):.2f}%")
        print(f"    P90:  {percentile(b_vals, 0.90):.2f}%")
        print(f"    P95:  {percentile(b_vals, 0.95):.2f}%")
        print()
        print_histogram(b_vals, [(0, 10), (10, 20), (20, 30), (30, 40), (40, 50), (50, 100), (100, float("inf"))], "%")

    print()
    print("  Top 10 testcases by Sum(A):")
    by_total_a = sorted(valid, key=lambda r: r.total_a, reverse=True)[:10]
    for rank, r in enumerate(by_total_a, 1):
        print(f"    {rank:>2}. {r.name:<30} Sum(A)={r.total_a:.4f}s  ({r.num_kernels} kernels)")

    print()
    print("  Top 10 testcases by Mean(B%):")
    by_mean_b = sorted(valid, key=lambda r: r.mean_b_pct, reverse=True)[:10]
    for rank, r in enumerate(by_mean_b, 1):
        print(f"    {rank:>2}. {r.name:<30} Mean(B%)={r.mean_b_pct:.2f}%  ({r.num_kernels} kernels)")


def percentile(sorted_vals: list[float], pct: float) -> float:
    if not sorted_vals:
        return 0.0
    idx = min(int(pct * len(sorted_vals)), len(sorted_vals) - 1)
    return sorted_vals[idx]


def print_histogram(values: list[float], bins: list[tuple[float, float]], unit: str) -> None:
    n = len(values)
    print("  Histogram:")
    for lo, hi in bins:
        label = f"{lo}-{hi}{unit}" if hi != float("inf") else f">={lo}{unit}"
        count = sum(1 for v in values if lo <= v < hi)
        pct = (100.0 * count / n) if n else 0.0
        bar_len = min(50, int(pct / 2))
        bar = "#" * bar_len
        print(f"    {label:12} {count:5} ({pct:5.1f}%) {bar}")


def print_kernel(rank: int, kernel: KernelTiming) -> None:
    print(f"--- Rank {rank} (kernel #{kernel.idx}) ---")
    print(f"  (1a) toStinkyTofuModule:      {kernel.t_1a:.4f}s")
    print(f"  (1b) runOptimizationPipeline: {kernel.t_1b:.4f}s")
    print(f"  (2)  emitAssembly:            {kernel.t_2:.4f}s")
    print(f"  Rocisa::str(moduleKernelBody): {kernel.t_rocisa:.4f}s")
    print(f"  (3) debug file write:         {kernel.t_3:.4f}s")
    print(f"  (0) total:                    {kernel.t_total:.4f}s")
    print(f"  (A)=(1a)+(1b)+(2):            {kernel.a_time:.4f}s")
    print(f"  (B)=(A)/Rocisa:               {kernel.b_pct:.2f}%")
    print()


def report_single_log(log_path: Path, top: int) -> None:
    kernels = parse_log(log_path)
    if not kernels:
        raise SystemExit("No kernel timing blocks found.")

    print(f"Parsed {len(kernels)} kernels from {log_path}\n")
    print("=" * 70)
    print("\nTop kernels by (A)=(1a)+(1b)+(2)\n")
    by_a = sorted(kernels, key=lambda k: k.a_time, reverse=True)[:top]
    for rank, kernel in enumerate(by_a, 1):
        print_kernel(rank, kernel)

    print("=" * 70)
    print("\nTop kernels by (B)%=(A)/Rocisa::str(moduleKernelBody)\n")
    by_b = sorted(kernels, key=lambda k: k.b_pct, reverse=True)[:top]
    for rank, kernel in enumerate(by_b, 1):
        print_kernel(rank, kernel)

    a_vals = sorted(k.a_time for k in kernels)
    print("=" * 70)
    print("\nDistribution of (A)\n")
    print(f"  Count: {len(a_vals)}")
    print(f"  Min:   {a_vals[0]:.4f}s")
    print(f"  Max:   {a_vals[-1]:.4f}s")
    print(f"  Mean:  {mean(a_vals):.4f}s")
    print(f"  P25:   {percentile(a_vals, 0.25):.4f}s")
    print(f"  P50:   {percentile(a_vals, 0.50):.4f}s")
    print(f"  P75:   {percentile(a_vals, 0.75):.4f}s")
    print(f"  P90:   {percentile(a_vals, 0.90):.4f}s")
    print(f"  P95:   {percentile(a_vals, 0.95):.4f}s")
    print_histogram(a_vals, [(0, 0.05), (0.05, 0.1), (0.1, 0.2), (0.2, 0.3), (0.3, 0.5), (0.5, 1.0), (1.0, float("inf"))], "s")

    b_vals = sorted(k.b_pct for k in kernels if k.b_pct != float("inf"))
    print("=" * 70)
    print("\nDistribution of (B)%\n")
    inf_count = len(kernels) - len(b_vals)
    if inf_count:
        print(f"  Excluded inf values: {inf_count}")
    if b_vals:
        print(f"  Count: {len(b_vals)}")
        print(f"  Min:   {b_vals[0]:.2f}%")
        print(f"  Max:   {b_vals[-1]:.2f}%")
        print(f"  Mean:  {mean(b_vals):.2f}%")
        print(f"  P25:   {percentile(b_vals, 0.25):.2f}%")
        print(f"  P50:   {percentile(b_vals, 0.50):.2f}%")
        print(f"  P75:   {percentile(b_vals, 0.75):.2f}%")
        print(f"  P90:   {percentile(b_vals, 0.90):.2f}%")
        print(f"  P95:   {percentile(b_vals, 0.95):.2f}%")
        print_histogram(b_vals, [(0, 10), (10, 20), (20, 30), (30, 40), (40, 50), (50, 100), (100, float("inf"))], "%")


def report_directory(asm_dir: Path, top: int) -> None:
    print(f"Scanning directory: {asm_dir}\n")
    results = discover_testcases(asm_dir)
    if not results:
        raise SystemExit(f"No testcases (subdirs with .log files) found in {asm_dir}")

    valid = [r for r in results if r.kernels]
    skipped = [r for r in results if not r.kernels]

    print(f"Found {len(results)} testcase(s), {len(valid)} with kernel data"
          f"{f', {len(skipped)} skipped (no kernels)' if skipped else ''}\n")

    if skipped:
        print("Skipped testcases (no kernels parsed):")
        for r in skipped:
            print(f"  - {r.name}")
        print()

    print("=" * 100)
    print("\nPer-TestCase Summary\n")
    print_testcase_summary_table(valid)

    print()
    print("=" * 100)
    print("\nOverall Summary (all testcases combined)\n")
    print_overall_summary(valid)

    all_kernels = [k for r in valid for k in r.kernels]
    if all_kernels:
        print()
        print("=" * 100)
        print(f"\nTop {top} kernels by (A) across ALL testcases\n")
        by_a = sorted(
            ((r.name, k) for r in valid for k in r.kernels),
            key=lambda x: x[1].a_time, reverse=True,
        )[:top]
        for rank, (tc_name, kernel) in enumerate(by_a, 1):
            print(f"--- Rank {rank} [{tc_name}] (kernel #{kernel.idx}) ---")
            print(f"  (1a) toStinkyTofuModule:      {kernel.t_1a:.4f}s")
            print(f"  (1b) runOptimizationPipeline: {kernel.t_1b:.4f}s")
            print(f"  (2)  emitAssembly:            {kernel.t_2:.4f}s")
            print(f"  Rocisa::str(moduleKernelBody): {kernel.t_rocisa:.4f}s")
            print(f"  (3) debug file write:         {kernel.t_3:.4f}s")
            print(f"  (0) total:                    {kernel.t_total:.4f}s")
            print(f"  (A)=(1a)+(1b)+(2):            {kernel.a_time:.4f}s")
            print(f"  (B)=(A)/Rocisa:               {kernel.b_pct:.2f}%")
            print()


def main() -> None:
    parser = argparse.ArgumentParser(description="Parse StinkyTofu compile timing log")
    parser.add_argument("path", type=Path,
                        help="Path to a single log file, or a directory of testcases (e.g. ./asm)")
    parser.add_argument("--top", type=int, default=20, help="Top N entries to show (default: 20)")
    args = parser.parse_args()

    if args.path.is_dir():
        report_directory(args.path, args.top)
    elif args.path.is_file():
        report_single_log(args.path, args.top)
    else:
        raise SystemExit(f"Path not found: {args.path}")


if __name__ == "__main__":
    main()
