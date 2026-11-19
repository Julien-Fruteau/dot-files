---
name: qa-chrome
description: QA a ticket on the locally running front end and back end — user journeys driven in a visible Chrome through the Chrome DevTools MCP, visual checks done together with the user, a fix/re-check loop, an independent code review, and the spec kept in sync. Last step before /open-pr.
disable-model-invocation: true
argument-hint: "<spec path or ticket key>"
---

QA of an implemented ticket, on the application running locally. It follows the
spec step (`/to-spec`, `/bmad-spec`…) and the implementation step (`/implement`,
`/tdd`, `/bmad-build`…), and comes before `/open-pr`.

The **QA log** (`qa-log.md`, next to the spec) is the single source of truth for
the session: plan, findings, fixes, decisions. Write it as you go, not at the end
of a phase, so an interrupted session resumes where it stopped and `/open-pr`
finds everything in it. Template: [`assets/qa-log.md`](assets/qa-log.md). Write
the log, like the commits, in the language the project documents itself in.

The user starts the back end, the front end and any side services. Never start
or restart a server yourself: check that it answers, and ask.

**Project agent docs** means whichever instruction files the project gives its
agents — `AGENTS.md`, `CLAUDE.md`, or both, at the workspace root and in each
touched repository — plus local setup docs (`README`, `docs/local*`,
`readme/local.md`…). Read all that exist; when they disagree, the one closest to
the code wins.

## Phase 0 — Framing

1. **Find the spec** from the argument (a path, or a ticket key to look up where
   the project agent docs say specs live). Read the spec, its stories, and the
   project agent docs: local URLs, ports, how to log in, test accounts, known
   pitfalls.
2. **Locate the code**: for each touched repository, current branch, commits
   since the base (`git log <base>..HEAD`), working-tree state. A repository not
   on the ticket's branch invalidates the whole QA — say so.
3. **If `qa-log.md` exists**, resume: re-read the plan and the log, state the
   phase and the point reached, carry on.
4. **Check the environment**: every service answers (`curl` the front end and a
   health endpoint or the API docs of the back end), and the driven browser is
   reachable. For the browser, follow [`references/browser.md`](references/browser.md);
   if the Chrome DevTools MCP is not available in this agent, follow
   [`references/mcp-setup.md`](references/mcp-setup.md). If anything is missing,
   say exactly what to run and wait.
5. **Write the QA plan** in `qa-log.md`. One checkpoint per observable behaviour
   in the spec: screen, journey, error state, email, database effect. Each
   checkpoint has a **mode**:
   - `auto`: checkable without the user — text, presence, state, navigation,
     network request, console, DOM measurement, email in the local SMTP server,
     database row;
   - `visual`: needs a human eye — overall rendering, fidelity to the mock-up
     when no numeric value is available;
   - `external`: depends on a step you cannot perform (real SSO, SMS one-time
     code, partner service) — the user does it, you check what follows.

   A back-end-only change belongs in the plan as soon as it changes what the end
   user sees or receives: the front-end journey that consumes it is the
   checkpoint, not the endpoint alone. When a mock-up exists (PDF, Figma, image
   attached to the ticket), tie each screen to its page or frame.

   Show the plan to the user and adjust it before running it. The phase is done
   when the user has approved the plan.

## Phase 1 — Journeys

Walk the plan screen by screen, in the order of the user journey.

**For each screen:**

1. Get there as the end user would — through the journey, not by typing the URL
   of an intermediate step, unless the plan says so.
2. Run the `auto` checkpoints: accessibility snapshot for texts and states,
   network requests (status, body compared with the spec's contract), console
   free of errors, DOM measurements for spacing and alignment. **Measure rather
   than eyeball**: a 4 px gap or an offset icon is not reliably visible in a
   screenshot, it is readable in `getBoundingClientRect`. Snippets in
   `references/browser.md`.
3. Compare with the mock-up: numeric values when it gives them (Figma dev mode,
   PDF dimensions), otherwise a screenshot side by side with the mock-up page,
   reporting only clear gaps (missing element, order, label, colour).
4. **`visual` checkpoints**: group the screen's ones into a single request. The
   user sees the same Chrome window as you; tell them what to look at, with what
   you have already measured, and wait for an "ok" or remarks. One question per
   screen, not per checkpoint.
5. Record each checkpoint's result in `qa-log.md` (✅ / ❌ + observation).

**Fix loop.** For any gap, found by you or by the user:

1. Log it (screen, observation, source).
2. Fix it. Front-end fixes are reloaded by the dev server; for a back-end fix,
   batch what can be batched, then ask the user to restart the back end, once.
3. Re-check the checkpoint, and the neighbouring ones the fix may affect.
4. Commit following the repository's conventions (one logical step per commit).
5. If the fix changes a behaviour, rule, label or contract the spec describes,
   **update the spec** right away. A pixel adjustment or an implementation bug
   stays in the log only.

If a gap calls the spec itself into question (need misunderstood, case not
foreseen), stop and ask instead of deciding.

The phase is done when every checkpoint is ✅, or ❌ accepted by the user and
logged as such. Report the outcome, then move to phase 2.

## Phase 2 — Independent review

1. **Update the spec** before the review, so the reviewer judges the code against
   what was actually decided.
2. **Run the review in a clean context**, so the reviewer does not anchor on the
   QA's conclusions. It receives only the repositories, each one's commit range,
   and the spec path — nothing from the QA. Depending on the agent:
   - Claude Code: a fresh subagent (`general-purpose`, never a fork) briefed to
     invoke the `code-review` skill with `high <base>` on each repository;
   - Codex: `/review` against the base branch, in a new session;
   - pi, or any agent without a review command: a fresh subagent if one is
     available, briefed to review the diff for correctness against the spec;
     otherwise ask the user to run the review in a new session and paste the
     result.

   Ask for findings as-is, with file, line, severity and failure scenario.
3. **Triage with the user.** Present the findings from most to least severe,
   each with your opinion (sound or not, cost of fixing). For each, the user
   decides: **fix**, **won't fix** (reason), or **defer** (reason, and where it
   is tracked). Record each decision in `qa-log.md` when it is made.
4. **Fix** what must be fixed, one commit per fix or coherent group. Re-run the
   touched repository's unit and integration tests, reading the real counts
   (number of scenarios, failures), not just the build status.
5. **Replay the QA** on the screens the fixes may affect, then a quick pass over
   the whole journey. Log it.
6. Carry into the spec the "won't fix" and "defer" decisions that bind future
   work (known limitation, accepted debt).

The phase is done when every finding has a recorded decision and the replayed
QA is green.

## Wrap-up

1. Re-read the spec one last time against what is delivered; fix what diverges.
2. Fill the "PR summary" section of `qa-log.md`: key points of the change, fixes
   made during QA, review decisions, what remains to watch.
3. If the project agent docs did not know something the QA had to discover (how
   to log in locally, test account, port, pitfall), offer to add it there.
4. Report the outcome in a few lines and suggest `/open-pr`.
