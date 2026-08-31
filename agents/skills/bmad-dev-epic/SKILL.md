---
name: bmad-dev-epic
description: Autonomously deliver every remaining story of a BMad spec folder by dispatching one story at a time to bmad-build, then owning the verification gate, the attributed commit, and epic completion. Use when the user asks to implement, dev, complete, or loop over all stories of a BMad epic or spec. Stop and prompt the user instead of retrying when a dependency, unavailable service, ambiguous state, or product decision requires user action.
---

# BMad Dev Epic

## Purpose

Deliver every story of one spec folder, in `stories.yaml` order, without leaving the epic half-done or the working tree polluted.

`bmad-build` owns planning, implementation, and adversarial review of a single story. This skill owns everything `bmad-build` does not: story selection, the checkpoint fields, the post-story test gate, the architecture view, deterministic completion validation, and a commit that contains the story's files and nothing else.

## The route

Artifacts live in the spec folder, never in `implementation_artifacts`:

```
{spec_folder}/
├── SPEC.md          the contract bmad-build reads
├── stories.yaml     execution order; no status field, ever
└── stories/
    └── {id}-{slug}.md   one story spec, status in its frontmatter
```

`stories.yaml` carries no status by schema, so a story's status is its own spec file's frontmatter, written by `bmad-build`: `draft` → `in-progress` → `in-review`. The transition to `done` belongs to this skill, after its gate passes.

Never read or write `sprint-status.yaml`. Never resolve paths from `_bmad/*/config.yaml` — those installer-generated mirrors do not receive `_bmad/custom/*.toml` overrides. `scripts/epic_state.py` reads the TOML layers directly.

## Inputs

- The spec folder: a path, or a bare slug resolved under `{output_folder}/specs/spec-<slug>`.
- Optional stop rule, such as a maximum number of stories.
- Optional commit-message convention. Default: `feat: implement story <id>-<slug>`.

## Preconditions

1. Run `uv run scripts/epic_state.py {project-root} --spec-folder <folder>`. Resolve every bare `scripts/...` and `references/...` path against this skill's installed directory, never the target project's working directory. If it cannot run, derive the same facts directly rather than guessing.
2. It returns the ordered story list with per-story status and route, the first eligible story, the resolved baseline, and `initial_dirty_state` — a fingerprint per dirty path. Retain unrelated dirty paths as `preexisting_dirty_state`. Never stage, overwrite, or revert them. Halt with the exact conflicting paths when a story's changes cannot be isolated from them.
3. Resolve the project's **focused** and **full** test commands once, from its agent instructions (`CLAUDE.md`, `AGENTS.md`, `project-context.md`) or, failing that, its build manifest — `pom.xml` → Maven, `package.json` → the declared script runner, `Taskfile.yml` → `task`, and so on. This skill hardcodes no build tool. If no full test command can be established, say so and ask rather than skipping the gate or guessing a command.
4. Halt on any state error the script reports (ambiguous `{id}-*.md` match, unknown status, prefix-colliding ids, a `status` field in `stories.yaml`). These are malformed state, not a reason to pick another story.

## Per-story loop

For each story the script marks eligible, in list order:

### Route `dispatch`

Invoke `bmad-build` with a **folder+id dispatch** — the spec folder and the story id, and no specific spec file path. `bmad-build` resolves the entry itself and writes to `{spec_folder}/stories/{id}-{slug}.md`. Append the entry's `invoke_dev_with` text verbatim to the prompt when non-empty.

Before the first source edit, ensure the story file records `baseline_commit`. `bmad-build` captures it in frontmatter at step 03; verify it is there afterwards and never overwrite an existing one on a resumed story.

When `spec_checkpoint` is `true`, tell `bmad-build` to stop once the story spec is written and reviewed, then halt the loop and give the user the story file path. A later invocation resumes it: `bmad-build` routes an existing `draft` file back into planning.

### Route `finalize`

`bmad-build` has finished its review layers and left the story `in-review`. Run the gate:

1. Write or refresh the architecture view at `docs/story-flows/{id}-{slug}.md` per `references/delivery-contract.md`, list it in the story File List, and link it from the Dev Agent Record.
2. Run the focused tests covering the story's changes, using the commands `bmad-build` reported when available and otherwise deriving them from the touched test files. Require them to pass.
3. Run the project's full test command from the main agent. Require it to pass.
4. Set the story frontmatter `status: done`.
5. Validate deterministically:

   ```
   uv run scripts/validate_delivery.py {project-root} \
     --story-id <id> --story-file <path> --spec-folder <folder> \
     --baseline <sha> --expected-status done \
     --preexisting-state '<path>=<sha256>'   # repeat per activation fingerprint
   ```

   It checks status, unchecked tasks, architecture structure, the changed/staged manifest, and that unrelated dirty paths were neither staged nor mutated. Semantic agreement — path attribution, whether the diagram matches the real control/data flow, acceptance satisfaction — stays your judgment; the script lists what it did not verify.
6. Attribute every candidate path to the story. Stage only explicit story-owned paths, then require `git diff --cached --name-only` and `git diff --cached --check` to pass.
7. Commit with the agreed convention.

When `done_checkpoint` is `true`, halt the loop after the commit and report; do not start the next story.

### Failure handling

- A test fails on code or test behavior → keep this story as the only work item and route the failure back through `bmad-build` for a fix and a fresh review. Do not advance.
- A test fails on a missing environment prerequisite (a database, Docker, a service, credentials, env vars, network) → if the project's agent instructions define a recovery command for exactly that prerequisite, run it once and rerun the failed command once. Otherwise, or if it still fails, halt with the command output and ask for the exact missing action. Never invent a recovery command, retry a third time, work around it with another worker, or move to another story.
- `bmad-build` halts for user action → halt the epic loop with that exact request.

## Delegation

Do story selection, state parsing, Git manifests, and structural validation locally through the scripts; they do not merit subagents. `bmad-build` runs its own implementation and review subagents — do not wrap it in another layer or run a second writer beside it.

Where explicit model selection is available, use `{agent.coding_worker_model}` and `{agent.review_worker_model}` when configured; otherwise choose the least expensive available model adequate for the role, and never invent an unavailable model ID.

Tell every dispatch: "Autonomous execution is authorized. You are not alone in the codebase; do not revert unrelated changes. Stop on a true halt condition." State that this orchestrator will rerun the story-covering focused tests and the project's full test command afterwards, so any known environment prerequisite must be reported rather than bypassed.

After each return, retain only changed paths, commands and results, resulting status, findings, and the next blocker — not the transcript.

## Epic completion

Once no eligible story remains:

1. Report the per-story commits and the validation commands that passed.
2. Commit any remaining epic-level artifact separately as `chore: complete epic <slug>`, if one exists outside the story commits.
3. Never auto-push.

## Halt invariant

Halt once, with concrete evidence and the exact next action, when: state is missing or malformed; ownership cannot be isolated; `bmad-build` touched unrelated files; required checks fail beyond the one database recovery; `bmad-build` reports unresolved blocking findings; or a dependency, service, credential, approval, or product decision requires the user. Do not select another story, spawn a workaround worker, or repeat the blocked command.

Allowed Git writes are narrow `git add -- <paths>` and `git commit`. Never reset, restore, checkout, clean, rebase, or stage broadly.
