---
name: bmad-dev-single-story
description: Autonomously deliver exactly one BMad story by selecting the requested, current, last active, or next eligible story, then running create-story, dev-story, architecture-flow documentation, code-review, developer fixes, final verification, status synchronization, and a story commit. Use when the user asks to implement, finish, continue, complete, or review/fix a single BMad story, including "dev this story", "finish the current story", or "implement the next story". Stop and prompt the user instead of retrying when a missing dependency, unavailable service, ambiguous status, or product decision requires user action.
---

# BMad Dev Single Story

## Purpose

Deliver one BMad story end to end using the per-story chain from `bmad-dev-epic`, without looping over the rest of the epic. This skill is an orchestration skill: delegate major phases to fresh subagents when available, keep sprint tracking coherent, enforce review/fix cycles, and commit only the completed story.

Every delivered story also leaves a concise architecture view at `docs/story-flows/<story-key>.md`. Its reader should understand in under a minute what the story implemented, how control or data flows through it, and where it fits relative to the global architecture.

## Required Context

Before starting task actions:

1. Read `.agents/skills/bmad-create-story/SKILL.md`, `.agents/skills/bmad-dev-story/SKILL.md`, `.agents/skills/bmad-code-review/SKILL.md`, and `.agents/skills/bmad-agent-dev/SKILL.md`.
2. Load `{project-root}/_bmad/bmm/config.yaml` and resolve `implementation_artifacts`.
3. Read the full `{implementation_artifacts}/sprint-status.yaml` from start to end.
4. Run `git status --short`.
5. Record unrelated dirty files as `preexisting_dirty_paths`. Do not overwrite, stage, or commit them. Halt with exact conflicting paths if story changes cannot be isolated.
6. Record `pre_story_baseline = git rev-parse HEAD` immediately before story work begins.

## Automation Rules

- Execute only one story, then stop.
- Tell worker subagents that the user authorized autonomous execution and normal confirmation checkpoints are approved unless a true halt condition occurs.
- Do not delegate the same write set to multiple workers concurrently.
- Use narrow prompts naming the skill, repo path, story key, story file path, ownership boundaries, expected status transition, validation commands, and: "You are not alone in the codebase; do not revert unrelated changes."
- If subagents are unavailable, execute the same phases directly while respecting each underlying skill's ownership and status rules.
- Do not repeatedly retry a blocked dependency or decision. After one clear failure that requires user action, halt and ask the user for the specific action needed.

## Git Commands

Use git commands required to isolate, verify, stage, and commit the story. Prefer `rtk git ...` when available.

Allowed read-only commands:

- `git status --short`
- `git rev-parse HEAD`
- `git diff --name-only <baseline>`
- `git diff -- <path>...`
- `git ls-files --others --exclude-standard`
- `git log -1 --oneline`

Allowed finalization commands after story verification passes:

- `git add -- <story-file> <sprint-status-file> <story-owned-path>...`
- `git diff --cached --name-only`
- `git diff --cached --check`
- `git commit -m "feat: implement story <story-key>"`

Do not use destructive git commands such as `git reset`, `git checkout --`, `git restore`, `git clean`, or rebasing commands unless the user explicitly requests them. If `.git` metadata writes require elevated permissions, request escalation for the exact `git add` or `git commit` command, or for the repository-approved wrapper command such as `rtk git commit`; keep the command path list narrow.

## Story Selection

If the user provides a story key or path, use it.

If no story is provided:

1. Prefer the last non-`done` story that is already active in `development_status`, in this order: `review`, then `in-progress`, then `ready-for-dev`.
2. If none is active, select the next `backlog` story in `development_status` order.
3. If no eligible story exists, report that there is no story to deliver and stop.

Eligible statuses:

- `backlog`: create the story, then develop it.
- `ready-for-dev`: develop the story.
- `in-progress`: inspect the story file and continue development or review-fix work as appropriate.
- `review`: review the current story changes and fix blocking findings.
- `done`: if explicitly provided, report that it is complete, then select the next eligible story in `development_status` order. If no next eligible story exists, stop.

Skip `epic-N` and `epic-N-retrospective` keys. Always pass the explicit `story_key` and expected story file path to workers; do not rely on global auto-discovery.

## Delivery Chain

### 1. Create Story

Run this phase only when sprint status says `backlog`.

Delegate to `bmad-create-story`.

Worker ownership:

- The story file matching `<story-key>.md`.
- `sprint-status.yaml`.
- No source-code files.

Required result:

- Story file exists.
- Story status is `ready-for-dev`.
- Sprint status for the story is `ready-for-dev`.

If a required planning artifact, dependency, or user decision is missing, halt and ask for that item. Do not continue selecting another story.

### 2. Develop Story

Run this phase for `ready-for-dev` and unfinished `in-progress` stories.

Delegate to `bmad-dev-story`.

Worker ownership:

- Source and test files required by the story.
- `docs/story-flows/<story-key>.md`.
- The permitted story-file sections: task checkboxes, Dev Agent Record, File List, Change Log, and Status.
- `sprint-status.yaml`.

Required result:

- All story tasks and subtasks are checked, or a precise halt condition is reported.
- Story status is `review`.
- Sprint status for the story is `review`.
- Focused tests and configured quality checks pass.
- `docs/story-flows/<story-key>.md` describes the implemented result, not merely the planned design, and contains:
  - a one-paragraph purpose and scope;
  - a Mermaid flow diagram, or a Mermaid component diagram when the story has no meaningful runtime flow;
  - the story-owned components and their responsibilities;
  - how those components connect to the relevant boundaries or flows in the global architecture, with a link to `{project-root}/_bmad-output/planning-artifacts/architecture.md`;
  - important exclusions or unchanged neighboring components when needed to prevent a misleading reading.

Keep this architecture view deliberately small. Prefer one diagram and short annotations over duplicating the story or global architecture. Add it to the story File List and link it from the Dev Agent Record completion notes.

If development fails because a dependency must be installed, a service must be started, credentials are missing, migrations require user approval, or product behavior is ambiguous, halt with the exact command, dependency, service, credential, or decision needed. Do not loop or pick another story.

### 3. Review Story

Run this phase for `review` stories and after each development or fix phase.

Delegate to `bmad-code-review`.

Review target:

- Current story changes since `pre_story_baseline`.
- The story file as spec context.
- `docs/story-flows/<story-key>.md` as the story's implemented architecture view.

Required review layers:

- Blind Hunter.
- Edge Case Hunter.
- Acceptance Auditor.
- Architecture View Auditor: verify that the diagram matches the implemented control/data flow, names the actual story-owned components, links them accurately to the global architecture, and does not imply unimplemented behavior.

Finding mapping:

- `decision_needed`: blocking; halt for user input.
- `patch`: blocking by default; fix unless explicitly Low/nit.
- `defer`: non-blocking; append to deferred work if the review worker has not already done so.
- `dismiss`: ignore.
- Critical, High, and Medium findings are blocking. Low findings are non-blocking by default.
- If severity is absent, treat `patch` as Medium.

If the review has no blocking findings, continue to finalization.

### 4. Fix Blocking Review Findings

If review reports blocking findings, delegate to `bmad-agent-dev` plus `bmad-dev-story` context to fix only those findings.

Fix worker ownership:

- Files directly required for the listed findings.
- `docs/story-flows/<story-key>.md` when a finding changes or corrects the documented flow.
- Story review follow-up checkboxes and Dev Agent Record.
- `sprint-status.yaml`.

Rules:

- Add or update regression tests for each fixed finding where practical.
- Mark corresponding review findings resolved in the story file.
- If `bmad-code-review` wrote `### Review Findings`, resolve those checkboxes in place.
- Keep equivalent `Review Follow-ups (AI)` or `Senior Developer Review (AI)` items synchronized when present.
- Return story and sprint status to `review`.
- Run focused tests, configured quality checks, and full tests when practical.

Repeat review after fixes. Continue review/fix cycles until there are no Critical/High/Medium findings. Halt after three consecutive fix cycles for the same story if blocking findings remain; report unresolved findings and exact files.

### 5. Finalize Story

After a clean final review:

1. Run local verification from the main agent:
   - Focused tests named by the dev or fix worker. If none are named, run tests for touched test files.
   - `go-task check` when `Taskfile.yml` exists and defines `check`.
   - `uv run pytest` when `pyproject.toml` configures pytest or `tests/` exists.
2. If verification fails because the local PostgreSQL test database is not reachable at the repo's configured host/port, attempt `rtk go-task db-up` exactly once from the main agent, then rerun the failed verification command once.
3. If `rtk go-task db-up` fails, or the rerun still needs a missing database/service prerequisite, halt and ask once for the specific action with the command output summary. Do not retry continuously.
4. If verification needs any other missing dependency, service, credential, approval, or user action, halt and ask once for the specific action. Do not retry continuously.
5. Update the story file `Status:` to `done`.
6. Confirm `docs/story-flows/<story-key>.md` exists, contains a Mermaid diagram, links to the global architecture, and agrees with the final touched source files and reviewed behavior.
7. Add a short Dev Agent Record completion note that final review passed and link the architecture view; ensure the architecture view appears in the story File List.
8. Update `sprint-status.yaml` story key to `done` and refresh `last_updated`.
9. Compute changed files with `git diff --name-only pre_story_baseline` plus untracked files from `git status --short`.
10. Exclude every `preexisting_dirty_paths` entry unless the user explicitly allowed including it.
11. Confirm the staging set with `git diff --name-only pre_story_baseline` and `git ls-files --others --exclude-standard`; halt if any included path cannot be attributed to the story.
12. Stage only files belonging to the story with an explicit pathspec: the story file, `sprint-status.yaml`, `docs/story-flows/<story-key>.md`, and source/test/config/docs files modified for that story.
13. Check staged files with `git diff --cached --name-only` and `git diff --cached --check`.
14. Commit with `feat: implement story <story-key>` unless the user supplied another convention.

If git staging or commit needs elevated permissions because worktree metadata is outside the sandbox, request escalation for the exact git command. Do not use broad approval prefixes.

## Stop Conditions

Halt and report concrete evidence when:

- Sprint status is missing or malformed.
- A story key cannot be mapped to a story file after creation.
- The final architecture view is missing or contradicts the reviewed implementation.
- The requested story is `done` and no next eligible story exists.
- A worker modifies unrelated files.
- Tests or quality checks fail and the active worker cannot fix them.
- A missing dependency, service, credential, migration approval, or external action requires the user.
- Product behavior or acceptance criteria require a user decision.
- The same story has three unresolved Critical/High/Medium review cycles.
- Git cannot isolate story changes from unrelated dirty files.

When halting for user action, ask for the exact next action or decision and stop. Do not keep selecting stories, rerunning the same command, or retrying the same blocked phase.
