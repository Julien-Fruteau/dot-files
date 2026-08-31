#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///

from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

from epic_state import inspect  # noqa: E402

STORIES = """\
- id: "1"
  title: First story
  description: does the first thing
- id: "2"
  title: Second story
  description: does the second thing
  done_checkpoint: true
"""


class EpicStateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.email", "test@example.com"], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.name", "Test"], check=True)

        config = self.root / "_bmad" / "config.toml"
        config.parent.mkdir(parents=True)
        config.write_text('[core]\noutput_folder = "{project-root}/ai/proj"\n', encoding="utf-8")

        self.spec = self.root / "ai" / "proj" / "specs" / "spec-demo"
        (self.spec / "stories").mkdir(parents=True)
        (self.spec / "SPEC.md").write_text("# SPEC\n", encoding="utf-8")
        (self.spec / "stories.yaml").write_text(STORIES, encoding="utf-8")

        (self.root / "README.md").write_text("test\n", encoding="utf-8")
        subprocess.run(["git", "-C", str(self.root), "add", "."], check=True)
        subprocess.run(["git", "-C", str(self.root), "commit", "-qm", "initial"], check=True)

    def tearDown(self) -> None:
        self.temp.cleanup()

    def write_story(self, story_id: str, slug: str, status: str) -> Path:
        path = self.spec / "stories" / f"{story_id}-{slug}.md"
        path.write_text(f"---\nstatus: {status}\n---\n\n# {slug}\n", encoding="utf-8")
        return path

    def test_bare_slug_resolves_against_output_folder(self) -> None:
        result = inspect(self.root, "demo", None)
        self.assertEqual(result["spec_folder"], "ai/proj/specs/spec-demo")

    def test_absent_story_file_routes_to_dispatch_in_list_order(self) -> None:
        result = inspect(self.root, str(self.spec), None)
        self.assertEqual(result["action"], "dispatch")
        self.assertEqual(result["story"]["id"], "1")
        self.assertEqual(result["story"]["status"], "absent")
        self.assertEqual(result["remaining"], ["1", "2"])

    def test_in_review_routes_to_finalize_and_done_is_skipped(self) -> None:
        self.write_story("1", "first", "done")
        self.write_story("2", "second", "in-review")
        result = inspect(self.root, str(self.spec), None)
        self.assertEqual(result["action"], "finalize")
        self.assertEqual(result["story"]["id"], "2")
        self.assertTrue(result["story"]["done_checkpoint"])
        self.assertEqual(result["remaining"], ["2"])

    def test_all_done_reports_epic_complete(self) -> None:
        self.write_story("1", "first", "done")
        self.write_story("2", "second", "done")
        result = inspect(self.root, str(self.spec), None)
        self.assertEqual(result["action"], "epic-complete")
        self.assertEqual(result["remaining"], [])

    def test_started_story_without_baseline_marker_warns(self) -> None:
        self.write_story("1", "first", "in-review")
        result = inspect(self.root, str(self.spec), None)
        self.assertIn("resolve the story-owned commit range", result["baseline_warning"])

    def test_ambiguous_story_file_halts(self) -> None:
        self.write_story("1", "first", "draft")
        self.write_story("1", "first-bis", "draft")
        with self.assertRaisesRegex(ValueError, "ambiguous story file match"):
            inspect(self.root, str(self.spec), None)

    def test_unknown_status_halts(self) -> None:
        self.write_story("1", "first", "reveiw")
        with self.assertRaisesRegex(ValueError, "unknown status"):
            inspect(self.root, str(self.spec), None)

    def test_status_field_in_stories_yaml_is_rejected(self) -> None:
        (self.spec / "stories.yaml").write_text(
            '- id: "1"\n  title: First\n  status: done\n', encoding="utf-8"
        )
        with self.assertRaisesRegex(ValueError, "status field is forbidden"):
            inspect(self.root, str(self.spec), None)

    def test_prefix_colliding_ids_are_rejected(self) -> None:
        (self.spec / "stories.yaml").write_text(
            '- id: "3"\n  title: A\n- id: "3-2"\n  title: B\n', encoding="utf-8"
        )
        with self.assertRaisesRegex(ValueError, "prefix-free"):
            inspect(self.root, str(self.spec), None)

    def test_custom_layer_overrides_base_output_folder(self) -> None:
        custom = self.root / "_bmad" / "custom" / "config.toml"
        custom.parent.mkdir(parents=True)
        custom.write_text('[core]\noutput_folder = "{project-root}/ai/other"\n', encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "spec folder not found"):
            inspect(self.root, "demo", None)


if __name__ == "__main__":
    unittest.main()
