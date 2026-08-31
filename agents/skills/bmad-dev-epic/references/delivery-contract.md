# Delivery contract

Loaded at the `finalize` route only. `bmad-build` owns planning, implementation and review; this file covers the two things it does not produce — the architecture view and the review-finding disposition this skill enforces before a story reaches `done`.

## Architecture view

`docs/story-flows/{id}-{slug}.md` describes the **implemented** result for a reader who was not in the session. Smaller than the story itself:

- one short purpose/scope paragraph;
- one Mermaid flow or component diagram (`validate_delivery.py` requires a ```mermaid fence);
- the story-owned components and their responsibilities;
- accurate boundaries to the surrounding architecture, with a link back to the spec folder's `SPEC.md` (the script requires that link, or the spec folder name, to appear);
- explicit exclusions, so the reader does not infer unimplemented behavior.

List it in the story File List and link it from the Dev Agent Record. The diagram must name real components and match the actual control and data flow — the script checks that the file exists and is structurally sound, never that it tells the truth. That check is yours.

## Review findings

`bmad-build` runs Blind Hunter, Edge Case Hunter and Verification Gap layers. Dispose of what it returns before finalizing:

| Disposition | Meaning |
|---|---|
| `decision_needed` | blocking; a user decision, so halt |
| `patch` | blocking unless explicitly Low/nit; a `patch` without severity is Medium |
| `defer` | non-blocking; record it in the deferred-work ledger |
| `dismiss` | ignored |

Critical, High and Medium are blocking. Low is non-blocking by default.

Fixes go back through `bmad-build` on the same story — never a second overlapping writer. Add regression coverage where practical, resolve review checkboxes in place, and require a fresh independent review afterwards. Stop after three fix cycles that still leave blocking findings, and report them.

## Story-owned paths

A story owns: the source and tests its tasks require, its own spec file under `{spec_folder}/stories/`, and its architecture view. It does not own `SPEC.md`, `stories.yaml`, or another story's file. Anything else in the working tree at activation is `preexisting_dirty_state` and must come back byte-identical — `validate_delivery.py` compares fingerprints and fails the story if it did not.
