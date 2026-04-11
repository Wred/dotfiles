---
description: Plan a larger effort as decoupled, parallelizable GitHub issues
argument-hint: <short description of the effort>
---

You are decomposing a larger effort into GitHub issues that can be worked in parallel by independent agents. The effort: $ARGUMENTS

## Process

1. **Explore the repo** enough to understand current state relevant to the effort. Read real code. Do not skip this step.

2. **Propose a decomposition.** Size it to the effort — small efforts may be 2–3 issues, larger ones more. Two failure modes to avoid:
   - **Over-fragmentation**: many tiny issues that are really coupled (slicing one logical change into "add struct", "add method", "wire it up"). If issues can't be worked in any order, they're one issue.
   - **Under-scoping**: one giant issue that should have been several independent ones. If a single issue touches unrelated subsystems and a reviewer would naturally split the PR, split the issue.

   If the count grows unusually large (into double digits), pause and sanity-check the scope with the user before proceeding — large fan-outs are usually a signal the effort wasn't actually decomposable or the original ask was too broad.

   Present the proposed list and **WAIT for "go"** before creating anything.

3. **For each issue, produce:**
   - Title (<70 chars)
   - **Context** — 2–4 sentences on why
   - **Scope** — concrete bullet points of changes
   - **Acceptance criteria** — testable checklist
   - **Self-contained check** — explicit statement of:
     - Files/modules touched
     - What it does NOT depend on from sibling issues
     - Shared interfaces — if two issues need one, one of them defines it and the other consumes it as-is (pick which, don't leave implicit)

4. **Hard decoupling rule**: no issue may reference another by number, and no issue may be blocked on another. Before creating, scan each body for `depends on #`, `blocks #`, `blocked by`, `after #`, `requires #` and reject/rewrite matches. If you cannot decouple, STOP and tell the user — restructure or fall back to a single issue.

5. **Only after the user approves**, create the issues. Write each body to
   a temp file and use `--body-file` to avoid shell interpretation of
   backticks, `$variables`, and other special characters in the body:
   ```
   tmp=$(mktemp)
   cat >"$tmp" <<'BODY'
   <issue body here>
   BODY
   gh issue create --title "..." --body-file "$tmp"
   rm "$tmp"
   ```
   Print the created URLs.

## Constraints

- **Flat issues only** — no epic, no tracking issue. Shared context goes in a committed doc, not a pinned issue. Epics become reference magnets ("see #42 for context") that silently rebuild coupling.
- Do NOT use `gh api`. Only `gh issue create`.
- Every issue body must end with a literal marker line:
  ```
  <!-- planned: self-contained -->
  ```
  so it's obvious at a glance which issues went through this planning flow.
