# WORKING.md Control Panel

> `WORKING.md` is the project-side runtime control panel. It is part of the Muninn repo ↔ vault interface, but it is not an evergreen knowledge store.

## Purpose

`WORKING.md` answers one question: if a new human or AI session starts now, what is the smallest current-state bundle needed to continue without replaying history?

It should contain:

- Current mainline in one sentence
- Current phase objective
- Current judgments, max 5
- Current blockers, max 3
- Next action with input anchors, expected output, and success criteria
- Guardrails against mistaken progress
- Recent verdict pointers, max 3-5, without expanding details
- Pending Arbiter / KMS sync items
- Startup reminder pointing back to the project entry file and KMS interface

## Do Not Store

Do not turn `WORKING.md` into a journal, archive, or concept store. Do not put:

- Long tables or complete experiment pipelines
- Full historical verdict stacks
- Stable knowledge already owned by `PROJECT.md`, `GAPS.md`, logs, `_Concepts/`, or `03-Zettelkasten/`
- Any experiment explanation longer than 10 lines
- Detailed retrospectives for closed directions
- Same-day verdict prose that belongs in the daily log

## Routing

| Information | First Landing Point |
|---|---|
| Process notes and same-day verdict details | `log/YYYY-MM-DD.md` |
| Current next action and session state | `WORKING.md` |
| Stable project narrative and gate evidence | `PROJECT.md` |
| Methodological flaws and bug-like risks | `GAPS.md` |
| Structural proposals | `docs/proposals/` |
| Stable mechanisms and concept definitions | `_Concepts/` or `03-Zettelkasten/` |
| Experimental facts and machine outputs | `out/...summary.json` + scripts |

## Update Protocol

- Overwrite the current control panel at session end; do not append a running diary.
- Keep exactly one mainline and at most two side tracks.
- Keep recent verdict pointers to 3-5 items. When adding one, evict obsolete or superseded pointers first.
- If a section grows past 10 lines, move the detail to log / GAPS / proposal and keep only a pointer.
- The next action must be immediately executable. If the first action cannot be written, the mainline is not converged.
- If the mainline, first action, or platform rule changes, update `WORKING.md` immediately rather than waiting for session end.
- Any timestamp write such as `[HH:MM]` or `[YYYY-MM-DD HH:MM]` requires a prior real-time `date` check if the project entry rules require timestamp discipline.

## Minimal Template

```markdown
# WORKING.md

> Current runtime control panel. Read at session start; update only the necessary current state at session end.

## 0. Edit Rules

- This file stores current state, not history.
- Long evidence and process details go to log / GAPS / PROJECT / proposals.
- Keep one mainline, max two side tracks, and 3-5 recent verdict pointers.
- Before writing timestamps, run `date` if the project entry file requires timestamp discipline.

## 1. Current Control Panel

### Current Mainline
<one sentence>

### Current Phase Objective
<what this phase is trying to decide or produce>

### Current Judgments
1. <max 5>

### Current Blockers
1. <max 3>

## 2. Next Action

### First Action
<immediately executable action>

### Input Anchors
1. <file / card / output pointer>

### Output
<artifact path or decision>

### Success Criteria
1. <observable criterion>

## 3. Guardrails

### Do Not Do
- <closed path or prohibited shortcut>

### Do Not Extrapolate
- <known boundary>

### Do Not Edit Directly
- `_Governance/`
- `_Concepts/概念-*.md`
- `_Skills/`
- Other Arbiter-only project files listed in the entry file

## 4. Recent Verdict Pointers

- `<date/time or id>` — <short verdict>; details: <log / output / card pointer>

## 5. Pending Arbiter / KMS Sync

- [ ] <sync item>
```
