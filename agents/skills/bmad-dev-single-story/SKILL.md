---
name: bmad-dev-single-story
description: Autonomously deliver exactly one BMad story through creation, implementation, architecture-flow documentation, independent review, fixes, verification, status synchronization, and a story-only commit. Use when the user asks to implement, finish, continue, complete, or review/fix one BMad story, including "dev this story", "finish the current story", or "implement the next story". Stop for missing dependencies, unavailable services, ambiguous state, or product decisions that require the user.
---

# BMad Dev Single Story

## Outcome

Deliver exactly one selected story to `done` and commit only its attributable files. Preserve unrelated work, leave a concise implemented architecture view at `docs/story-flows/<story-key>.md`, and stop rather than guessing when user action is required.

## Activate and Route

Resolve every bare `scripts/...` and `references/...` path against this skill's installed directory, never the target project's working directory.

1. Inspect story state with `uv run scripts/story_state.py {project-root} [--story <key-or-path>]`. It resolves BMad config, parses sprint status, selects the route, and recovers a recorded implementation baseline without loading full tracking files into the coordinator. If the script cannot run, derive the same compact facts directly.
2. Classify the state script's `initial_dirty_state` against the selected story. Story-attributable dirty paths join the review target; retain every unrelated path and fingerprint as `preexisting_dirty_state`. Never overwrite, stage, or commit unrelated paths. Halt with exact conflicts when attribution or isolation is impossible.
3. If an explicitly requested story is already `done`, report it and stop. Only auto-select another story when the user asked for the current or next story.
4. Load `references/phase-contracts.md` only after the route is known, and only the contract for the phase being executed. Underlying skills are loaded by their assigned worker, not by the coordinator.

Before the first source edit, record `Implementation baseline: <sha>` in the story's Dev Agent Record when absent. On a resumed story, use the baseline returned by the state script; if it warns that no reliable baseline exists, resolve the story-owned commit range before review rather than silently reviewing only new changes.

## Lean Delegation

Do story selection, status parsing, Git manifests, and structural validation locally through scripts; they do not merit subagents. Delegate only judgment-heavy phases:

- creation or bounded artifact work: a lightweight `delegate`, using `{agent.bounded_worker_model}` when configured;
- implementation and fixes: one coding `worker`, using `{agent.coding_worker_model}` when configured;
- final review: a fresh independent `reviewer`, using `{agent.review_worker_model}` when configured.

When explicit model selection is available and no override is configured, choose the least expensive available model adequate for the role. Do not use a general-purpose worker when a coding or review specialist exists. Keep one writer active at a time. Reuse the implementation worker for tightly coupled fixes when the runtime preserves its context; the final reviewer remains fresh and independent.

Every worker receives only this compact handoff plus its phase contract:

```text
repo, story_key, story_file, status, implementation_baseline,
preexisting_dirty_state, owned_paths, expected_transition,
validation_commands, unresolved_findings, architecture_view
```

Tell writers: "Autonomous execution is authorized. You are not alone in the codebase; do not revert unrelated changes. Stop on a true halt condition." After each return, retain only changed paths, commands/results, status, findings, and the next-action blocker—not the transcript. Compact at phase boundaries when supported, before the parent context approaches 150k tokens.

If subagents are unavailable, execute the same phase directly. Never run concurrent writers or retry a user-owned blocker.

## Delivery

- `backlog` → run **Create**, then refresh state.
- `ready-for-dev` → run **Develop**.
- `in-progress` → inspect unchecked work and run **Develop** or proceed to review when implementation is complete.
- `review` → run **Review**.
- `done` → stop for an explicit story; otherwise no eligible story remains for this invocation.

Workers follow the applicable contract in `references/phase-contracts.md` and return the compact handoff. Review targets the complete story-owned range from `implementation_baseline`, including already committed work, plus the story and architecture view.

Critical, High, and Medium review findings block completion. Fix blocking findings with the implementation worker, add regression coverage where practical, then run a fresh review. Low findings are non-blocking by default. Stop after three fix cycles with unresolved blocking findings.

## Finalize

After a clean review:

1. Run worker-reported focused tests, then configured project checks. When the configured local PostgreSQL test database alone is unavailable, run `rtk go-task db-up` once and retry the failed command once.
2. Set story and sprint status to `done`, refresh `last_updated`, and record that final review passed. Keep the architecture view linked from the Dev Agent Record and listed in the story File List.
3. Validate deterministic completion with `uv run scripts/validate_delivery.py {project-root} --story-key <key> --story-file <path> --sprint-status <path> --baseline <sha> --expected-status done`, adding each activation fingerprint as `--preexisting-state '<path>=<sha256>'`. The script checks status synchronization, implementation tasks, architecture structure, changed/staged manifests, and whether unrelated dirty files were altered; semantic agreement remains review judgment.
4. Attribute every candidate path to the story. Stage only explicit story-owned paths, then require `git diff --cached --name-only` and `git diff --cached --check` to pass.
5. Commit as `feat: implement story <story-key>` unless the user supplied another convention, then stop.

Allowed Git writes are narrow `git add -- <paths>` and `git commit`. Never use reset, restore, checkout, clean, rebase, or broad staging. Request exact-command escalation if repository metadata permissions require it.

## Halt Invariant

Halt once with concrete evidence and the exact next action when state is missing or malformed, ownership cannot be isolated, a worker touches unrelated files, required checks fail beyond the one database recovery, three review-fix cycles remain blocked, a dependency/service/credential/approval is missing, or acceptance behavior needs a product decision. Do not select another story, spawn a workaround worker, or repeat the blocked command.
