#!/usr/bin/env python3
"""Rotate the commit-by-test tables in a benchmark summary.txt.

Each matrix section is transposed so tests run down the page and commits across
it, which fits a wide run on a terminal.  In Best, every later commit also shows
its percent change from the first commit on that test.  The VGPR and SGPR
sections are folded into one vgpr/sgpr table, since the two counts are read
together.  Sections that are not commit-by-test matrices, such as the PM
averages, are copied through untouched.
"""

import argparse
import os
import sys
import tempfile
from pathlib import Path
from typing import Any, Callable, TextIO

COLUMN_GAP = "   "
MATRIX_KEY = ("commit-id", "source")
PM_TAIL = ("test", "all-xcd-average")
MIN_GAP = 2
REGISTER_TITLES = ("VGPR", "SGPR")
MERGED_TITLE = "/".join(REGISTER_TITLES)
MISSING = "-"


def atomic_write(path: Path, writer: Callable[[TextIO], Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix=f".{path.name}.", dir=path.parent, text=True)
    temporary = Path(name)
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="") as stream:
            writer(stream)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    except BaseException:
        temporary.unlink(missing_ok=True)
        raise


def column_spans(lines: list[str]) -> list[tuple[int, int]]:
    """Character span of each column, from positions blank in every line.

    Splitting on whitespace would lose both halves of the problem: a cell may
    hold a multi-word value ("19736.58 +/- 14.84") and a cell may be empty.  A
    gap between columns is at least three spaces on every line, while a gap
    inside a value is one, so a run of two is already unambiguous.  The header
    line must be included, since its names are what keep an all-empty column
    from merging into its neighbours.
    """
    width = max((len(line) for line in lines), default=0)
    padded = [line.ljust(width) for line in lines]
    blank = [all(line[index] == " " for line in padded) for index in range(width)]

    separators: list[tuple[int, int]] = []
    index = 0
    while index < width:
        if not blank[index]:
            index += 1
            continue
        end = index
        while end < width and blank[end]:
            end += 1
        if end - index >= MIN_GAP:
            separators.append((index, end))
        index = end

    spans: list[tuple[int, int]] = []
    cursor = 0
    for start, end in separators:
        if start > cursor:
            spans.append((cursor, start))
        cursor = end
    if cursor < width:
        spans.append((cursor, width))
    return spans


def split_row(line: str, spans: list[tuple[int, int]]) -> list[str]:
    return [line[start:end].strip() for start, end in spans]


def render_table(header: list[str], rows: list[list[str]]) -> list[str]:
    """Lay out a table the way the benchmark writes one: first column left."""
    table = [header, *rows]
    widths = [
        max(len(row[index]) for row in table)
        for index in range(len(header))
    ]
    lines = []
    for row in table:
        fields = [row[0].ljust(widths[0])]
        fields.extend(row[index].rjust(widths[index]) for index in range(1, len(row)))
        lines.append(COLUMN_GAP.join(fields).rstrip())
    return lines


def is_matrix(header: list[str]) -> bool:
    return (
        tuple(header[:2]) == MATRIX_KEY
        and len(header) > 2
        and tuple(header[2:]) != PM_TAIL
    )


def transpose(
    header: list[str], rows: list[list[str]]
) -> tuple[list[str], list[list[str]]]:
    """Turn commit-id/source/<tests> rows into test/<commits> rows.

    The source of each commit is metadata rather than a measurement, so it stays
    a row of its own instead of widening every column header.
    """
    rotated_header = ["test", *(row[0] for row in rows)]
    rotated_rows = [["source", *(row[1] for row in rows)]]
    for index, test in enumerate(header[2:], start=2):
        rotated_rows.append([test, *(row[index] for row in rows)])
    return rotated_header, rotated_rows


def parse_matrix(lines: list[str]) -> tuple[list[str], list[list[str]]] | None:
    """Header and rows of a titled commit-by-test section, None for anything else."""
    if len(lines) < 3 or not lines[1].startswith("commit-id"):
        return None
    spans = column_spans(lines[1:])
    header = split_row(lines[1], spans)
    if not is_matrix(header):
        return None
    return header, [split_row(line, spans) for line in lines[2:]]


def merge_counts(vgpr: str, sgpr: str) -> str:
    if not vgpr and not sgpr:
        return ""
    return f"{vgpr or MISSING}/{sgpr or MISSING}"


def merge_registers(sections: list[list[str]]) -> list[list[str]]:
    """Replace the VGPR and SGPR sections with a single vgpr/sgpr table.

    Returns the sections untouched unless both are present and agree on their
    commits and tests, so a summary written before the counts were collected, or
    holding only one of them, still rotates.
    """
    found = {
        section[0]: section
        for section in sections
        if section and section[0] in REGISTER_TITLES
    }
    if len(found) != len(REGISTER_TITLES):
        return sections
    parsed = [parse_matrix(found[title]) for title in REGISTER_TITLES]
    if any(matrix is None for matrix in parsed):
        return sections
    (header, vgpr_rows), (sgpr_header, sgpr_rows) = parsed
    if header != sgpr_header:
        return sections
    sgpr_by_commit = {row[0]: row for row in sgpr_rows}
    if any(row[0] not in sgpr_by_commit for row in vgpr_rows):
        return sections

    merged_rows = []
    for row in vgpr_rows:
        partner = sgpr_by_commit[row[0]]
        merged_rows.append([row[0], row[1], *(
            merge_counts(row[index], partner[index])
            for index in range(2, len(header))
        )])
    merged = [MERGED_TITLE, *render_table(header, merged_rows)]

    result = []
    for section in sections:
        if section is found[REGISTER_TITLES[0]]:
            result.append(merged)
        elif section is not found[REGISTER_TITLES[1]]:
            result.append(section)
    return result


def score_value(cell: str) -> float | None:
    """Numeric part of a Best cell.  * and = are annotations, not part of the score."""
    numeric = cell.strip()
    while numeric and numeric[-1] in "*=":
        numeric = numeric[:-1]
    if not numeric:
        return None
    try:
        return float(numeric)
    except ValueError:
        return None


def with_percent_delta(cell: str, baseline: str) -> str:
    """Append the percent change from the baseline cell.

    A zero baseline has no defined change, so the cell is left as written.
    """
    value = score_value(cell)
    base = score_value(baseline)
    if value is None or base is None or base == 0:
        return cell
    delta = (value - base) / base * 100
    return f"{cell} ({delta:+.2f}%)"


def add_best_deltas(
    header: list[str], rows: list[list[str]]
) -> tuple[list[str], list[list[str]]]:
    """Percent change of each later commit against the first commit, per test."""
    if len(header) < 3:
        return header, rows
    annotated = []
    for row in rows:
        if not row or row[0] == "source":
            annotated.append(row)
            continue
        baseline = row[1]
        annotated.append([
            row[0],
            baseline,
            *(with_percent_delta(cell, baseline) for cell in row[2:]),
        ])
    return header, annotated


def rotate_section(lines: list[str]) -> list[str]:
    """Rotate one titled section, or return it unchanged if it is not a matrix."""
    matrix = parse_matrix(lines)
    if matrix is None:
        return lines
    header, rows = transpose(*matrix)
    body = [lines[0]]
    if lines[0] == "Best" and len(header) > 2:
        header, rows = add_best_deltas(header, rows)
        body.append(f"percent versus {header[1]}")
    body.extend(render_table(header, rows))
    return body


def rotate_document(text: str) -> str:
    sections: list[list[str]] = []
    current: list[str] = []
    for line in text.splitlines():
        if line.strip():
            current.append(line)
        elif current:
            sections.append(current)
            current = []
    if current:
        sections.append(current)
    rotated = [
        "\n".join(rotate_section(section))
        for section in merge_registers(sections)
    ]
    return "\n\n".join(rotated) + "\n"


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "path", type=Path, nargs="?", default=Path("summary.txt"),
        help="summary to rotate (default: summary.txt)",
    )
    parser.add_argument("-o", "--output", type=Path, help="write to this file")
    parser.add_argument(
        "-i", "--in-place", action="store_true", help="rewrite the input file",
    )
    args = parser.parse_args()
    if args.output and args.in_place:
        parser.error("--output and --in-place are mutually exclusive")
    if not args.path.is_file():
        parser.error(f"no such file: {args.path}")

    rotated = rotate_document(args.path.read_text(encoding="utf-8"))
    destination = args.path if args.in_place else args.output
    if destination is None:
        sys.stdout.write(rotated)
    else:
        atomic_write(destination, lambda stream: stream.write(rotated))


if __name__ == "__main__":
    main()
