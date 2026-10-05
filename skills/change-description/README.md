# change-description

Drafts a title and a markdown description for the change on the current
branch — pull request, merge request, or patch series — and prints them.

This file is provenance and design rationale. It is not loaded at runtime;
[SKILL.md](SKILL.md) is the skill itself.

## Why it exists

Every comparable skill surveyed ends by *applying* its output: `gh pr create`,
`gh pr edit`, or the GitLab equivalent. None of them stops at generating. That
turns a writing task into a forge-integration task, which drags in a CLI, a
token, network access, and a whole class of "it opened the PR against the
wrong base" failures.

Separating the two makes the writing portable. With no forge dependency the
skill runs under any harness that loads Agent Skills — opencode, pi, Zed,
Claude Code — and works the same whether the destination is GitHub, GitLab,
Forgejo, or a mailing list.

## Design constraints

**Generate only.** No forge writes, ever. The operator pastes the output where
they want it.

**No network.** Local git refs plus files on disk is the entire dependency set.
This is why base-ref detection avoids `git remote show origin`, which most
implementations of this reach for.

**Forge-neutral vocabulary.** The skill does not argue about whether it is a
PR or an MR. The one place forge vocabulary genuinely matters — cross-reference
syntax — is settled by requiring full URLs, since bare `!123` and `#123` render
as plain text outside the forge that minted them.

**Size before prose.** The section budget is fixed from the diffstat before any
writing happens. A three-line fix arriving with six headings is what teaches
reviewers to skip generated text, and no amount of good writing recovers from
it.

**Size on substance, not on line count.** Planning narrative, lock files, and
vendored or generated trees are excluded from the measurement. This repo's
workstream plans and logs made the problem obvious — they were 46% of the
first branch measured, and a plan plus log is verbose by design, so including
them would push essentially every change into "large" regardless of how much
code moved. Lock files are the same shape in the opposite direction: three
thousand lines behind a two-line manifest edit. The script reports what it
excluded by path, so the judgment stays visible rather than silently halving
the number, and `CHANGE_SIZE_EXCLUDE` overrides the defaults per repository.

## Provenance

Assembled from four sources, all MIT.

| Source | What it contributed |
|---|---|
| GitLab's [`gitlab-mr-description`](https://gitlab.com/gitlab-org/ai/skills/-/tree/main/skills/gitlab-mr-description) | The two-step structure, the omission discipline ("fill only what you have evidence for; no placeholder text"), `<details>` wrapping, and the full-URL rule |
| [tdhopper](https://github.com/tdhopper/dotfiles2.0)'s `creating-pull-requests` | The size gate and its budget rule, the noun-stacking cap, the AI-tell rules, and the six-month test |
| [technicalpickles](https://github.com/technicalpickles/pickled-claude-plugins)' `pull-request` | The anti-pattern cut list, the diff/CI test, title derivation from branch name, the `CONTRIBUTING.md` check, the H1 ban, and network-free base-ref detection |
| This repository's own `commands/create-pr.md`, removed in `3ebc168` | Generating a title *and* description together, and printing them separated for pasting |

The GitLab source is roughly 60% GitLab-monolith-specific — postgres.ai plan
links, WIP feature-flag defaults, Rails `IN (…)` emission notes, `pg_indexes`
verification, feature-flag testing matrices. All of that was removed.

## Deliberately excluded

**Conventional Commits and gitmoji prefixes.** `commands/create-pr.md`
hardcoded them, and its sibling `create-commit-message.md` did too — both were
replaced in this repo by `commit-messages`, which treats prefixes as
conditional on project convention. The skill reads the project's log and
matches what it finds rather than imposing a style.

**Visual-aid guidance.** tdhopper's coverage of mermaid diagrams, GFM alerts,
and before/after tables is good, but rendering differs across forges and it
would roughly double the skill's size. Only `<details><summary>` survived,
which renders everywhere.

**Update workflows.** Detecting manual edits to an existing description,
diffing against a previously generated body, tracking state in `.scratch/`.
Generate-only means there is nothing to reconcile.

**Forge API access of any kind**, including reading an existing description.
Reading one would be useful, but fetching it breaks the no-network property;
supply it from a file or paste instead.

## Development record

The investigation behind these choices — the survey of the GitLab skills, the
comparison against harness built-ins and the marketplace, and the git
archaeology that recovered `create-pr.md` — is recorded in
`docs/workstreams/change-description/` and
`docs/workstreams/review-skill-comparison/`.

## License

MIT, consistent with all four sources.
