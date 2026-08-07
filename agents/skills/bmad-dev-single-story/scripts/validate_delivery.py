#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# ///
"""Validate deterministic BMad story completion and emit a compact Git manifest."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any

from story_state import parse_development_status, path_fingerprint


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
        (index for index, line in enumerate(lines) if re.match(r"^##\s+Tasks(?:\s*/\s*Subtasks|\s+and\s+Subtasks)?\s*$", line, re.IGNORECASE)),
        None,
    )
    if start is None:
        return []
    result: list[tuple[int, str]] = []
    skipping_review = False
    for index in range(start + 1, len(lines)):
        line = lines[index]
        heading = re.match(r"^(#{2,6})\s+(.+?)\s*$", line)
        if heading:
            level, title = len(heading.group(1)), heading.group(2)
            if level == 2:
                break
            if level <= 3:
                skipping_review = bool(
                    re.match(r"^(?:Review Follow-ups|Senior Developer Review)(?:\s*\(AI\))?", title, re.IGNORECASE)
                )
        if not skipping_review:
            result.append((index + 1, line))
    return result


def validate(args: argparse.Namespace) -> dict[str, Any]:
    root = args.project_root.resolve()
    story_file = (args.story_file if args.story_file.is_absolute() else root / args.story_file).resolve()
    sprint_file = (args.sprint_status if args.sprint_status.is_absolute() else root / args.sprint_status).resolve()
    architecture_file = root / "docs" / "story-flows" / f"{args.story_key}.md"
    failures: list[str] = []

    if not story_file.is_file():
        failures.append(f"missing story file: {story_file}")
        story_text = ""
    else:
        story_text = story_file.read_text(encoding="utf-8")
    if not sprint_file.is_file():
        failures.append(f"missing sprint status: {sprint_file}")
        sprint = {}
    else:
        sprint = parse_development_status(sprint_file)

    actual_story_status = story_status(story_text)
    sprint_story_status = sprint.get(args.story_key)
    if actual_story_status != args.expected_status:
        failures.append(f"story status is {actual_story_status!r}, expected {args.expected_status!r}")
    if sprint_story_status != args.expected_status:
        failures.append(f"sprint status is {sprint_story_status!r}, expected {args.expected_status!r}")

    unchecked = [
        {"line": number, "text": line.strip()}
        for number, line in implementation_task_lines(story_text)
        if re.match(r"^\s*[-*]\s+\[ \]\s+", line)
    ]
    if unchecked:
        failures.append(f"{len(unchecked)} unchecked story task(s)")

    architecture_checks = {
        "exists": architecture_file.is_file(),
        "has_mermaid": False,
        "links_global_architecture": False,
        "listed_in_story": False,
    }
    if architecture_file.is_file():
        architecture_text = architecture_file.read_text(encoding="utf-8")
        architecture_checks["has_mermaid"] = bool(re.search(r"```mermaid\s", architecture_text, re.IGNORECASE))
        architecture_checks["links_global_architecture"] = "_bmad-output/planning-artifacts/architecture.md" in architecture_text
    relative_architecture = architecture_file.relative_to(root).as_posix()
    architecture_checks["listed_in_story"] = relative_architecture in story_text
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

    required_paths = {
        story_file.relative_to(root).as_posix(),
        sprint_file.relative_to(root).as_posix(),
        relative_architecture,
    }
    required_conflicts = sorted(required_paths.intersection(preexisting))
    if required_conflicts:
        failures.append("required story artifacts overlap preexisting dirty paths")
    missing_candidates = sorted(required_paths.difference(candidate_paths).difference(staged))
    if missing_candidates:
        failures.append("required story artifacts are absent from the changed/staged manifest")

    return {
        "valid": not failures,
        "story_key": args.story_key,
        "expected_status": args.expected_status,
        "story_status": actual_story_status,
        "sprint_status": sprint_story_status,
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
    parser.add_argument("--story-key", required=True)
    parser.add_argument("--story-file", type=Path, required=True)
    parser.add_argument("--sprint-status", type=Path, required=True)
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
