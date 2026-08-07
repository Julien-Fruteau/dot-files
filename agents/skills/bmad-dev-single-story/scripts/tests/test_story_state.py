#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# ///

from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

from story_state import inspect  # noqa: E402


class StoryStateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.email", "test@example.com"], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.name", "Test"], check=True)
        artifacts = self.root / "_bmad-output" / "implementation-artifacts"
        artifacts.mkdir(parents=True)
        config = self.root / "_bmad" / "bmm" / "config.yaml"
        config.parent.mkdir(parents=True)
        config.write_text('implementation_artifacts: "{project-root}/_bmad-output/implementation-artifacts"\n', encoding="utf-8")
        (artifacts / "sprint-status.yaml").write_text(
            "development_status:\n"
            "  epic-1: in-progress\n"
            "  1-1-first: review\n"
            "  1-2-second: backlog\n"
            "  epic-1-retrospective: optional\n",
            encoding="utf-8",
        )
        (self.root / "README.md").write_text("test\n", encoding="utf-8")
        subprocess.run(["git", "-C", str(self.root), "add", "."], check=True)
        subprocess.run(["git", "-C", str(self.root), "commit", "-qm", "initial"], check=True)

    def tearDown(self) -> None:
        self.temp.cleanup()

    def test_selects_review_before_backlog_and_warns_on_missing_baseline(self) -> None:
        result = inspect(self.root, None)
        self.assertEqual(result["story_key"], "1-1-first")
        self.assertEqual(result["route"], "review")
        self.assertIn("resolve the story-owned range", result["baseline_warning"])

    def test_explicit_done_story_stops_without_selecting_another(self) -> None:
        status = self.root / "_bmad-output" / "implementation-artifacts" / "sprint-status.yaml"
        status.write_text(status.read_text().replace("1-1-first: review", "1-1-first: done"), encoding="utf-8")
        result = inspect(self.root, "1-1-first")
        self.assertEqual(result["action"], "report-complete-and-stop")
        self.assertEqual(result["story_key"], "1-1-first")

    def test_unknown_story_status_halts_instead_of_selecting_other_work(self) -> None:
        status = self.root / "_bmad-output" / "implementation-artifacts" / "sprint-status.yaml"
        status.write_text(status.read_text().replace("1-1-first: review", "1-1-first: reveiw"), encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "unknown story status"):
            inspect(self.root, None)


if __name__ == "__main__":
    unittest.main()
