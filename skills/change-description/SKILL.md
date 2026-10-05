---
name: change-description
description: Draft a title and markdown description for the change on the current branch — pull request, merge request, or patch series. Use when the user asks for a PR or MR description or title, says they are about to open or raise a PR/MR, asks you to write up their branch, or wants something they can paste into a forge. Reads the branch diff, sizes the change, and follows the project's own template when it has one. Generates and prints only; never posts, opens, edits, or pushes anything, and never uses the network. Do not use for commit messages — that is commit-messages — or for summarizing an uncommitted working tree for the user's own reading, which is summarize-changes.
command: change-description
command_description: Draft a title and description for the current branch's change
command_prompt: Draft a title and description for the change on the current branch.
version: 0.3.0
category: Development Workflow
license: MIT
author:
  name: Jeremy Hinegardner
compatibility: opencode
metadata:
  audience: developers
  workflow: git
  keywords: pull request, merge request, PR description, MR description, changelog entry
---

# Change Description

Draft the title and description for the change on the current branch, print
them, and stop. The destination decides whether it is called a pull request,
a merge request, or a patch series; the writing is the same either way.

## Gotchas

- **An empty diff usually means "not committed yet", not "no change".**
  People ask for a description immediately *before* committing. Never report
  "no changes" without checking the working tree — `scripts/change-context.sh`
  classifies this for you.
- **Size is the main quality lever.** A three-line fix arriving with six
  headings is what teaches reviewers to skip generated text. Budget sections
  before writing prose, not after.
- **Never emit an H1.** Every forge renders the title separately.
- **Never use bare `!123` or `#123`.** Short refs render as plain text outside
  the forge that minted them. Full URLs always.
- **Never introduce a prefix style the project's log doesn't already use.**
  Most repositories are not Conventional Commits; check before assuming.

## Rules

- **Generate only.** Never run `gh pr create`, `glab mr create`, `gh pr edit`,
  `git push`, or anything else that creates or alters a change on a forge. If
  asked to open it afterwards, decline — that is a different tool's job.
- **No network.** Local git refs plus files on disk is the entire dependency
  set. No forge CLI, no API, no token.
- **No placeholder text.** A section with nothing to say is omitted, not
  filled with "None", "N/A", or "TODO".

## 1. Gather

`SKILL_DIR` is the directory containing this file; resolve it from this
file's own path. Run from the repository being described:

```bash
"$SKILL_DIR/scripts/change-context.sh" [base-ref]
```

Resolves the base ref from local refs only, classifies what there is to
describe, sizes it, finds any project template and `CONTRIBUTING.md`, and
prints the recent log so you can match its subject convention. **Follow every
`hint:` line it emits** — that is where the non-obvious cases are handled.

Pass an explicit base ref when the operator names one, or when the script
reports it found none.

## 2. Size

The script suggests a class, and sizes on **substantive** lines: planning
narrative, lock files, and vendored or generated trees are excluded, because
their bulk says nothing about how much prose the change deserves. It lists
every path it excluded — if that list looks wrong for the repository, pass
`CHANGE_SIZE_EXCLUDE` (colon-separated globs, empty to disable).

Treat the class as a floor; several unrelated concerns push a change up one.

| Size | Shape |
|---|---|
| **Small** (<50 lines, one concern) | Summary only, one to three sentences, plus Related if there are links. Nothing else. |
| **Medium** (50–200) | Summary plus at most two sections that earn their space. |
| **Large** (200+, or several concerns) | Every section that applies. |

**Budget rule:** for small and medium changes the description must be shorter
than its own diff. If it is longer, it is restating the diff.

## 3. Skeleton

The project's own template wins — follow its structure exactly, and still omit
sections you have no evidence for. Add a heading it lacks only when the diff
clearly needs one. With no template, use
[references/TEMPLATE.md](references/TEMPLATE.md). If `CONTRIBUTING.md` states
description expectations, they outrank both.

## 4. Title

Match the convention in the log the script printed. Absent one: imperative,
capitalized, no trailing period, 72 characters or fewer, shaped as
`<Verb> <what> [in/for/to <context>]`. Derive it from the branch name when
that name is semantic, otherwise from the commits.

Cap consecutive nouns at two — three or more make a title the reader has to
backtrack through. Examples and the read-aloud test are in
[references/WRITING_RULES.md](references/WRITING_RULES.md).

## 5. Description

Explain what the diff cannot show: motivation, tradeoffs, rejected
alternatives, context living outside the code. Four rules, in full in
[references/WRITING_RULES.md](references/WRITING_RULES.md):

1. **Could a reviewer learn this sentence from the diff or CI output?** Then
   cut it, unless it is the change's central point.
2. **Explain non-obvious choices.** Undocumented decisions get re-litigated in
   review.
3. **No AI tells.** Never open with "This PR" or "This change"; prefer a
   concrete number to a vague claim.
4. **The six-month test.** Would a stranger reading this through `git log` in
   six months understand why?

Wrap anything long in `<details><summary>…</summary>`.

## 6. Print

Output the title and description as two separated blocks, the description
fenced so it can be copied verbatim. Add one line naming the size class and
which template you followed, so the operator can tell the shape was chosen
rather than stumbled into. Write to a file only if asked.

## References

- **Fallback skeleton, by size**: [references/TEMPLATE.md](references/TEMPLATE.md)
- **Title rules, anti-patterns, AI tells, formatting**: [references/WRITING_RULES.md](references/WRITING_RULES.md)
- **Context gathering**: [scripts/change-context.sh](scripts/change-context.sh)
