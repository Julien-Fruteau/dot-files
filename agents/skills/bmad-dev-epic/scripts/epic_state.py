#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///
"""Resolve compact BMad epic routing state from a spec folder's stories.yaml.

Source of truth is `{spec_folder}/stories.yaml` plus the per-story spec files
under `{spec_folder}/stories/`. There is no sprint-status.yaml in this route:
`stories.yaml` carries no status field by schema, so each story's status is
read from its own spec file's frontmatter, written by bmad-build.

Config comes from the four-layer TOML merge (_bmad/config.toml ->
config.user.toml -> custom/config.toml -> custom/config.user.toml), never from
the installer-generated _bmad/*/config.yaml mirrors, which do not receive
custom overrides.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import tomllib
from pathlib import Path
from typing import Any

import yaml

# Status vocabulary written by bmad-build into a story spec's frontmatter.
BUILD_STATUSES = {"draft", "in-progress", "in-review", "done"}

# What the orchestrator does next for a given story status.
#   dispatch  -> hand the story to bmad-build (first run or resume)
#   finalize  -> bmad-build is done reviewing; the epic owns the gate to `done`
#   skip      -> nothing left to do
ROUTES = {
    "absent": "dispatch",
    "draft": "dispatch",
    "in-progress": "dispatch",
    "in-review": "finalize",
    "done": "skip",
}

_ID_RE = re.compile(r"^[A-Za-z0-9-]+$")


def deep_merge(base: dict[str, Any], overlay: dict[str, Any]) -> dict[str, Any]:
    merged = dict(base)
    for key, value in overlay.items():
        if isinstance(value, dict) and isinstance(merged.get(key), dict):
            merged[key] = deep_merge(merged[key], value)
        else:
            merged[key] = value
    return merged


def load_central_config(project_root: Path) -> dict[str, Any]:
    """Mirror _bmad/scripts/config_utils.load_central_config without importing it."""
    bmad = project_root / "_bmad"
    layers = (
        bmad / "config.toml",
        bmad / "config.user.toml",
        bmad / "custom" / "config.toml",
        bmad / "custom" / "config.user.toml",
    )
    merged: dict[str, Any] = {}
    for index, layer in enumerate(layers):
        if not layer.is_file():
            if index == 0:
                raise ValueError(f"missing BMad config: {layer}")
            continue
        merged = deep_merge(merged, tomllib.loads(layer.read_text(encoding="utf-8")))
    return merged


def expand(value: str, project_root: Path) -> str:
    return value.replace("{project-root}", str(project_root))


def resolve_spec_folder(project_root: Path, requested: str) -> Path:
    """Accept a path, or a bare slug resolved under {output_folder}/specs."""
    candidate = Path(requested).expanduser()
    if candidate.is_absolute() or candidate.exists() or "/" in requested or "\\" in requested:
        resolved = candidate if candidate.is_absolute() else project_root / candidate
        return resolved.resolve()

    config = load_central_config(project_root)
    output_folder = config.get("core", {}).get("output_folder")
    if not output_folder:
        raise ValueError("core.output_folder missing from the merged BMad config")
    specs = Path(expand(output_folder, project_root)) / "specs"
    slug = requested if requested.startswith("spec-") else f"spec-{requested}"
    return (specs / slug).resolve()


def load_stories(spec_folder: Path) -> list[dict[str, Any]]:
    path = spec_folder / "stories.yaml"
    if not path.is_file():
        raise ValueError(f"missing stories.yaml: {path}")
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(data, list) or not data:
        raise ValueError(f"stories.yaml must be a non-empty YAML list: {path}")

    seen: set[str] = set()
    entries: list[dict[str, Any]] = []
    for position, raw in enumerate(data):
        if not isinstance(raw, dict):
            raise ValueError(f"stories.yaml entry {position} is not a mapping")
        story_id = raw.get("id")
        if not isinstance(story_id, str) or not _ID_RE.fullmatch(story_id):
            raise ValueError(f"stories.yaml entry {position}: id must be a quoted string of letters, digits and dashes")
        if "status" in raw:
            raise ValueError(f"stories.yaml entry {story_id!r}: a status field is forbidden by the schema")
        if story_id in seen:
            raise ValueError(f"duplicate story id: {story_id}")
        for other in seen:
            if story_id.startswith(f"{other}-") or other.startswith(f"{story_id}-"):
                raise ValueError(f"story ids must be prefix-free: {other!r} and {story_id!r} collide")
        seen.add(story_id)
        if not raw.get("title"):
            raise ValueError(f"stories.yaml entry {story_id!r}: title is required")
        entries.append(
            {
                "id": story_id,
                "title": str(raw["title"]).strip(),
                "description": str(raw.get("description", "")).strip(),
                "spec_checkpoint": bool(raw.get("spec_checkpoint", False)),
                "done_checkpoint": bool(raw.get("done_checkpoint", False)),
                "invoke_dev_with": str(raw.get("invoke_dev_with", "")).strip(),
            }
        )
    return entries


def frontmatter_status(story_file: Path) -> str | None:
    if not story_file.is_file():
        return None
    text = story_file.read_text(encoding="utf-8")
    match = re.search(r"(?im)^status:\s*['\"]?([\w-]+)['\"]?\s*$", text)
    return match.group(1) if match else None


def locate_story_file(spec_folder: Path, story_id: str) -> tuple[Path | None, list[Path]]:
    stories_dir = spec_folder / "stories"
    matches = sorted(stories_dir.glob(f"{story_id}-*.md")) if stories_dir.is_dir() else []
    if len(matches) == 1:
        return matches[0], matches
    return None, matches


def git(project_root: Path, *args: str) -> str:
    return subprocess.run(
        ["git", "-C", str(project_root), *args],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout.strip()


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


def recorded_baseline(story_file: Path | None) -> str | None:
    if story_file is None or not story_file.is_file():
        return None
    match = re.search(
        r"(?im)^\s*(?:[-*]\s*)?(?:Implementation baseline|baseline_commit):\s*`?([0-9a-f]{7,40})`?\s*$",
        story_file.read_text(encoding="utf-8"),
    )
    return match.group(1) if match else None


def resolve_baseline(project_root: Path, story_file: Path | None, status: str) -> tuple[str, str, str | None]:
    marker = recorded_baseline(story_file)
    if marker:
        try:
            return git(project_root, "rev-parse", marker), "story-marker", None
        except subprocess.CalledProcessError:
            return marker, "invalid-story-marker", f"recorded baseline {marker} is not a valid commit"

    head = git(project_root, "rev-parse", "HEAD")
    if status in {"absent", "draft"}:
        return head, "current-head", None
    return head, "current-head-fallback", (
        "no recorded baseline on a started story; resolve the story-owned commit range before finalizing"
    )


def inspect(project_root: Path, spec_folder_arg: str, requested_story: str | None) -> dict[str, Any]:
    project_root = project_root.resolve()
    spec_folder = resolve_spec_folder(project_root, spec_folder_arg)
    if not spec_folder.is_dir():
        raise ValueError(f"spec folder not found: {spec_folder}")
    if not (spec_folder / "SPEC.md").is_file():
        raise ValueError(f"no SPEC.md in spec folder: {spec_folder}")

    entries = load_stories(spec_folder)
    initial_dirty_state = dirty_snapshot(project_root)

    stories: list[dict[str, Any]] = []
    for entry in entries:
        story_file, matches = locate_story_file(spec_folder, entry["id"])
        if len(matches) > 1:
            raise ValueError(
                f"ambiguous story file match for id {entry['id']!r}: "
                + ", ".join(str(item.relative_to(project_root)) for item in matches)
            )
        status = frontmatter_status(story_file) if story_file else None
        if story_file is not None and status is None:
            raise ValueError(f"story file has no status frontmatter: {story_file}")
        if status is not None and status not in BUILD_STATUSES:
            raise ValueError(f"unknown status {status!r} in {story_file}")
        effective = status or "absent"
        stories.append(
            {
                **entry,
                "status": effective,
                "route": ROUTES[effective],
                "story_file": str(story_file.relative_to(project_root)) if story_file else None,
                "eligible": ROUTES[effective] != "skip",
            }
        )

    if requested_story is not None:
        selected = next((item for item in stories if item["id"] == requested_story), None)
        if selected is None:
            raise ValueError(f"story id not present in stories.yaml: {requested_story}")
    else:
        selected = next((item for item in stories if item["eligible"]), None)

    payload: dict[str, Any] = {
        "project_root": str(project_root),
        "spec_folder": str(spec_folder.relative_to(project_root)),
        "spec_file": str((spec_folder / "SPEC.md").relative_to(project_root)),
        "stories": stories,
        "remaining": [item["id"] for item in stories if item["eligible"]],
        "initial_dirty_state": initial_dirty_state,
    }

    if selected is None:
        payload.update({"action": "epic-complete", "reason": "no eligible story remains"})
        return payload

    story_file = (project_root / selected["story_file"]) if selected["story_file"] else None
    baseline, source, warning = resolve_baseline(project_root, story_file, selected["status"])
    payload.update(
        {
            "action": selected["route"],
            "story": selected,
            "implementation_baseline": baseline,
            "baseline_source": source,
            "baseline_warning": warning,
        }
    )
    return payload


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
    parser.add_argument("--spec-folder", required=True, help="spec folder path, or a bare slug under {output_folder}/specs")
    parser.add_argument("--story", help="explicit story id; default selects the first eligible story in list order")
    parser.add_argument("-o", "--output", type=Path, help="write JSON to this path")
    parser.add_argument("--verbose", action="store_true", help="emit diagnostics to stderr")
    args = parser.parse_args()
    try:
        emit(inspect(args.project_root, args.spec_folder, args.story), args.output)
        return 0
    except (OSError, ValueError, yaml.YAMLError, subprocess.CalledProcessError) as exc:
        if args.verbose:
            print(repr(exc), file=sys.stderr)
        emit({"error": str(exc), "action": "halt"}, args.output)
        return 1


if __name__ == "__main__":
    sys.exit(main())
