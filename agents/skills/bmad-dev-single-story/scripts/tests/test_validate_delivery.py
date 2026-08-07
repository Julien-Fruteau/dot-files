#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
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

from story_state import path_fingerprint  # noqa: E402
from validate_delivery import validate  # noqa: E402


class ValidateDeliveryTests(unittest.TestCase):
    def test_clean_deterministic_state(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            subprocess.run(["git", "init", "-q", str(root)], check=True)
            subprocess.run(["git", "-C", str(root), "config", "user.email", "test@example.com"], check=True)
            subprocess.run(["git", "-C", str(root), "config", "user.name", "Test"], check=True)
            artifacts = root / "_bmad-output" / "implementation-artifacts"
            artifacts.mkdir(parents=True)
            key = "1-1-first"
            status = artifacts / "sprint-status.yaml"
            status.write_text(f"development_status:\n  {key}: review\n", encoding="utf-8")
            (root / "README.md").write_text("test\n", encoding="utf-8")
            subprocess.run(["git", "-C", str(root), "add", "."], check=True)
            subprocess.run(["git", "-C", str(root), "commit", "-qm", "initial"], check=True)
            baseline = subprocess.run(
                ["git", "-C", str(root), "rev-parse", "HEAD"],
                check=True,
                text=True,
                stdout=subprocess.PIPE,
            ).stdout.strip()

            status.write_text(f"development_status:\n  {key}: done\n", encoding="utf-8")
            story = artifacts / f"{key}.md"
            story.write_text(
                "Status: done\n\n## Tasks / Subtasks\n- [x] implementation\n\n"
                "### Review Follow-ups (AI)\n- [ ] Low: optional polish\n\n## File List\n"
                f"- docs/story-flows/{key}.md\n",
                encoding="utf-8",
            )
            architecture = root / "docs" / "story-flows" / f"{key}.md"
            architecture.parent.mkdir(parents=True)
            architecture.write_text(
                "# Flow\n\n```mermaid\ngraph TD\n A --> B\n```\n\n"
                "[_global_](_bmad-output/planning-artifacts/architecture.md)\n",
                encoding="utf-8",
            )
            preexisting = root / "notes.txt"
            preexisting.write_text("unrelated\n", encoding="utf-8")
            preexisting_state = f"notes.txt={path_fingerprint(preexisting)}"
            args = argparse.Namespace(
                project_root=root,
                story_key=key,
                story_file=story,
                sprint_status=status,
                baseline=baseline,
                expected_status="done",
                preexisting_state=[preexisting_state],
            )
            result = validate(args)
            self.assertTrue(result["valid"], result["failures"])
            self.assertIn(f"docs/story-flows/{key}.md", result["git"]["candidate_paths"])
            self.assertNotIn("notes.txt", result["git"]["candidate_paths"])

            preexisting.write_text("worker changed unrelated content\n", encoding="utf-8")
            mutated = validate(args)
            self.assertFalse(mutated["valid"])
            self.assertIn("preexisting dirty paths changed after activation", mutated["failures"])


if __name__ == "__main__":
    unittest.main()
