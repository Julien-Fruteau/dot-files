#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# ///
"""Resolve compact BMad story routing state without loading YAML into an LLM."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
from collections import OrderedDict
from pathlib import Path
from typing import Any

VALID_STATUSES = {"backlog", "ready-for-dev", "in-progress", "review", "done"}
ROUTES = {
    "backlog": "create",
    "ready-for-dev": "develop",
    "in-progress": "resume",
    "review": "review",
    "done": "complete",
}


def scalar(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


def parse_top_level_scalars(path: Path) -> dict[str, str]:
    result: dict[str, str] = {}
    for raw in path.read_text(encoding="utf-8").splitlines():
        if not raw or raw[0].isspace() or raw.lstrip().startswith("#"):
            continue
        match = re.match(r"^([A-Za-z_][\w-]*):\s*(.*?)\s*$", raw)
        if match and match.group(2):
            result[match.group(1)] = scalar(match.group(2))
    return result


def parse_development_status(path: Path) -> OrderedDict[str, str]:
    statuses: OrderedDict[str, str] = OrderedDict()
    in_section = False
    base_indent = 0
    for raw in path.read_text(encoding="utf-8").splitlines():
        stripped = raw.strip()
        if not in_section:
            if stripped == "development_status:":
                in_section = True
                base_indent = len(raw) - len(raw.lstrip())
            continue
        if not stripped or stripped.startswith("#"):
            continue
        indent = len(raw) - len(raw.lstrip())
        if indent <= base_indent:
            break
        match = re.match(r"^\s*([^:#][^:]*):\s*([^#]+?)\s*$", raw)
        if match:
            key, status = scalar(match.group(1).strip()), scalar(match.group(2).strip())
            statuses[key] = status
    if not statuses:
        raise ValueError(f"no development_status story entries found in {path}")
    return statuses


def expand_config(value: str, project_root: Path, config: dict[str, str]) -> str:
    expanded = value.replace("{project-root}", str(project_root))
    for _ in range(5):
        previous = expanded
        for key, item in config.items():
            expanded = expanded.replace("{" + key + "}", item.replace("{project-root}", str(project_root)))
        if expanded == previous:
            break
    return expanded


def git(project_root: Path, *args: str) -> str:
    return subprocess.run(
        ["git", "-C", str(project_root), *args],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout.strip()


def is_meta_key(key: str) -> bool:
    return bool(re.fullmatch(r"epic-\d+(?:-retrospective)?", key))


def path_fingerprint(path: Path) -> str:
    if path.is_symlink():
        payload = b"symlink\0" + os.readlink(path).encode("utf-8", errors="surrogateescape")
    elif path.is_file():
        payload = b"file\0" + path.read_bytes()
    elif path.is_dir():
        digest = hashlib.sha256(b"directory\0")
        for child in sorted(item for item in path.rglob("*") if item.is_file() or item.is_symlink()):
            digest.update(child.relative_to(path).as_posix().encode())
            digest.update(path_fingerprint(child).encode())
        return digest.hexdigest()
    else:
        payload = b"missing\0"
    return hashlib.sha256(payload).hexdigest()


def dirty_snapshot(project_root: Path) -> dict[str, str]:
    paths = set(git(project_root, "diff", "--name-only").splitlines())
    paths.update(git(project_root, "diff", "--cached", "--name-only").splitlines())
    paths.update(git(project_root, "ls-files", "--others", "--exclude-standard").splitlines())
    return {path: path_fingerprint(project_root / path) for path in sorted(paths) if path}


def resolve_story_file(artifacts: Path, key: str, supplied_path: Path | None) -> Path:
    if supplied_path is not None:
        return supplied_path
    expected = artifacts / f"{key}.md"
    if expected.exists():
        return expected
    matches = sorted(artifacts.rglob(f"{key}.md")) if artifacts.exists() else []
    return matches[0] if len(matches) == 1 else expected


def recorded_baseline(story_file: Path) -> str | None:
    if not story_file.exists():
        return None
    match = re.search(
        r"(?im)^\s*(?:[-*]\s*)?Implementation baseline:\s*`?([0-9a-f]{7,40})`?\s*$",
        story_file.read_text(encoding="utf-8"),
    )
    return match.group(1) if match else None


def resolve_baseline(project_root: Path, story_file: Path, key: str, status: str) -> tuple[str, str, str | None]:
    marker = recorded_baseline(story_file)
    if marker:
        try:
            return git(project_root, "rev-parse", marker), "story-marker", None
        except subprocess.CalledProcessError:
            return marker, "invalid-story-marker", f"recorded baseline {marker} is not a valid commit"

    head = git(project_root, "rev-parse", "HEAD")
    if status not in {"in-progress", "review", "done"}:
        return head, "current-head", None

    commits = git(project_root, "log", "--format=%H", "--reverse", "--fixed-strings", f"--grep={key}").splitlines()
    if commits:
        try:
            parent = git(project_root, "rev-parse", f"{commits[0]}^")
            return parent, "commit-history", "baseline inferred from the oldest story-key commit; confirm attribution"
        except subprocess.CalledProcessError:
            pass
    return head, "current-head-fallback", "no recorded or inferable implementation baseline; resolve the story-owned range before review"


def inspect(project_root: Path, requested: str | None) -> dict[str, Any]:
    project_root = project_root.resolve()
    config_path = project_root / "_bmad" / "bmm" / "config.yaml"
    if not config_path.is_file():
        raise ValueError(f"missing BMad config: {config_path}")
    config = parse_top_level_scalars(config_path)
    raw_artifacts = config.get("implementation_artifacts")
    if not raw_artifacts:
        raise ValueError(f"implementation_artifacts missing from {config_path}")
    artifacts = Path(expand_config(raw_artifacts, project_root, config)).resolve()
    sprint_status = artifacts / "sprint-status.yaml"
    if not sprint_status.is_file():
        raise ValueError(f"missing sprint status: {sprint_status}")
    statuses = parse_development_status(sprint_status)
    initial_dirty_state = dirty_snapshot(project_root)
    malformed = {key: status for key, status in statuses.items() if not is_meta_key(key) and status not in VALID_STATUSES}
    if malformed:
        details = ", ".join(f"{key}={status}" for key, status in malformed.items())
        raise ValueError(f"unknown story status in development_status: {details}")

    supplied_path: Path | None = None
    explicit = requested is not None
    if requested:
        candidate = Path(requested).expanduser()
        if candidate.suffix == ".md" or "/" in requested or "\\" in requested:
            supplied_path = (candidate if candidate.is_absolute() else project_root / candidate).resolve()
            key = supplied_path.stem
        else:
            key = requested
        if key not in statuses:
            raise ValueError(f"story key not present in development_status: {key}")
    else:
        key = ""
        for wanted in ("review", "in-progress", "ready-for-dev", "backlog"):
            key = next((item for item, state in statuses.items() if state == wanted and not is_meta_key(item)), "")
            if key:
                break
        if not key:
            return {
                "project_root": str(project_root),
                "config_path": str(config_path),
                "implementation_artifacts": str(artifacts),
                "sprint_status_path": str(sprint_status),
                "eligible": False,
                "action": "stop",
                "reason": "no eligible story",
                "initial_dirty_state": initial_dirty_state,
            }

    status = statuses[key]
    story_file = resolve_story_file(artifacts, key, supplied_path)
    baseline, baseline_source, warning = resolve_baseline(project_root, story_file, key, status)
    action = "report-complete-and-stop" if explicit and status == "done" else ROUTES[status]
    return {
        "project_root": str(project_root),
        "config_path": str(config_path),
        "implementation_artifacts": str(artifacts),
        "sprint_status_path": str(sprint_status),
        "eligible": status != "done",
        "explicit_request": explicit,
        "story_key": key,
        "story_status": status,
        "story_file": str(story_file),
        "story_file_exists": story_file.is_file(),
        "route": ROUTES[status],
        "action": action,
        "implementation_baseline": baseline,
        "baseline_source": baseline_source,
        "baseline_warning": warning,
        "initial_dirty_state": initial_dirty_state,
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
    parser.add_argument("project_root", type=Path, help="BMad project root")
    parser.add_argument("--story", help="explicit story key or markdown path")
    parser.add_argument("-o", "--output", type=Path, help="write JSON to this path")
    parser.add_argument("--verbose", action="store_true", help="emit diagnostics to stderr")
    args = parser.parse_args()
    try:
        payload = inspect(args.project_root, args.story)
        emit(payload, args.output)
        return 0
    except (OSError, ValueError, subprocess.CalledProcessError) as exc:
        if args.verbose:
            print(repr(exc), file=sys.stderr)
        emit({"error": str(exc), "action": "halt"}, args.output)
        return 1


if __name__ == "__main__":
    sys.exit(main())
