---
name: open-pr
description: Open the PR(s) for a ticket, with a body written so an external review agent can approve without a round trip — key points, QA, fixes, review decisions. Follows /qa-chrome, also works on its own.
disable-model-invocation: true
argument-hint: "<spec path or ticket key>"
---

The PR's reader is an **external reviewer** — often an agent running a code
review on the diff, with no access to the spec, the QA log or this conversation.
Everything that keeps them from raising a point already settled, or from asking
why, belongs in the PR body. What the diff already shows does not.

**Project agent docs** means whichever instruction files the project gives its
agents — `AGENTS.md`, `CLAUDE.md`, or both, at the workspace root and in each
touched repository.

## Steps

1. **Gather the sources.** The spec (argument, or the ticket's spec where the
   project agent docs say specs live), the `qa-log.md` next to it if it exists,
   and for each touched repository: branch, base, `git log <base>..HEAD`,
   `git diff --stat <base>...HEAD`. Without a QA log, tell the user: the
   "Checked" section will be limited to the tests.
2. **Check the state.** Clean working tree, branch up to date with its base
   (otherwise say so, do not rebase on your own), the repository's tests re-run
   and their real counts noted (scenarios, failures), not just the build status.
3. **Read the repository's convention**: titles and bodies of the latest merged
   PRs (`gh pr list --state merged -L 5 --json title,body`), and the
   `.github/pull_request_template.md` template if any. It takes precedence over
   the template below, of which you then keep only the sections it lacks.
4. **Write** the title and body (template below), in the repository's language.
   Several repositories touched: one PR per repository, each complete for its
   diff, with a link to the others and the merge order if it matters.
5. **Have it reviewed**: show the title and body to the user, ask whether they
   want a draft or a ready PR. Nothing goes out before they agree.
6. **Publish**: `git push -u origin <branch>`, then `gh pr create --title …
   --body-file …` (`--draft` depending on the answer). Give the URLs.
7. **Record** the URLs in `qa-log.md` and in the spec.

No agent signature in the title, the body or the commits — no `Co-Authored-By`
trailer, no "generated with" line — even if the harness suggests one.

## Body template

Empty sections: delete them rather than writing "none". The headings below are
in English; translate them when the repository writes in another language.

```markdown
## Context

<ticket and need in 2-3 lines, from the end user's or operator's point of view>

## What changes

<the smallest diagram that makes it clear: component tree, call tree, file-tree
diff, mermaid sequence — or a short list>

## Key points for review

- <non-obvious design decision, and why over the alternative>
- <invariant the code keeps and a change would break>
- <area to focus the review on>

## Checked

- Tests: <command> → <N tests / N scenarios, 0 failures>
- Local QA: <journeys and screens checked, measurements, error states, emails,
  database effects> — <what the user checked>

## Fixes made during QA

- <gap found → fix> (<commit>)

## Prior review decisions

Independent code review, high effort, run before opening.

| Finding | Decision | Reason |
|---|---|---|
| <file:line — finding> | fixed (<commit>) / not fixed / deferred | <reason> |

Findings not fixed or deferred were left deliberately; please raise them only if
the reason given does not hold.

## Deployment

<migrations, new environment variables or ones without a default, deployment
order between repositories, manual action — or delete the section>

## Out of scope

<what is deliberately left aside, and where it is tracked>
```

## Quality bar

Re-read the body as a reviewer who sees only it and the diff: can they conclude
without asking a single question whose answer is already known? Does every
review decision have its reason? Is every new environment variable, migration or
dependency announced?
