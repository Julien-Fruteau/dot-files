#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///
"""Validate deterministic BMad story completion and emit a compact Git manifest.

Adapted to the spec-folder route: the story's own frontmatter is the single
status source (no sprint-status.yaml), and the architecture view is expected to
link back to the spec folder's SPEC.md rather than a global architecture file.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any

from epic_state import load_stories, path_fingerprint


def git(project_root: Path, *args: str) -> list[str]:
    output = subprocess.run(
        ["git", "-C", str(project_root), *args],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout
    return [line for line in output.splitlines() if line]


def story_status(text: str) -> str | None:
    patterns = (
        r"(?im)^Status:\s*`?([\w-]+)`?\s*$",
        r"(?im)^status:\s*['\"]?([\w-]+)['\"]?\s*$",
    )
    for pattern in patterns:
        match = re.search(pattern, text)
        if match:
            return match.group(1)
    return None


def implementation_task_lines(text: str) -> list[tuple[int, str]]:
    """Return implementation tasks, excluding nested AI review-follow-up sections."""
    lines = text.splitlines()
    start = next(
        (
            index
            for index, line in enumerate(lines)
            if re.match(r"^##\s+Tasks(?:\s*(?:&|/|and)\s*(?:Subtasks|Acceptance))?\s*$", line, re.IGNORECASE)
        ),
        None,
    )
    if start is None:
        return []
    collected: list[tuple[int, str]] = []
    for offset, line in enumerate(lines[start + 1 :], start=start + 2):
        if re.match(r"^##\s+", line):
            break
        if re.match(r"^###\s+.*(review|follow-?up)", line, re.IGNORECASE):
            break
        collected.append((offset, line))
    return collected


def validate(args: argparse.Namespace) -> dict[str, Any]:
    root = args.project_root.resolve()
    story_file = (args.story_file if args.story_file.is_absolute() else root / args.story_file).resolve()
    spec_folder = (args.spec_folder if args.spec_folder.is_absolute() else root / args.spec_folder).resolve()
    spec_file = spec_folder / "SPEC.md"
    architecture_file = root / "docs" / "story-flows" / f"{story_file.stem}.md"
    failures: list[str] = []

    if not story_file.is_file():
        failures.append(f"missing story file: {story_file}")
        story_text = ""
    else:
        story_text = story_file.read_text(encoding="utf-8")

    if not spec_file.is_file():
        failures.append(f"missing spec kernel: {spec_file}")
    else:
        try:
            known = {entry["id"] for entry in load_stories(spec_folder)}
            if args.story_id not in known:
                failures.append(f"story id {args.story_id!r} is absent from stories.yaml")
        except (OSError, ValueError) as exc:
            failures.append(f"stories.yaml unusable: {exc}")

    actual_story_status = story_status(story_text)
    if actual_story_status != args.expected_status:
        failures.append(f"story status is {actual_story_status!r}, expected {args.expected_status!r}")

    unchecked = [
        {"line": number, "text": line.strip()}
        for number, line in implementation_task_lines(story_text)
        if re.match(r"^\s*[-*]\s+\[ \]\s+", line)
    ]
    if unchecked:
        failures.append(f"{len(unchecked)} unchecked story task(s)")

    relative_architecture = architecture_file.relative_to(root).as_posix()
    relative_spec = spec_file.relative_to(root).as_posix()
    architecture_checks = {
        "exists": architecture_file.is_file(),
        "has_mermaid": False,
        "links_spec": False,
        "listed_in_story": relative_architecture in story_text,
    }
    if architecture_file.is_file():
        architecture_text = architecture_file.read_text(encoding="utf-8")
        architecture_checks["has_mermaid"] = bool(re.search(r"```mermaid\s", architecture_text, re.IGNORECASE))
        architecture_checks["links_spec"] = relative_spec in architecture_text or spec_folder.name in architecture_text
    for name, passed in architecture_checks.items():
        if not passed:
            failures.append(f"architecture check failed: {name}")

    changed = sorted(set(git(root, "diff", "--name-only", args.baseline)))
    untracked = sorted(set(git(root, "ls-files", "--others", "--exclude-standard")))
    staged = sorted(set(git(root, "diff", "--cached", "--name-only")))
    preexisting_state: dict[str, str] = {}
    malformed_state: list[str] = []
    for item in args.preexisting_state:
        if "=" not in item:
            malformed_state.append(item)
            continue
        path, fingerprint = item.rsplit("=", 1)
        preexisting_state[Path(path).as_posix()] = fingerprint
    if malformed_state:
        failures.append("preexisting state entries must use <path>=<sha256>")
    preexisting = set(preexisting_state)
    candidate_paths = sorted(set(changed + untracked).difference(preexisting))
    staged_conflicts = sorted(preexisting.intersection(staged))
    mutated_preexisting = sorted(
        path for path, fingerprint in preexisting_state.items() if path_fingerprint(root / path) != fingerprint
    )
    if staged_conflicts:
        failures.append("preexisting dirty paths were staged")
    if mutated_preexisting:
        failures.append("preexisting dirty paths changed after activation")

    required_paths = {story_file.relative_to(root).as_posix(), relative_architecture}
    required_conflicts = sorted(required_paths.intersection(preexisting))
    if required_conflicts:
        failures.append("required story artifacts overlap preexisting dirty paths")
    missing_candidates = sorted(required_paths.difference(candidate_paths).difference(staged))
    if missing_candidates:
        failures.append("required story artifacts are absent from the changed/staged manifest")

    return {
        "valid": not failures,
        "story_id": args.story_id,
        "story_file": story_file.relative_to(root).as_posix(),
        "spec_folder": spec_folder.relative_to(root).as_posix(),
        "expected_status": args.expected_status,
        "story_status": actual_story_status,
        "unchecked_tasks": unchecked,
        "architecture": {"path": relative_architecture, **architecture_checks},
        "git": {
            "baseline": args.baseline,
            "changed": changed,
            "untracked": untracked,
            "staged": staged,
            "candidate_paths": candidate_paths,
            "preexisting_conflicts": sorted(set(staged_conflicts + required_conflicts + mutated_preexisting)),
        },
        "failures": failures,
        "semantic_review_required": [
            "candidate path attribution to the story",
            "architecture agreement with implemented control/data flow",
            "acceptance-criteria satisfaction",
        ],
    }


def emit(payload: dict[str, Any], output: Path | None) -> None:
    rendered = json.dumps(payload, indent=2, ensure_ascii=False) + "\n"
    if output:
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(rendered, encoding="utf-8")
    else:
        sys.stdout.write(rendered)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("project_root", type=Path, help="Git/BMad project root")
    parser.add_argument("--story-id", required=True, help="story id as it appears in stories.yaml")
    parser.add_argument("--story-file", type=Path, required=True)
    parser.add_argument("--spec-folder", type=Path, required=True)
    parser.add_argument("--baseline", required=True, help="implementation baseline commit")
    parser.add_argument("--expected-status", default="done")
    parser.add_argument(
        "--preexisting-state",
        action="append",
        default=[],
        help="activation fingerprint as <path>=<sha256>; repeat as needed",
    )
    parser.add_argument("-o", "--output", type=Path, help="write JSON to this path")
    parser.add_argument("--verbose", action="store_true", help="emit diagnostics to stderr")
    args = parser.parse_args()
    try:
        payload = validate(args)
        emit(payload, args.output)
        return 0 if payload["valid"] else 1
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        if args.verbose:
            print(repr(exc), file=sys.stderr)
        emit({"valid": False, "error": str(exc), "action": "halt"}, args.output)
        return 2


if __name__ == "__main__":
    sys.exit(main())
