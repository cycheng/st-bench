#!/usr/bin/env python3
"""Atomic durable state and report generation for Jichang benchmarks."""

import argparse
import csv
import difflib
import hashlib
import json
import math
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any, Callable, TextIO

FIELDS = [
    "commit", "yaml", "short_commit", "source", "yaml_revision", "test",
    "status", "score", "metric", "unit", "attempt", "log_path",
    "asm_cache_status", "message",
]
LEGACY_SAMPLE_FIELDS = ["commit", "test", "run", "status", "score"]
SAMPLE_FIELDS = [*LEGACY_SAMPLE_FIELDS, "time-us"]
PM_FIELDS = [
    "commit-id", "test", "attempt", "run", "pm-log", "sample-count",
    "interval-sample-count", "used-sample-count",
    "all-xcd-min", "warning",
]
DONE = {"passed", "validation-failed", "execution-failed", "asm-skipped"}
LEGACY_DONE = {"no-score"}
RETRYABLE_MESSAGES = {"git checkout failed", "git stash apply failed"}


def task_done(row: dict[str, str]) -> bool:
    return (
        row["status"] in DONE | LEGACY_DONE
        and row["message"] not in RETRYABLE_MESSAGES
    )


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


def write_json(path: Path, value: Any) -> None:
    atomic_write(path, lambda stream: json.dump(value, stream, indent=2, sort_keys=True))


def chronological_commits(output: Path, commits: list[str]) -> list[str]:
    metadata_path = output / "run-metadata.json"
    if not commits or not metadata_path.exists():
        return commits
    repo = json.loads(metadata_path.read_text(encoding="utf-8")).get("rocm_repo")
    if not repo:
        return commits
    result = subprocess.run(
        ["git", "-C", repo, "show", "-s", "--format=%H %ct", *commits],
        text=True, capture_output=True, check=False,
    )
    if result.returncode != 0:
        return commits
    timestamps: dict[str, int] = {}
    for line in result.stdout.splitlines():
        commit, separator, timestamp = line.partition(" ")
        if separator and timestamp.isdigit():
            timestamps[commit] = int(timestamp)
    original_order = {commit: index for index, commit in enumerate(commits)}
    return sorted(
        commits,
        key=lambda commit: (
            timestamps.get(commit, 2**63 - 1),
            original_order[commit],
        ),
    )


def read_rows(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != FIELDS:
            raise SystemExit(f"Unexpected run-state.csv columns in {path}")
        return list(reader)


def write_rows(path: Path, rows: list[dict[str, str]]) -> None:
    def writer(stream: TextIO) -> None:
        output = csv.DictWriter(stream, fieldnames=FIELDS, lineterminator="\n")
        output.writeheader()
        output.writerows(rows)
    atomic_write(path, writer)


def samples_path(state_path: Path) -> Path:
    return state_path.parent / "run-samples.csv"


def read_samples(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames not in (LEGACY_SAMPLE_FIELDS, SAMPLE_FIELDS):
            raise SystemExit(f"Unexpected run-samples.csv columns in {path}")
        rows = list(reader)
    if reader.fieldnames == LEGACY_SAMPLE_FIELDS:
        for row in rows:
            row["time-us"] = ""
    return rows


def write_samples(path: Path, rows: list[dict[str, str]]) -> None:
    def writer(stream: TextIO) -> None:
        output = csv.DictWriter(stream, fieldnames=SAMPLE_FIELDS, lineterminator="\n")
        output.writeheader()
        output.writerows(rows)
    atomic_write(path, writer)


def read_pm_rows(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames != PM_FIELDS:
            raise SystemExit(f"Unexpected pm-summary.csv columns in {path}")
        return list(reader)


def write_pm_rows(path: Path, rows: list[dict[str, str]]) -> None:
    def writer(stream: TextIO) -> None:
        output = csv.DictWriter(stream, fieldnames=PM_FIELDS, lineterminator="\n")
        output.writeheader()
        output.writerows(rows)
    atomic_write(path, writer)


def locate(rows: list[dict[str, str]], commit: str, test: str) -> dict[str, str] | None:
    return next((row for row in rows if row["commit"] == commit and row["test"] == test), None)


def initialize(args: argparse.Namespace) -> None:
    output = args.output
    state = output / "run-state.csv"
    metadata_path = output / "run-metadata.json"
    config_hash = hashlib.sha256(args.config.read_bytes()).hexdigest()
    metadata = {
        "version": 1,
        "config_sha256": config_hash,
        "rocm_repo": str(args.repo.resolve()),
        "repeat_runs": args.repeat,
        "validation_mode": args.validation_mode,
    }
    if output.exists() and not state.exists() and any(
        (output / name).exists() for name in ("results.csv", "summary.txt", "failures.csv")
    ):
        raise SystemExit(
            f"{output} contains legacy results without run-state.csv; refusing unsafe resume"
        )
    output.mkdir(parents=True, exist_ok=True)
    if metadata_path.exists():
        previous = json.loads(metadata_path.read_text(encoding="utf-8"))
        if "repeat_runs" not in previous:
            previous["repeat_runs"] = 1
        if "validation_mode" not in previous:
            previous["validation_mode"] = "all"
        if previous != metadata:
            raise SystemExit(
                "Resume metadata mismatch: config, repository, repeat count, "
                "or validation mode changed"
            )
    else:
        write_json(metadata_path, metadata)
    if not state.exists():
        write_rows(state, [])


def ensure(args: argparse.Namespace) -> None:
    rows = read_rows(args.state)
    row = locate(rows, args.commit, args.test)
    values = {
        "commit": args.commit, "yaml": args.yaml, "short_commit": args.short,
        "source": args.source, "yaml_revision": args.yaml_revision, "test": args.test,
        "metric": args.metric, "unit": args.unit,
    }
    if row is None:
        row = {field: "" for field in FIELDS}
        row.update(values)
        row.update(status="missing", attempt="0", asm_cache_status="missing")
        rows.append(row)
    else:
        for key, value in values.items():
            if row[key] and row[key] != value:
                raise SystemExit(f"Task identity mismatch for {args.commit}/{args.test}: {key}")
            row[key] = value
    write_rows(args.state, rows)


def start(args: argparse.Namespace) -> None:
    rows = read_rows(args.state)
    row = locate(rows, args.commit, args.test)
    if row is None:
        raise SystemExit("Task must be ensured before it is started")
    if task_done(row):
        print("skip")
        return
    attempt = int(row["attempt"] or "0") + 1
    relative_log = f"logs/{row['short_commit']}/{row['test']}.attempt-{attempt}.log"
    row.update(status="running", attempt=str(attempt), log_path=relative_log, message="")
    write_rows(args.state, rows)
    sample_rows = read_samples(samples_path(args.state))
    sample_rows = [
        sample for sample in sample_rows
        if not (sample["commit"] == args.commit and sample["test"] == args.test)
    ]
    write_samples(samples_path(args.state), sample_rows)
    print(relative_log)


def record_sample(args: argparse.Namespace) -> None:
    path = samples_path(args.output / "run-state.csv")
    rows = read_samples(path)
    rows = [
        row for row in rows
        if not (
            row["commit"] == args.commit
            and row["test"] == args.test
            and row["run"] == str(args.run)
        )
    ]
    rows.append({
        "commit": args.commit,
        "test": args.test,
        "run": str(args.run),
        "status": args.status,
        "score": args.score,
        "time-us": args.time_us,
    })
    write_samples(path, rows)


def record_pm(args: argparse.Namespace) -> None:
    output = args.output.resolve()
    log_path = args.log.resolve()
    if not log_path.is_file():
        raise SystemExit(f"PM log does not exist: {log_path}")

    required_columns = [
        f"GPU0 XCD XCD{index} Post Deep Sleep Freq"
        for index in range(8)
    ]
    samples: list[list[float | None]] = []
    sample_count = 0
    with log_path.open(encoding="utf-8", errors="replace", newline="") as stream:
        reader = csv.DictReader(stream)
        if reader.fieldnames is None or any(
            column not in reader.fieldnames for column in required_columns
        ):
            raise SystemExit(
                f"PM log is missing one or more Post Deep Sleep Freq columns: {log_path}"
            )
        for row in reader:
            sample_count += 1
            sample: list[float | None] = []
            for index, column in enumerate(required_columns):
                try:
                    value = float(row[column])
                except (TypeError, ValueError):
                    value = math.nan
                sample.append(value if math.isfinite(value) else None)
            samples.append(sample)

    row_averages: list[float | None] = []
    for sample in samples:
        numeric_values = [value for value in sample if value is not None]
        row_averages.append(
            sum(numeric_values) / len(numeric_values)
            if numeric_values else None
        )
    if not any(value is not None for value in row_averages):
        raise SystemExit(f"PM log has no numeric Post Deep Sleep Freq data: {log_path}")

    warning = ""
    begin = next(
        (
            index for index, value in enumerate(row_averages)
            if value is not None and value < 2000
        ),
        None,
    )
    if begin is None:
        begin = 0
        end = len(row_averages) - 1
        warning = "no row-average transition below 2000"
    else:
        end = next(
            (
                index for index in range(begin + 1, len(row_averages))
                if row_averages[index] is not None
                and row_averages[index] > 2000
            ),
            None,
        )
        if end is None:
            end = len(row_averages) - 1
            warning = "no row-average transition back above 2000"

    interval_sample_count = end - begin + 1
    selected_samples = samples[begin:end + 1]
    if interval_sample_count < 3:
        warning = (
            f"active interval has only {interval_sample_count} row(s)"
            + (f"; {warning}" if warning else "")
        )
    if warning:
        print(f"WARNING: {warning}: {log_path}", file=sys.stderr)

    selected_values = [
        value
        for sample in selected_samples
        for value in sample
        if value is not None
    ]
    if not selected_values:
        raise SystemExit(f"PM log has no usable active-interval rows: {log_path}")
    all_xcd_min = min(selected_values)

    relative_log = log_path.relative_to(output)
    log_name = relative_log.name.removesuffix("_pm.csv")
    test, separator, attempt_and_run = log_name.rpartition(".attempt-")
    if not separator:
        raise SystemExit(f"Unexpected PM log filename: {relative_log}")
    attempt, run_separator, run = attempt_and_run.partition(".run-")
    if not run_separator:
        run = "1"

    row = {
        "commit-id": relative_log.parent.name,
        "test": test,
        "attempt": attempt,
        "run": run,
        "pm-log": str(relative_log),
        "sample-count": str(sample_count),
        "interval-sample-count": str(interval_sample_count),
        "used-sample-count": str(len(selected_samples)),
        "all-xcd-min": f"{all_xcd_min:.9g}",
        "warning": warning,
    }

    summary_path = output / "pm-summary.csv"
    rows = [
        existing for existing in read_pm_rows(summary_path)
        if existing["pm-log"] != str(relative_log)
    ]
    rows.append(row)
    write_pm_rows(summary_path, rows)
    if not args.keep_log:
        log_path.unlink()


def finish(args: argparse.Namespace) -> None:
    if args.status not in DONE:
        raise SystemExit(f"Invalid terminal status: {args.status}")
    rows = read_rows(args.state)
    row = locate(rows, args.commit, args.test)
    if row is None:
        raise SystemExit("Unknown task")
    row.update(
        status=args.status, score=args.score, asm_cache_status=args.asm_status,
        message=args.message,
    )
    write_rows(args.state, rows)


def set_asm(args: argparse.Namespace) -> None:
    rows = read_rows(args.state)
    changed = False
    for row in rows:
        if row["commit"] == args.commit:
            row["asm_cache_status"] = args.status
            changed = True
    if changed:
        write_rows(args.state, rows)


def list_tests(args: argparse.Namespace) -> None:
    seen: set[str] = set()
    for row in read_rows(args.state):
        if row["test"] not in seen:
            seen.add(row["test"])
            print(row["test"])


def has_pending(args: argparse.Namespace) -> None:
    rows = read_rows(args.state)
    pending = any(
        (row := locate(rows, args.commit, test)) is None
        or not task_done(row)
        for test in args.test
    )
    print("yes" if pending else "no")


def save_plan(args: argparse.Namespace) -> None:
    path = args.output / "current-plan.json"
    old = json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
    old_asm = old.get("asm_same", {})
    asm_same = {
        commit: value
        for commit, value in old_asm.items()
        if commit not in args.commit
    }
    plan = {
        "commits": args.commit,
        "tests": args.test,
        "asm_same": asm_same,
    }
    write_json(args.output / "current-plan.json", plan)


def set_plan_asm(args: argparse.Namespace) -> None:
    path = args.output / "current-plan.json"
    plan = json.loads(path.read_text(encoding="utf-8"))
    plan.setdefault("asm_same", {})[args.commit] = args.value
    write_json(path, plan)


def asm_files(root: Path) -> dict[str, Path]:
    if not root.is_dir():
        return {}
    return {
        str(path.relative_to(root)): path
        for path in root.rglob("*")
        if path.is_file() and path.suffix.lower() in {".s", ".asm"}
    }


CLUSTER_LABEL_HASH_RE = re.compile(
    r"(label_skipCBPreSignal_(?:LCL_)?)[A-Za-z0-9]{16}"
)
SLASH_COMMENT_RE = re.compile(r"[ \t]*//.*")


def strip_slash_comments(text: str) -> str:
    """Drop // comments. A line that is only a // comment is removed."""
    kept: list[str] = []
    for line in text.splitlines(keepends=True):
        ending = ""
        body = line
        if body.endswith("\r\n"):
            ending = "\r\n"
            body = body[:-2]
        elif body.endswith(("\n", "\r")):
            ending = body[-1]
            body = body[:-1]
        updated, count = SLASH_COMMENT_RE.subn("", body, count=1)
        if count and not updated.strip():
            continue
        kept.append(updated + ending)
    return "".join(kept)


def normalized_asm_text(path: Path) -> str:
    text = strip_slash_comments(path.read_text(encoding="utf-8", errors="replace"))
    return CLUSTER_LABEL_HASH_RE.sub(r"\1<hash>", text)


def normalized_asm_bytes(path: Path) -> bytes:
    return normalized_asm_text(path).encode("utf-8")


def file_hash(path: Path) -> str:
    return hashlib.sha256(normalized_asm_bytes(path)).hexdigest()


def compare_asm_roots(left_root: Path, right_root: Path) -> str:
    if not left_root.is_dir() or not right_root.is_dir():
        return "unknown"

    left_files = asm_files(left_root)
    right_files = asm_files(right_root)
    if left_files.keys() != right_files.keys():
        return "no"
    return "yes" if all(
        file_hash(left_files[name]) == file_hash(right_files[name])
        for name in left_files
    ) else "no"


def asm_status(args: argparse.Namespace) -> None:
    print(compare_asm_roots(args.left, args.right))


def reuse_task(args: argparse.Namespace) -> None:
    rows = read_rows(args.state)
    source = locate(rows, args.source_commit, args.test)
    target = locate(rows, args.target_commit, args.test)
    if source is None or target is None:
        raise SystemExit("Source and target tasks must be ensured before reuse")
    if not task_done(source) or not source["score"]:
        raise SystemExit("Source task has no completed score to reuse")

    target.update(
        status="asm-skipped",
        score=source["score"],
        attempt="0",
        log_path="",
        asm_cache_status="cached",
        message=args.message,
    )
    write_rows(args.state, rows)
    sample_path = samples_path(args.state)
    sample_rows = read_samples(sample_path)
    sample_rows = [
        row for row in sample_rows
        if not (
            row["commit"] == args.target_commit
            and row["test"] == args.test
        )
    ]
    source_samples = [
        row for row in sample_rows
        if row["commit"] == args.source_commit and row["test"] == args.test
    ]
    if not source_samples:
        source_samples = [{
            "commit": args.source_commit,
            "test": args.test,
            "run": "1",
            "status": source["status"],
            "score": source["score"],
            "time-us": "",
        }]
    sample_rows.extend([
        {**row, "commit": args.target_commit}
        for row in source_samples
    ])
    write_samples(sample_path, sample_rows)


def numeric_score(raw_score: str) -> float | None:
    try:
        value = float(raw_score.rstrip("*"))
    except ValueError:
        return None
    return value if math.isfinite(value) else None


def numeric_value(raw_value: str) -> float | None:
    try:
        value = float(raw_value)
    except ValueError:
        return None
    return value if math.isfinite(value) else None


def calculate_statistics(
    sample_rows: list[dict[str, str]],
) -> dict[str, float | int | bool | str | None] | None:
    measured: list[tuple[float, bool]] = []
    for row in sample_rows:
        value = numeric_score(row["score"])
        if value is not None:
            measured.append((value, row["score"].endswith("*")))
    if not measured:
        return None

    values = [value for value, _ in measured]
    average = sum(values) / len(values)
    standard_deviation = math.sqrt(
        sum((value - average) ** 2 for value in values) / len(values)
    )
    time_values = [
        value
        for row in sample_rows
        if (value := numeric_value(row.get("time-us", ""))) is not None
    ]
    time_average = (
        sum(time_values) / len(time_values)
        if time_values
        else None
    )
    time_standard_deviation = (
        math.sqrt(
            sum((value - time_average) ** 2 for value in time_values)
            / len(time_values)
        )
        if time_values and time_average is not None
        else None
    )
    best_index = max(range(len(values)), key=values.__getitem__)
    validation_failures = sum(1 for _, failed in measured if failed)
    best = values[best_index]
    best_display = f"{best:.9g}" + ("*" if validation_failures else "")
    return {
        "count": len(values),
        "average": average,
        "best": best,
        "worst": min(values),
        "standard_deviation": standard_deviation,
        "time_count": len(time_values),
        "time_average": time_average,
        "time_minimum": min(time_values) if time_values else None,
        "time_maximum": max(time_values) if time_values else None,
        "time_standard_deviation": time_standard_deviation,
        "best_display": best_display,
        "validation_failures": validation_failures,
        "run_failures": sum(
            1 for row in sample_rows if row["status"] == "execution-failed"
        ),
    }


def sample_statistics(args: argparse.Namespace) -> None:
    state_rows = read_rows(args.output / "run-state.csv")
    samples = [
        row for row in read_samples(args.output / "run-samples.csv")
        if row["commit"] == args.commit and row["test"] == args.test
    ]
    if not samples:
        state_row = locate(state_rows, args.commit, args.test)
        if state_row is not None and task_done(state_row):
            samples = [{
                "commit": args.commit,
                "test": args.test,
                "run": "1",
                "status": state_row["status"],
                "score": state_row["score"],
                "time-us": "",
            }]
    statistics = calculate_statistics(samples)
    if statistics is None:
        print("0")
        return
    print(
        "\t".join([
            str(statistics["count"]),
            f"{statistics['average']:.9g}",
            f"{statistics['best']:.9g}",
            f"{statistics['worst']:.9g}",
            f"{statistics['standard_deviation']:.9g}",
            str(statistics["best_display"]),
            str(statistics["validation_failures"]),
            str(statistics["run_failures"]),
        ])
    )


def write_file_diff(left: Path, right: Path, destination: Path) -> None:
    left_lines = normalized_asm_text(left).splitlines(True)
    right_lines = normalized_asm_text(right).splitlines(True)
    body = difflib.unified_diff(
        left_lines,
        right_lines,
        fromfile=str(left),
        tofile=str(right),
    )
    atomic_write(destination, lambda stream: stream.writelines(body))


def compare_asm(args: argparse.Namespace) -> None:
    output = args.output
    state_rows = read_rows(output / "run-state.csv")
    plan_path = output / "current-plan.json"
    if not plan_path.exists():
        raise SystemExit("current-plan.json does not exist")
    plan = json.loads(plan_path.read_text(encoding="utf-8"))
    commits: list[str] = plan.get("commits", [])
    tests: list[str] = []
    short_by_commit: dict[str, str] = {}
    for row in state_rows:
        short_by_commit.setdefault(row["commit"], row["short_commit"])
        if row["commit"] not in commits:
            commits.append(row["commit"])
        if row["test"] not in tests:
            tests.append(row["test"])
    commits = chronological_commits(output, commits)

    summary_rows = [[
        "previous-commit", "current-commit", "yaml", "status",
        "total", "same", "different", "added", "removed",
    ]]
    file_rows = [[
        "previous-commit", "current-commit", "yaml", "file", "status",
        "previous-sha256", "current-sha256",
    ]]
    asm_same = {
        commit: value
        for commit, value in plan.get("asm_same", {}).items()
        if commit not in commits
    }
    diff_root = output / "asm-diffs"
    if diff_root.exists():
        shutil.rmtree(diff_root)

    previous_commit = ""
    for commit in commits:
        current_short = short_by_commit.get(commit, commit[:12])
        if not previous_commit:
            asm_same[commit] = {
                "status": "N/A", "different": "", "added": "", "removed": "",
            }
            previous_commit = commit
            continue

        previous_short = short_by_commit.get(previous_commit, previous_commit[:12])
        aggregate = {"same": 0, "different": 0, "added": 0, "removed": 0}
        incomplete = False
        for test in tests:
            left_root = output / "asm" / previous_short / test / "st"
            right_root = output / "asm" / current_short / test / "st"
            if not left_root.is_dir() or not right_root.is_dir():
                incomplete = True
                summary_rows.append([
                    previous_short, current_short, test, "unknown",
                    "", "", "", "", "",
                ])
                continue

            left_files = asm_files(left_root)
            right_files = asm_files(right_root)
            counts = {"same": 0, "different": 0, "added": 0, "removed": 0}
            for relative in sorted(left_files.keys() | right_files.keys()):
                left = left_files.get(relative)
                right = right_files.get(relative)
                left_hash = file_hash(left) if left else ""
                right_hash = file_hash(right) if right else ""
                if left is None:
                    status = "added"
                elif right is None:
                    status = "removed"
                elif left_hash == right_hash:
                    status = "same"
                else:
                    status = "different"
                    write_file_diff(
                        left,
                        right,
                        diff_root / f"{previous_short}--{current_short}"
                        / test / f"{relative}.diff",
                    )
                counts[status] += 1
                file_rows.append([
                    previous_short, current_short, test, relative, status,
                    left_hash, right_hash,
                ])

            for name, value in counts.items():
                aggregate[name] += value
            total = sum(counts.values())
            yaml_status = (
                "yes"
                if counts["different"] + counts["added"] + counts["removed"] == 0
                else "no"
            )
            summary_rows.append([
                previous_short, current_short, test, yaml_status, str(total),
                str(counts["same"]), str(counts["different"]),
                str(counts["added"]), str(counts["removed"]),
            ])

        changed = aggregate["different"] + aggregate["added"] + aggregate["removed"]
        status = "unknown" if incomplete else ("yes" if changed == 0 else "no")
        asm_same[commit] = {
            "status": status,
            "different": str(aggregate["different"]),
            "added": str(aggregate["added"]),
            "removed": str(aggregate["removed"]),
        }
        previous_commit = commit

    plan["asm_same"] = asm_same
    write_json(plan_path, plan)
    atomic_write(
        output / "asm-summary.csv",
        lambda stream: csv.writer(stream, lineterminator="\n").writerows(summary_rows),
    )
    atomic_write(
        output / "asm-file-comparisons.csv",
        lambda stream: csv.writer(stream, lineterminator="\n").writerows(file_rows),
    )


def format_table(header: list[str], rows: list[list[str]]) -> str:
    display_rows: list[list[str]] = []
    for row in rows:
        display = [row[0]]
        for field in row[1:]:
            numeric = field
            annotations = ""
            while numeric and numeric[-1] in "*=":
                annotations = numeric[-1] + annotations
                numeric = numeric[:-1]
            try:
                display.append(f"{float(numeric):.2f}{annotations}")
            except ValueError:
                display.append(field)
        display_rows.append(display)
    widths = [
        max(len(header[i]), *(len(row[i]) for row in display_rows))
        for i in range(len(header))
    ]
    lines = []
    for row in [header, *display_rows]:
        fields = [row[0].ljust(widths[0])]
        fields.extend(row[i].rjust(widths[i]) for i in range(1, len(row)))
        lines.append("   ".join(fields))
    return "\n".join(lines) + "\n"


def format_summary(
    best_header: list[str],
    best_rows: list[list[str]],
    average_header: list[str],
    average_rows: list[list[str]],
    pm_header: list[str],
    pm_minimum_rows: list[list[str]],
) -> str:
    sections = [
        "Best",
        format_table(best_header, best_rows).rstrip("\n"),
        "",
        "Average with SD",
        format_table(average_header, average_rows).rstrip("\n"),
    ]
    if pm_minimum_rows:
        sections.extend([
            "",
            "PM Post Deep Sleep Freq minimum (best benchmark run)",
            format_table(pm_header, pm_minimum_rows).rstrip("\n"),
            "PM annotation: * active interval was too short or incomplete",
        ])
    sections.extend([
        "",
        "Annotations: = ASM matches previous chronological commit; * validation failed",
    ])
    return "\n".join(sections) + "\n"


def format_time_summary(
    header: list[str],
    minimum_rows: list[list[str]],
    average_rows: list[list[str]],
) -> str:
    return "\n".join([
        "Minimum execution time (us; lower is better)",
        format_table(header, minimum_rows).rstrip("\n"),
        "",
        "Average execution time with SD (us; lower is better)",
        format_table(header, average_rows).rstrip("\n"),
        "",
        "Annotations: = ASM matches previous chronological commit; * validation failed",
    ]) + "\n"


def statistics_for_task(
    state_row: dict[str, str],
    sample_map: dict[tuple[str, str], list[dict[str, str]]],
) -> dict[str, float | int | bool | str | None] | None:
    samples = sample_map.get((state_row["commit"], state_row["test"]), [])
    if not samples and task_done(state_row):
        samples = [{
            "commit": state_row["commit"],
            "test": state_row["test"],
            "run": "1",
            "status": state_row["status"],
            "score": state_row["score"],
            "time-us": "",
        }]
    return calculate_statistics(samples)


def best_sample_run(sample_rows: list[dict[str, str]]) -> str | None:
    best_run = None
    best_score = None
    for sample in sample_rows:
        score = numeric_score(sample["score"])
        if score is not None and (best_score is None or score > best_score):
            best_run = sample["run"]
            best_score = score
    return best_run


def reports(args: argparse.Namespace) -> None:
    output = args.output
    rows = read_rows(output / "run-state.csv")
    plan_path = output / "current-plan.json"
    plan = json.loads(plan_path.read_text(encoding="utf-8")) if plan_path.exists() else {}
    commits = plan.get("commits", [])
    tests: list[str] = []
    # Include earlier/extended work after the currently selected ordering.
    for row in rows:
        if row["commit"] not in commits:
            commits.append(row["commit"])
        if row["test"] not in tests:
            tests.append(row["test"])
    commits = chronological_commits(output, commits)
    sample_map: dict[tuple[str, str], list[dict[str, str]]] = {}
    for sample in read_samples(output / "run-samples.csv"):
        sample_map.setdefault((sample["commit"], sample["test"]), []).append(sample)
    latest_pm_rows: dict[tuple[str, str], list[dict[str, str]]] = {}
    for pm_row in read_pm_rows(output / "pm-summary.csv"):
        key = (pm_row["commit-id"], pm_row["test"])
        latest_pm_rows.setdefault(key, [])
        try:
            attempt = int(pm_row["attempt"])
        except ValueError:
            attempt = -1
        current_rows = latest_pm_rows[key]
        if current_rows:
            try:
                current_attempt = int(current_rows[0]["attempt"])
            except ValueError:
                current_attempt = -1
            if attempt > current_attempt:
                latest_pm_rows[key] = [pm_row]
            elif attempt == current_attempt:
                current_rows.append(pm_row)
        else:
            latest_pm_rows[key] = [pm_row]
    yaml_asm_same: dict[tuple[str, str], bool] = {}
    asm_summary_path = output / "asm-summary.csv"
    if asm_summary_path.exists():
        with asm_summary_path.open(encoding="utf-8", newline="") as stream:
            for asm_row in csv.DictReader(stream):
                yaml_asm_same[
                    (asm_row["current-commit"], asm_row["yaml"])
                ] = asm_row["status"] == "yes"
    by_key = {(row["commit"], row["test"]): row for row in rows}
    commit_rows: list[list[str]] = []
    average_rows: list[list[str]] = []
    time_minimum_rows: list[list[str]] = []
    time_average_rows: list[list[str]] = []
    pm_minimum_rows: list[list[str]] = []
    statistics_rows = [[
        "commit-id", "source", "test", "unit", "count",
        "average", "best", "worst", "standard-deviation",
        "time-us-count", "time-us-average", "time-us-minimum",
        "time-us-maximum", "time-us-standard-deviation",
    ]]
    for commit in commits:
        related = [row for row in rows if row["commit"] == commit]
        if not related:
            continue
        first = related[0]
        best_values = []
        average_values = []
        time_minimum_values = []
        time_average_values = []
        for test in tests:
            row = by_key.get((commit, test))
            statistics = (
                statistics_for_task(row, sample_map)
                if row and row["status"] in DONE
                else None
            )
            if statistics is None:
                best_value = row["score"] if row else ""
                fallback_score = numeric_score(row["score"]) if row else None
                average_value = (
                    f"{fallback_score:.2f} +/- 0.00"
                    if fallback_score is not None
                    else ""
                )
            else:
                best_value = str(statistics["best_display"])
                average_value = (
                    f"{statistics['average']:.2f} +/- "
                    f"{statistics['standard_deviation']:.2f}"
                )
                statistics_rows.append([
                    first["short_commit"], first["source"], test,
                    row["unit"], str(statistics["count"]),
                    f"{statistics['average']:.9g}",
                    f"{statistics['best']:.9g}",
                    f"{statistics['worst']:.9g}",
                    f"{statistics['standard_deviation']:.9g}",
                    str(statistics["time_count"]),
                    (
                        f"{statistics['time_average']:.9g}"
                        if statistics["time_average"] is not None
                        else ""
                    ),
                    (
                        f"{statistics['time_minimum']:.9g}"
                        if statistics["time_minimum"] is not None
                        else ""
                    ),
                    (
                        f"{statistics['time_maximum']:.9g}"
                        if statistics["time_maximum"] is not None
                        else ""
                    ),
                    (
                        f"{statistics['time_standard_deviation']:.9g}"
                        if statistics["time_standard_deviation"] is not None
                        else ""
                    ),
                ])
            if best_value and yaml_asm_same.get((first["short_commit"], test), False):
                best_value += "="
                average_value += "="
            time_minimum_value = ""
            time_average_value = ""
            if statistics is not None and statistics["time_average"] is not None:
                time_minimum_value = f"{statistics['time_minimum']:.9g}"
                time_average_value = (
                    f"{statistics['time_average']:.2f} +/- "
                    f"{statistics['time_standard_deviation']:.2f}"
                )
                if statistics["validation_failures"]:
                    time_minimum_value += "*"
                    time_average_value += "*"
                if yaml_asm_same.get((first["short_commit"], test), False):
                    time_minimum_value += "="
                    time_average_value += "="
            best_values.append(best_value)
            average_values.append(average_value)
            time_minimum_values.append(time_minimum_value)
            time_average_values.append(time_average_value)
        commit_rows.append([
            first["short_commit"], first["source"], *best_values,
        ])
        average_rows.append([
            first["short_commit"], first["source"], *average_values,
        ])
        time_minimum_rows.append([
            first["short_commit"], first["source"], *time_minimum_values,
        ])
        time_average_rows.append([
            first["short_commit"], first["source"], *time_average_values,
        ])
        pm_values_for_commit = []
        has_pm_value = False
        for test in (test for test in tests if test.startswith("maf-")):
            pm_rows = latest_pm_rows.get((first["short_commit"], test), [])
            best_run = best_sample_run(sample_map.get((commit, test), []))
            if best_run is None and by_key.get((commit, test)):
                best_run = "1"
            best_pm_row = next(
                (pm_row for pm_row in pm_rows if pm_row["run"] == best_run),
                None,
            )
            pm_value = ""
            if best_pm_row is not None:
                value = numeric_value(
                    best_pm_row["all-xcd-min"]
                )
            else:
                value = None
            if value is not None:
                has_pm_value = True
                pm_value = f"{value:.9g}"
                if best_pm_row["warning"]:
                    pm_value += "*"
            pm_values_for_commit.append(pm_value)
        if has_pm_value:
            pm_minimum_rows.append([
                first["short_commit"], first["source"], *pm_values_for_commit,
            ])
    header = ["commit-id", "source", *tests]
    pm_header = [
        "commit-id", "source",
        *(test for test in tests if test.startswith("maf-")),
    ]
    atomic_write(
        output / "results.csv",
        lambda stream: csv.writer(stream, lineterminator="\n").writerows([header, *commit_rows]),
    )
    atomic_write(
        output / "summary.txt",
        lambda stream: stream.write(
            format_summary(
                header, commit_rows, header, average_rows,
                pm_header, pm_minimum_rows,
            )
        ),
    )
    atomic_write(
        output / "time-summary.txt",
        lambda stream: stream.write(
            format_time_summary(header, time_minimum_rows, time_average_rows)
        ),
    )
    atomic_write(
        output / "run-statistics.csv",
        lambda stream: csv.writer(stream, lineterminator="\n").writerows(statistics_rows),
    )
    failures = [["commit-id", "source", "test", "status", "reason", "log"]]
    for row in rows:
        if (
            row["status"] in {"validation-failed", "execution-failed", "no-score"}
            or (row["asm_cache_status"] == "missing" and row["message"])
        ):
            failures.append([
                row["short_commit"], row["source"], row["test"], row["status"],
                row["message"], row["log_path"],
            ])
    atomic_write(
        output / "failures.csv",
        lambda stream: csv.writer(stream, lineterminator="\n").writerows(failures),
    )


def session(args: argparse.Namespace) -> None:
    path = args.output / "git-session.json"
    if args.action == "get":
        if path.exists():
            value = json.loads(path.read_text(encoding="utf-8"))
            print(value.get(args.field, "") if args.field else json.dumps(value))
        return
    if args.action == "clear":
        path.unlink(missing_ok=True)
        return
    value = json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
    for key in ("original_commit", "original_branch", "stash_oid", "applied_commit", "applied_diff_hash"):
        argument = getattr(args, key)
        if argument is not None:
            value[key] = argument
    write_json(path, value)


def add_common_task(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--state", type=Path, required=True)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--test", required=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    commands = parser.add_subparsers(dest="command", required=True)
    init = commands.add_parser("init")
    init.add_argument("--output", type=Path, required=True)
    init.add_argument("--config", type=Path, required=True)
    init.add_argument("--repo", type=Path, required=True)
    init.add_argument("--repeat", type=int, default=1)
    init.add_argument(
        "--validation-mode",
        choices=("all", "none", "first-repeat"),
        default="all",
    )
    init.set_defaults(handler=initialize)
    ensure_parser = commands.add_parser("ensure")
    add_common_task(ensure_parser)
    for name in ("yaml", "short", "source", "yaml-revision", "metric", "unit"):
        ensure_parser.add_argument(f"--{name}", required=True)
    ensure_parser.set_defaults(handler=ensure)
    start_parser = commands.add_parser("start")
    add_common_task(start_parser)
    start_parser.set_defaults(handler=start)
    sample_parser = commands.add_parser("record-sample")
    sample_parser.add_argument("--output", type=Path, required=True)
    sample_parser.add_argument("--commit", required=True)
    sample_parser.add_argument("--test", required=True)
    sample_parser.add_argument("--run", type=int, required=True)
    sample_parser.add_argument("--status", required=True)
    sample_parser.add_argument("--score", default="")
    sample_parser.add_argument("--time-us", default="")
    sample_parser.set_defaults(handler=record_sample)
    pm_parser = commands.add_parser("record-pm")
    pm_parser.add_argument("--output", type=Path, required=True)
    pm_parser.add_argument("--log", type=Path, required=True)
    pm_parser.add_argument("--keep-log", action="store_true")
    pm_parser.set_defaults(handler=record_pm)
    finish_parser = commands.add_parser("finish")
    add_common_task(finish_parser)
    finish_parser.add_argument("--status", required=True)
    finish_parser.add_argument("--score", default="")
    finish_parser.add_argument("--asm-status", required=True)
    finish_parser.add_argument("--message", default="")
    finish_parser.set_defaults(handler=finish)
    reuse_parser = commands.add_parser("reuse")
    reuse_parser.add_argument("--state", type=Path, required=True)
    reuse_parser.add_argument("--source-commit", required=True)
    reuse_parser.add_argument("--target-commit", required=True)
    reuse_parser.add_argument("--test", required=True)
    reuse_parser.add_argument("--message", required=True)
    reuse_parser.set_defaults(handler=reuse_task)
    asm_status_parser = commands.add_parser("asm-status")
    asm_status_parser.add_argument("--left", type=Path, required=True)
    asm_status_parser.add_argument("--right", type=Path, required=True)
    asm_status_parser.set_defaults(handler=asm_status)
    sample_stats_parser = commands.add_parser("sample-stats")
    sample_stats_parser.add_argument("--output", type=Path, required=True)
    sample_stats_parser.add_argument("--commit", required=True)
    sample_stats_parser.add_argument("--test", required=True)
    sample_stats_parser.set_defaults(handler=sample_statistics)
    asm_parser = commands.add_parser("set-asm")
    asm_parser.add_argument("--state", type=Path, required=True)
    asm_parser.add_argument("--commit", required=True)
    asm_parser.add_argument("--status", required=True)
    asm_parser.set_defaults(handler=set_asm)
    tests_parser = commands.add_parser("tests")
    tests_parser.add_argument("--state", type=Path, required=True)
    tests_parser.set_defaults(handler=list_tests)
    pending_parser = commands.add_parser("pending")
    pending_parser.add_argument("--state", type=Path, required=True)
    pending_parser.add_argument("--commit", required=True)
    pending_parser.add_argument("--test", action="append", default=[])
    pending_parser.set_defaults(handler=has_pending)
    plan = commands.add_parser("plan")
    plan.add_argument("--output", type=Path, required=True)
    plan.add_argument("--commit", action="append", default=[])
    plan.add_argument("--test", action="append", default=[])
    plan.set_defaults(handler=save_plan)
    plan_asm = commands.add_parser("plan-asm")
    plan_asm.add_argument("--output", type=Path, required=True)
    plan_asm.add_argument("--commit", required=True)
    plan_asm.add_argument("--value", required=True)
    plan_asm.set_defaults(handler=set_plan_asm)
    compare_parser = commands.add_parser("compare-asm")
    compare_parser.add_argument("--output", type=Path, required=True)
    compare_parser.set_defaults(handler=compare_asm)
    report = commands.add_parser("reports")
    report.add_argument("--output", type=Path, required=True)
    report.set_defaults(handler=reports)
    session_parser = commands.add_parser("session")
    session_parser.add_argument("--output", type=Path, required=True)
    session_parser.add_argument("action", choices=("get", "set", "clear"))
    session_parser.add_argument("--field")
    for name in ("original-commit", "original-branch", "stash-oid", "applied-commit", "applied-diff-hash"):
        session_parser.add_argument(f"--{name}")
    session_parser.set_defaults(handler=session)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    args.handler(args)


if __name__ == "__main__":
    main()
