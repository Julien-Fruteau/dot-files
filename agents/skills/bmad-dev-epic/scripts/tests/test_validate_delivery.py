#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = ["pyyaml"]
# ///

from __future__ import annotations

import argparse
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(SCRIPTS))

from epic_state import path_fingerprint  # noqa: E402
from validate_delivery import validate  # noqa: E402


class ValidateDeliveryTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.email", "test@example.com"], check=True)
        subprocess.run(["git", "-C", str(self.root), "config", "user.name", "Test"], check=True)

        self.spec = self.root / "ai" / "proj" / "specs" / "spec-demo"
        (self.spec / "stories").mkdir(parents=True)
        (self.spec / "SPEC.md").write_text("# SPEC\n", encoding="utf-8")
        (self.spec / "stories.yaml").write_text('- id: "1"\n  title: First\n', encoding="utf-8")
        (self.root / "README.md").write_text("test\n", encoding="utf-8")
        subprocess.run(["git", "-C", str(self.root), "add", "."], check=True)
        subprocess.run(["git", "-C", str(self.root), "commit", "-qm", "initial"], check=True)
        self.baseline = subprocess.run(
            ["git", "-C", str(self.root), "rev-parse", "HEAD"],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
        ).stdout.strip()

        self.stem = "1-first"
        self.story = self.spec / "stories" / f"{self.stem}.md"
        self.story.write_text(
            "---\nstatus: done\n---\n\n## Tasks & Acceptance\n- [x] implementation\n\n"
            "### Review Follow-ups (AI)\n- [ ] Low: optional polish\n\n## File List\n"
            f"- docs/story-flows/{self.stem}.md\n",
            encoding="utf-8",
        )
        architecture = self.root / "docs" / "story-flows" / f"{self.stem}.md"
        architecture.parent.mkdir(parents=True)
        architecture.write_text(
            "# Flow\n\n```mermaid\ngraph TD\n A --> B\n```\n\n"
            "[spec](../../ai/proj/specs/spec-demo/SPEC.md)\n",
            encoding="utf-8",
        )
        self.preexisting = self.root / "notes.txt"
        self.preexisting.write_text("unrelated\n", encoding="utf-8")

    def tearDown(self) -> None:
        self.temp.cleanup()

    def args(self, **overrides) -> argparse.Namespace:
        base = dict(
            project_root=self.root,
            story_id="1",
            story_file=self.story,
            spec_folder=self.spec,
            baseline=self.baseline,
            expected_status="done",
            preexisting_state=[f"notes.txt={path_fingerprint(self.preexisting)}"],
        )
        base.update(overrides)
        return argparse.Namespace(**base)

    def test_clean_deterministic_state(self) -> None:
        result = validate(self.args())
        self.assertTrue(result["valid"], result["failures"])
        self.assertIn(f"docs/story-flows/{self.stem}.md", result["git"]["candidate_paths"])
        self.assertNotIn("notes.txt", result["git"]["candidate_paths"])

    def test_review_follow_ups_do_not_count_as_unchecked_tasks(self) -> None:
        self.assertEqual(validate(self.args())["unchecked_tasks"], [])

    def test_mutated_preexisting_path_fails(self) -> None:
        args = self.args()
        self.preexisting.write_text("worker changed unrelated content\n", encoding="utf-8")
        result = validate(args)
        self.assertFalse(result["valid"])
        self.assertIn("preexisting dirty paths changed after activation", result["failures"])

    def test_story_id_absent_from_stories_yaml_fails(self) -> None:
        result = validate(self.args(story_id="9"))
        self.assertFalse(result["valid"])
        self.assertIn("story id '9' is absent from stories.yaml", result["failures"])

    def test_unchecked_implementation_task_fails(self) -> None:
        self.story.write_text(
            self.story.read_text(encoding="utf-8").replace("- [x] implementation", "- [ ] implementation"),
            encoding="utf-8",
        )
        result = validate(self.args())
        self.assertFalse(result["valid"])
        self.assertIn("1 unchecked story task(s)", result["failures"])

    def test_architecture_view_missing_spec_link_fails(self) -> None:
        architecture = self.root / "docs" / "story-flows" / f"{self.stem}.md"
        architecture.write_text("# Flow\n\n```mermaid\ngraph TD\n A --> B\n```\n", encoding="utf-8")
        result = validate(self.args())
        self.assertFalse(result["valid"])
        self.assertIn("architecture check failed: links_spec", result["failures"])


if __name__ == "__main__":
    unittest.main()
