#!/usr/bin/env python3
"""
Draw a control-flow graph from pass dump text.

This parser intentionally only looks at:
  - block labels:     ^label_name:
  - successor lines:  Successors: ^nextA, ^nextB

Everything else is ignored.
"""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
from dataclasses import dataclass, field
from pathlib import Path


FUNC_RE = re.compile(r"^\s*st\.func\s+@([^(]+)\(")
LABEL_RE = re.compile(r"^\s*\^([A-Za-z0-9_.$-]+):\s*$")
SUCCESSORS_RE = re.compile(r"^\s*Successors:\s*(.+?)\s*$")
SUCCESSOR_LABEL_RE = re.compile(r"\^([A-Za-z0-9_.$-]+)")


@dataclass
class FunctionCFG:
    name: str
    index: int
    nodes: set[str] = field(default_factory=set)
    edges: set[tuple[str, str]] = field(default_factory=set)
    block_order: list[str] = field(default_factory=list)

    def add_node(self, label: str) -> None:
        if label not in self.nodes:
            self.nodes.add(label)
            self.block_order.append(label)

    def add_edge(self, src: str, dst: str) -> None:
        self.add_node(src)
        self.add_node(dst)
        self.edges.add((src, dst))


def parse_cfg_functions(path: Path) -> list[FunctionCFG]:
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    functions: list[FunctionCFG] = []
    current_func: FunctionCFG | None = None
    current_label: str | None = None

    def ensure_function() -> FunctionCFG:
        nonlocal current_func
        if current_func is None:
            current_func = FunctionCFG(name="global", index=len(functions))
            functions.append(current_func)
        return current_func

    for line in lines:
        func_match = FUNC_RE.match(line)
        if func_match:
            current_func = FunctionCFG(name=func_match.group(1), index=len(functions))
            functions.append(current_func)
            current_label = None
            continue

        label_match = LABEL_RE.match(line)
        if label_match:
            label = label_match.group(1)
            func = ensure_function()
            func.add_node(label)
            current_label = label
            continue

        succ_match = SUCCESSORS_RE.match(line)
        if succ_match and current_label is not None:
            func = ensure_function()
            raw_succ = succ_match.group(1)
            for succ in SUCCESSOR_LABEL_RE.findall(raw_succ):
                func.add_edge(current_label, succ)

    return functions


def to_dot(func: FunctionCFG) -> str:
    out: list[str] = []
    out.append("digraph cfg {")
    out.append('  graph [label="Function: %s (index=%d)", labelloc=t, fontsize=20];' % (func.name, func.index))
    out.append("  rankdir=LR;")
    out.append('  node [shape=box, fontname="monospace"];')

    for node in func.block_order:
        out.append(f'  "{node}";')

    for src, dst in sorted(func.edges):
        out.append(f'  "{src}" -> "{dst}";')

    out.append("}")
    return "\n".join(out) + "\n"


def pick_function(
    functions: list[FunctionCFG],
    function_index: int | None,
    function_name: str | None,
) -> FunctionCFG:
    if not functions:
        raise SystemExit("No labels/functions found.")

    if function_index is not None and function_name is not None:
        raise SystemExit("Use only one of --function-index or --function-name.")

    if function_name is not None:
        for f in functions:
            if f.name == function_name:
                return f
        raise SystemExit(f"Function not found: {function_name}")

    idx = 0 if function_index is None else function_index
    if idx < 0 or idx >= len(functions):
        raise SystemExit(f"--function-index out of range: {idx} (available 0..{len(functions)-1})")
    return functions[idx]


def render_graphviz(dot_path: Path, image_path: Path) -> None:
    dot_bin = shutil.which("dot")
    if dot_bin is None:
        raise SystemExit("Graphviz 'dot' not found in PATH. Install graphviz or skip --image-out.")

    ext = image_path.suffix.lower().lstrip(".")
    if not ext:
        raise SystemExit("--image-out must have an extension (e.g. .png or .svg).")

    subprocess.run(
        [dot_bin, f"-T{ext}", str(dot_path), "-o", str(image_path)],
        check=True,
    )


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Draw CFG from pass dump (using only ^label and Successors lines)."
    )
    parser.add_argument("input", type=Path, help="Pass dump text file")
    parser.add_argument(
        "--function-index",
        type=int,
        default=None,
        help="Function index to draw (default: 0)",
    )
    parser.add_argument(
        "--function-name",
        type=str,
        default=None,
        help="Function name to draw (alternative to --function-index)",
    )
    parser.add_argument(
        "--list-functions",
        action="store_true",
        help="List discovered functions and exit",
    )
    parser.add_argument(
        "--dot-out",
        type=Path,
        default=None,
        help="Write Graphviz .dot output path (default: <input>.cfg.dot)",
    )
    parser.add_argument(
        "--image-out",
        type=Path,
        default=None,
        help="Optional rendered output path (.png/.svg/...) via graphviz dot",
    )
    args = parser.parse_args()

    if not args.input.is_file():
        raise SystemExit(f"Input not found: {args.input}")

    functions = parse_cfg_functions(args.input)

    if args.list_functions:
        if not functions:
            print("No functions found.")
            return
        for f in functions:
            print(f"[{f.index}] {f.name}  nodes={len(f.nodes)} edges={len(f.edges)}")
        return

    target = pick_function(functions, args.function_index, args.function_name)
    dot_text = to_dot(target)

    dot_out = args.dot_out if args.dot_out is not None else Path(f"{args.input.stem}.cfg.dot")
    dot_out.write_text(dot_text, encoding="utf-8")
    print(f"Wrote DOT: {dot_out}")
    print(f"Selected function: [{target.index}] {target.name} (nodes={len(target.nodes)}, edges={len(target.edges)})")

    if args.image_out is not None:
        render_graphviz(dot_out, args.image_out)
        print(f"Wrote image: {args.image_out}")


if __name__ == "__main__":
    main()
