#!/usr/bin/env python3
"""Atomic durable state and report generation for Jichang benchmarks."""

import argparse
import csv
import difflib
import hashlib
import json
import os
import re
import shutil
import subprocess
import tempfile
from pathlib import Path
from typing import Any, Callable, TextIO

FIELDS = [
    "commit", "yaml", "short_commit", "source", "yaml_revision", "test",
    "status", "score", "metric", "unit", "attempt", "log_path",
    "asm_cache_status", "message",
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


def locate(rows: list[dict[str, str]], commit: str, test: str) -> dict[str, str] | None:
    return next((row for row in rows if row["commit"] == commit and row["test"] == test), None)


def initialize(args: argparse.Namespace) -> None:
    output = args.output
    state = output / "run-state.csv"
    metadata_path = output / "run-metadata.json"
    config_hash = hashlib.sha256(args.config.read_bytes()).hexdigest()
    metadata = {"version": 1, "config_sha256": config_hash, "rocm_repo": str(args.repo.resolve())}
    if output.exists() and not state.exists() and any(
        (output / name).exists() for name in ("results.csv", "summary.txt", "failures.csv")
    ):
        raise SystemExit(
            f"{output} contains legacy results without run-state.csv; refusing unsafe resume"
        )
    output.mkdir(parents=True, exist_ok=True)
    if metadata_path.exists():
        previous = json.loads(metadata_path.read_text(encoding="utf-8"))
        if previous != metadata:
            raise SystemExit(
                "Resume metadata mismatch: config content or ROCm repository path changed"
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
    print(relative_log)


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
CLUSTER_LABEL_HASH_BYTES_RE = re.compile(
    rb"(label_skipCBPreSignal_(?:LCL_)?)[A-Za-z0-9]{16}"
)


def normalized_asm_bytes(path: Path) -> bytes:
    return CLUSTER_LABEL_HASH_BYTES_RE.sub(rb"\1<hash>", path.read_bytes())


def normalized_asm_text(path: Path) -> str:
    text = path.read_text(encoding="utf-8", errors="replace")
    return CLUSTER_LABEL_HASH_RE.sub(r"\1<hash>", text)


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


def format_summary(header: list[str], rows: list[list[str]]) -> str:
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
    lines.extend([
        "",
        "Annotations: = ASM matches previous chronological commit; * validation failed",
    ])
    return "\n".join(lines) + "\n"


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
    for commit in commits:
        related = [row for row in rows if row["commit"] == commit]
        if not related:
            continue
        first = related[0]
        values = []
        for test in tests:
            row = by_key.get((commit, test))
            value = row["score"] if row and row["status"] in DONE else ""
            if value and yaml_asm_same.get((first["short_commit"], test), False):
                value += "="
            values.append(value)
        commit_rows.append([
            first["short_commit"], first["source"], *values,
        ])
    header = ["commit-id", "source", *tests]
    atomic_write(
        output / "results.csv",
        lambda stream: csv.writer(stream, lineterminator="\n").writerows([header, *commit_rows]),
    )
    atomic_write(output / "summary.txt", lambda stream: stream.write(format_summary(header, commit_rows)))
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
    init.set_defaults(handler=initialize)
    ensure_parser = commands.add_parser("ensure")
    add_common_task(ensure_parser)
    for name in ("yaml", "short", "source", "yaml-revision", "metric", "unit"):
        ensure_parser.add_argument(f"--{name}", required=True)
    ensure_parser.set_defaults(handler=ensure)
    start_parser = commands.add_parser("start")
    add_common_task(start_parser)
    start_parser.set_defaults(handler=start)
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
