#!/usr/bin/env python3

import argparse
import csv
import math
import os
import tempfile
from collections.abc import Callable
from pathlib import Path
from typing import TextIO


def atomic_write(path: Path, writer: Callable[[TextIO], object]) -> None:
    fd, temporary_name = tempfile.mkstemp(
        prefix=".benchmark-", dir=path.parent, text=True
    )
    temporary = Path(temporary_name)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="") as stream:
            writer(stream)
        temporary.replace(path)
    except BaseException:
        temporary.unlink(missing_ok=True)
        raise


def format_summary(header: list[str], data_rows: list[list[str]]) -> str:
    display_rows = []
    for row in data_rows:
        display = [row[0]]
        for field in row[1:]:
            try:
                display.append(f"{float(field):.2f}")
            except ValueError:
                display.append(field)
        display_rows.append(display)

    widths = []
    for column in range(len(header)):
        values = [header[column], *(row[column] for row in display_rows)]
        widths.append(max(len(item) for item in values))

    def format_row(row: list[str]) -> str:
        fields = [row[0].ljust(widths[0])]
        fields.extend(
            row[column].rjust(widths[column])
            for column in range(1, len(row))
        )
        return "   ".join(fields)

    lines = [format_row(header), *(format_row(row) for row in display_rows)]
    return "\n".join(lines) + "\n"


def update_result(args: argparse.Namespace) -> None:
    with args.results.open(newline="", encoding="utf-8") as stream:
        rows = list(csv.reader(stream))

    header = rows[0]
    data_rows = rows[1:]
    current_index = next(
        (index for index, row in enumerate(data_rows) if row[0] == args.commit),
        None,
    )
    if current_index is None:
        data_rows.append(
            [args.commit, args.source] + ["0"] * (len(header) - 2)
        )
        current_index = len(data_rows) - 1
    else:
        data_rows[current_index][1] = args.source

    if args.index >= 0:
        data_rows[current_index][args.index + 2] = args.value

    atomic_write(
        args.results,
        lambda stream: csv.writer(stream, lineterminator="\n").writerows(
            [header, *data_rows]
        ),
    )

    summary = format_summary(header, data_rows)
    atomic_write(args.summary, lambda stream: stream.write(summary))

    summary_lines = summary.rstrip("\n").splitlines()
    if args.index < 0:
        print(summary_lines[0])
    print(summary_lines[current_index + 1])


def extract_max_pflops(args: argparse.Namespace) -> None:
    maximum = None
    gflops_index = None

    with args.log.open(
        encoding="utf-8", errors="replace", newline=""
    ) as stream:
        for line in stream:
            try:
                row = next(csv.reader([line]))
            except csv.Error:
                continue

            normalized = [field.strip().lower() for field in row]
            if "gflops" in normalized:
                gflops_index = normalized.index("gflops")
                continue
            if gflops_index is None or len(row) <= gflops_index:
                continue

            try:
                value = float(row[gflops_index].strip())
            except ValueError:
                continue
            if math.isfinite(value) and (
                maximum is None or value > maximum
            ):
                maximum = value

    if maximum is None:
        raise SystemExit(1)
    print(f"{maximum / 1000.0:.9g}")


def show_summary(args: argparse.Namespace) -> None:
    print(args.summary.read_text(encoding="utf-8"), end="")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Process benchmark-jichang-commits results."
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    update = subparsers.add_parser("update")
    update.add_argument("--results", type=Path, required=True)
    update.add_argument("--summary", type=Path, required=True)
    update.add_argument("--commit", required=True)
    update.add_argument("--source", required=True)
    update.add_argument("--index", type=int, required=True)
    update.add_argument("--value", required=True)
    update.set_defaults(handler=update_result)

    extract = subparsers.add_parser("extract")
    extract.add_argument("log", type=Path)
    extract.set_defaults(handler=extract_max_pflops)

    show = subparsers.add_parser("show")
    show.add_argument("summary", type=Path)
    show.set_defaults(handler=show_summary)

    return parser.parse_args()


def main() -> None:
    args = parse_args()
    args.handler(args)


if __name__ == "__main__":
    main()
