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
            [args.commit, args.source, args.asm_same]
            + ["0"] * (len(header) - 3)
        )
        current_index = len(data_rows) - 1
    else:
        data_rows[current_index][1] = args.source
        data_rows[current_index][2] = args.asm_same

    if args.index >= 0:
        data_rows[current_index][args.index + 3] = args.value

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


def extract_max_score(args: argparse.Namespace) -> None:
    maximum = None
    maximum_time_us = ""
    metric_index = None
    time_us_index = None
    validation_index = None
    maximum_failed_validation = False

    with args.log.open(
        encoding="utf-8", errors="replace", newline=""
    ) as stream:
        for line in stream:
            try:
                row = next(csv.reader([line]))
            except csv.Error:
                continue

            normalized = [field.strip().lower() for field in row]
            if args.metric in normalized:
                metric_index = normalized.index(args.metric)
                time_us_index = (
                    normalized.index("time-us")
                    if "time-us" in normalized
                    else None
                )
                validation_index = (
                    normalized.index("validation")
                    if "validation" in normalized
                    else None
                )
                continue
            if metric_index is None or len(row) <= metric_index:
                continue

            try:
                value = float(row[metric_index].strip())
            except ValueError:
                continue
            if math.isfinite(value) and (
                maximum is None or value > maximum
            ):
                maximum = value
                maximum_failed_validation = (
                    validation_index is not None
                    and len(row) > validation_index
                    and row[validation_index].strip().lower() == "failed"
                )
                maximum_time_us = ""
                if time_us_index is not None and len(row) > time_us_index:
                    try:
                        time_us = float(row[time_us_index].strip())
                    except ValueError:
                        pass
                    else:
                        if math.isfinite(time_us):
                            maximum_time_us = f"{time_us:.9g}"

    if maximum is None:
        raise SystemExit(1)
    annotation = "*" if maximum_failed_validation else ""
    divisor = 1000.0 if args.metric == "gflops" else 1.0
    score = f"{maximum / divisor:.9g}{annotation}"
    if args.include_time_us:
        print(f"{score}\t{maximum_time_us}")
    else:
        print(score)


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
    update.add_argument("--asm-same", required=True)
    update.add_argument("--index", type=int, required=True)
    update.add_argument("--value", required=True)
    update.set_defaults(handler=update_result)

    extract = subparsers.add_parser("extract")
    extract.add_argument("log", type=Path)
    extract.add_argument(
        "--metric",
        choices=("gflops", "gbps-bandwidth"),
        default="gflops",
    )
    extract.add_argument("--include-time-us", action="store_true")
    extract.set_defaults(handler=extract_max_score)

    show = subparsers.add_parser("show")
    show.add_argument("summary", type=Path)
    show.set_defaults(handler=show_summary)

    return parser.parse_args()


def main() -> None:
    args = parse_args()
    args.handler(args)


if __name__ == "__main__":
    main()
