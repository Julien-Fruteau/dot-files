---
name: bmad-dev-epic
description: Autonomously deliver every remaining story in a BMad epic by repeatedly delegating one explicit story at a time to bmad-dev-single-story, then completing the epic status and commit when all stories are done. Use when the user asks to implement, dev, complete, or loop over all stories of an epic with BMad workflows and subagents. Stop and prompt the user instead of retrying when the delegated single-story workflow reports a missing dependency, unavailable service, ambiguous status, or product decision requiring user action.
---

# BMad Dev Epic

## Purpose

Run the proven BMad story delivery chain repeatedly for every eligible story in one epic. This skill is an epic-level orchestration skill: it selects the next story in the requested epic, delegates that single story to `bmad-dev-single-story`, verifies the story reached `done`, then repeats until the epic has no remaining eligible stories.

## Inputs

- Epic identifier from the user, such as `epic 2`, `2`, or `epic-2`.
- Optional stop rule, such as a maximum number of stories. If absent, continue until the epic has no remaining backlog, ready-for-dev, in-progress, or review stories.
- Optional commit-message convention. If absent, use `feat: implement story <story-key>`.

## Preconditions

1. Read the sibling skill `bmad-dev-single-story/SKILL.md`, resolved against this skill's parent directory, before starting task actions.
2. Load `_bmad/bmm/config.yaml` and resolve `implementation_artifacts`.
3. Read the full `sprint-status.yaml` from start to end.
4. Run `git status --short`.
5. If unrelated dirty files exist, record them as `preexisting_dirty_paths`. Do not overwrite or stage them. Continue only when each story's changes can be isolated; otherwise halt with the exact conflicting paths.

## Automation Overrides

This skill is only for explicit autonomous epic execution. When invoking `bmad-dev-single-story`, tell the worker that the user has already authorized autonomous execution and that normal confirmation checkpoints should be treated as approved unless the worker hits a real halt condition.

The delegated single-story workflow owns create/dev/review/fix/finalize behavior and the per-story commit. The epic workflow owns epic-scoped story selection, loop control, and final epic completion.

The epic workflow also owns one post-story verification gate: after each delegated story is complete, prove that all applicable tests pass before selecting another story. At minimum, run the focused tests that cover the story changes and run `go-task test` from the main agent. Treat this as mandatory even when the single-story workflow has already run focused tests, `go-task check`, or other validation.

## Story Selection

For the target epic, process stories in the order they appear in `development_status`.

Eligible story statuses:

- `backlog`
- `ready-for-dev`
- `in-progress`
- `review`

Skip stories already marked `done`. Skip `epic-N` and `epic-N-retrospective` keys.

Always pass the explicit `story_key`, target epic, and expected story file path to `bmad-dev-single-story`. Do not rely on global auto-discovery while looping an epic.

## Per-Story Loop

For each eligible story in the target epic:

1. Record the story key, current status, and expected story file path.
2. Invoke `bmad-dev-single-story` for that explicit story only.
3. Instruct the worker to:
   - Use the provided `story_key` and story file path.
   - Execute only that story and stop.
   - Preserve `preexisting_dirty_paths`.
   - Commit the story with `feat: implement story <story-key>` unless the user supplied another convention.
   - Halt immediately if a dependency, service, credential, approval, external action, or product decision requires the user.
4. After the worker returns, reload the full `sprint-status.yaml`.
5. Verify the story key is `done`.
6. Verify the story commit was created or the worker reported an explicit reason commit was not possible.
7. Run or rerun the focused tests that cover the story changes, using the worker-reported focused commands when available and otherwise deriving them from touched test files. Require them to pass.
8. Run `go-task test` from the main agent and require it to pass.
9. If a required test command fails because the local PostgreSQL test database is not reachable at the repo's configured host/port, attempt `rtk go-task db-up` exactly once from the main agent, then rerun the failed required test command once. If `rtk go-task db-up` fails, or the rerun still fails for a missing database/service prerequisite, halt immediately with the command output summary and ask the user for the exact missing action.
10. If any required test command fails because the local environment is missing Docker, another running service, credentials, environment variables, network access, database setup not covered by the one `rtk go-task db-up` attempt, or any other external prerequisite, halt immediately and ask the user for the exact missing action. Do not retry the same command again, ask another worker to work around it, or select another story.
11. If any required test command fails because of code or test behavior, keep the active story as the only work item and route the failure back through the single-story review/fix path. Do not select another story until the story-covering focused tests and `go-task test` pass.
12. If the story is not `done`, halt and report the worker's concrete blocker. Do not continue to another story.
13. Continue to the next eligible story in the target epic until no eligible stories remain or the optional stop rule is reached.

If the single-story workflow halts for user action, halt the epic loop with that exact action request. Do not retry the same story, select another story, or loop continuously.

If the epic-level test gate halts for user action, halt the epic loop with the exact missing prerequisite and command output summary. Do not retry, continue with another story, or mark the epic complete.

## Epic Completion

After all stories in the epic are `done`:

1. Update `epic-N` to `done` in `sprint-status.yaml`.
2. Leave `epic-N-retrospective` unchanged unless the user asked to run it.
3. Commit the epic status update separately as `chore: complete epic N` unless it was already included in the final story commit.
4. Report the completed story commits and validation commands.

## Subagent Prompt Pattern

Use narrow prompts that name `bmad-dev-single-story`, repo path, target epic, story key, story file path, current status, expected `done` status transition, validation expectations, commit-message convention, and the rule: "You are not alone in the codebase; do not revert unrelated changes."

Include in every single-story prompt that the epic orchestrator will rerun story-covering focused tests and `go-task test` after the worker returns, and that any known environment prerequisite for those commands must be reported explicitly instead of hidden or bypassed.

Do not delegate the same write set to multiple workers concurrently. Story deliveries run sequentially; `bmad-dev-single-story` may coordinate its internal review/fix workers.

## Stop Conditions

Halt and report concrete evidence when:

- Sprint status is missing or malformed.
- A story key cannot be mapped to a story file after creation.
- A worker modifies unrelated files.
- Tests or quality checks fail and the active worker cannot fix them.
- A required post-story test command fails, including story-covering focused tests or `go-task test`.
- A required post-story test command fails because of missing Docker, services, credentials, environment variables, network access, database setup, or another local environment prerequisite after the permitted one-time `rtk go-task db-up` recovery attempt for the local PostgreSQL test database.
- The delegated single-story workflow reports unresolved Critical/High/Medium findings.
- A missing dependency, service, credential, migration approval, external action, or product decision requires the user.
- Git cannot isolate story changes from unrelated dirty files.
