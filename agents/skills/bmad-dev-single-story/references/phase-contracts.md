# Single-Story Phase Contracts

Load only the contract for the active phase. Every writer receives the compact handoff defined in `SKILL.md`, owns only the paths listed below, preserves `preexisting_dirty_paths`, and returns changed paths, validation commands/results, resulting status, and any exact blocker.

## Create

Use `bmad-create-story` for a `backlog` story. The worker owns only the matching story file and `sprint-status.yaml`; it must leave both statuses at `ready-for-dev`. Missing planning artifacts or decisions are halt conditions, not reasons to choose another story.

## Develop

Use `bmad-dev-story` for a `ready-for-dev` or unfinished `in-progress` story. The coding worker owns story-required source/tests, `sprint-status.yaml`, `docs/story-flows/<story-key>.md`, and the story's task checkboxes, Dev Agent Record, File List, Change Log, and Status.

Success means all tasks are checked, focused tests and configured checks pass, and both statuses are `review`. The architecture view describes the implemented result for a reader who was not in the session:

- one short purpose/scope paragraph;
- one Mermaid flow or component diagram;
- story-owned components and responsibilities;
- accurate boundaries to the global architecture with a link to `_bmad-output/planning-artifacts/architecture.md`;
- exclusions needed to avoid implying unimplemented behavior.

Keep it smaller than the story itself, list it in the story File List, and link it from completion notes.

## Review

Use `bmad-code-review` through a fresh independent reviewer. Review the complete story-owned diff from `implementation_baseline`, including committed and uncommitted changes, with the story as specification and the architecture view as an implementation map.

Require Blind Hunter, Edge Case Hunter, Acceptance Auditor, and Architecture View Auditor perspectives. The architecture audit checks that the diagram names actual components and behavior, matches control/data flow, and connects accurately to global architecture.

Map findings as follows:

- `decision_needed`: blocking user decision;
- `patch`: blocking unless explicitly Low/nit;
- `defer`: non-blocking and recorded in deferred work;
- `dismiss`: ignored.

Critical, High, and Medium are blocking; Low is non-blocking by default. A `patch` without severity is Medium.

## Fix

The coding worker—not a second overlapping capability—owns fixes for listed blocking findings. It may change only directly required source/tests, story review follow-ups and Dev Agent Record, the architecture view when behavior changes, and `sprint-status.yaml`.

Add regression tests where practical, resolve review checkboxes in place, synchronize equivalent `Review Follow-ups (AI)` or `Senior Developer Review (AI)` entries, and return both statuses to `review`. Run focused checks and full tests when practical. The next review is always independent.
