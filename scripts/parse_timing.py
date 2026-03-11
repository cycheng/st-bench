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
from dataclasses import dataclass
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


def main() -> None:
    parser = argparse.ArgumentParser(description="Parse StinkyTofu compile timing log")
    parser.add_argument("log_file", type=Path, help="Path to compile log file")
    parser.add_argument("--top", type=int, default=20, help="Top N entries to show (default: 20)")
    args = parser.parse_args()

    if not args.log_file.is_file():
        raise SystemExit(f"Log file not found: {args.log_file}")

    kernels = parse_log(args.log_file)
    if not kernels:
        raise SystemExit("No kernel timing blocks found.")

    print(f"Parsed {len(kernels)} kernels from {args.log_file}\n")
    print("=" * 70)
    print("\nTop kernels by (A)=(1a)+(1b)+(2)\n")
    by_a = sorted(kernels, key=lambda k: k.a_time, reverse=True)[: args.top]
    for rank, kernel in enumerate(by_a, 1):
        print_kernel(rank, kernel)

    print("=" * 70)
    print("\nTop kernels by (B)%=(A)/Rocisa::str(moduleKernelBody)\n")
    by_b = sorted(kernels, key=lambda k: k.b_pct, reverse=True)[: args.top]
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


if __name__ == "__main__":
    main()
