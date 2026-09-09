# Claude Skills: Overview

## What Are Claude Skills?

Claude Skills are self-contained, file-based packages that extend Claude with specialized knowledge and capabilities for specific tasks. Each skill is a folder containing a `SKILL.md` instruction file plus optional scripts, references, and assets. Claude loads a skill **on demand** when the task matches its description — no fine-tuning, no plugin installation, just files on disk.

Skills follow the open [Agent Skills](https://agentskills.io) standard. For a deeper dive, see Anthropic's [Complete Guide to Building Skills for Claude](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf).

## Why Skills Are Useful

Skills give Claude domain-specific behavior without bloating every prompt with instructions. They are:

- **Composable** — drop a folder into a project to enable it; remove it to disable.
- **Context-efficient** — only the skill's short description sits in context until it's actually needed (progressive disclosure).
- **Deterministic where it matters** — bundle helper scripts so Claude executes proven code instead of re-deriving logic each time.
- **Portable** — the same skill works across Claude Code, Claude.ai, the API, and Claude Agent SDK.

### Example use cases

- Enforcing style for code review, commits, or PR descriptions
- Project-specific workflows (running tests a certain way, scaffolding modules)

## Skills vs. Neighbors

Developers often confuse skills with other Claude extension mechanisms. Quick disambiguation:

| Mechanism | What it provides | When loaded | Best for |
|---|---|---|---|
| **Skill** | Instructions + optional scripts/refs/assets | On demand (by description match or `/name`) | Procedures, workflows, large reference material |
| **CLAUDE.md** | Facts and conventions | Always in context | Project-wide rules that apply every turn |
| **Slash command** (`.claude/commands/`) | A prompt template | When you type `/name` | Same as a skill; commands have been merged *into* skills — skills are now recommended |
| **Subagent** | A scoped sub-Claude with its own tools | When parent delegates | Isolating context-heavy or parallel work |
| **MCP server** | New *tools* (function calls) | Tools advertised at startup | Connecting Claude to external systems/APIs |
| **Plugin** | A bundle of any of the above | When the plugin is enabled | Distributing skills + hooks + MCP + agents together |

Rule of thumb: if you keep pasting the same instructions, write a skill. If you need a new *capability* (API call, database query), write/use an MCP server. If you have a fact that applies every turn, put it in CLAUDE.md.

## Folder Structure

A skill is just a directory. Only `SKILL.md` is required.

```
my-skill/
├── SKILL.md          # Required: YAML frontmatter + instructions
├── scripts/          # Optional: executable helpers Claude can run
│   └── helper.py
├── references/       # Optional: long-form docs loaded on demand
│   └── api-spec.md
└── assets/           # Optional: templates, fonts, images
    └── template.docx
```

### `SKILL.md` format

```markdown
---
name: my-skill
description: Short, specific summary of what this skill does and when to use it.
  Claude reads ONLY this to decide whether to load the skill, so be precise.
---

# My Skill

## When to use
Use when the user asks to...

## Instructions
1. Step one
2. Step two

## Resources
- See `references/api-spec.md` for the full schema
- Run `scripts/helper.py` to perform X
```

**Progressive disclosure** is the key idea:
1. The `description` is always in context (cheap).
2. The `SKILL.md` body loads when the skill triggers (keep under ~500 lines).
3. Files in `references/`, `scripts/`, and `assets/` load only when Claude reaches for them.

## How Skills Are Initiated

Skills are surfaced two ways:

- **Automatically** — Claude reads each skill's `description` and decides whether to load the full `SKILL.md` based on the user's request. The `description` is the trigger surface; vague descriptions under-trigger, specific ones with concrete keywords trigger reliably.
- **Explicitly** — type `/skill-name` to invoke it directly (the directory name becomes the command). Set `disable-model-invocation: true` in frontmatter to force manual-only invocation.

## Where Skills Live

Discovery happens in well-known locations, with precedence enterprise → personal → project. A same-named skill at any level overrides bundled skills; plugin skills use a `plugin-name:skill-name` namespace and don't conflict.

| Location | Path | Applies to |
|---|---|---|
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Wherever the plugin is enabled |

Project skills also load from nested `.claude/skills/` in subdirectories (handy for monorepos — the variant gets a directory-qualified name like `apps/web:deploy`). Changes to `SKILL.md` are picked up live without restarting Claude Code.

## Hello World

A 10-line skill that summarizes uncommitted changes. Drop this in `~/.claude/skills/summarize-changes/SKILL.md`:

```markdown
---
description: Summarizes uncommitted changes and flags anything risky. Use when the user asks what changed, wants a commit message, or asks to review their diff.
---

## Current changes

!`git diff HEAD`

## Instructions

Summarize the changes above in two or three bullet points, then list risks
(missing error handling, hardcoded values, tests that need updating).
```

Then ask Claude "what did I change?" — or invoke it directly with `/summarize-changes`. The `` !`git diff HEAD` `` line is dynamic context injection: Claude Code runs the command and inlines its output before the skill body is read.

## Example Skills from Anthropic

Anthropic publishes a [reference set of skills](https://github.com/anthropics/skills/tree/main/skills). A few of the most broadly useful:

| Skill | What it does |
|---|---|
| **skill-creator** | Meta-skill that authors, tests, and iterates on new skills |
| **mcp-builder** | Scaffolds Model Context Protocol servers |
| **webapp-testing** | Drives browser automation to test web apps |
| **claude-api** | Reference for Claude API usage — models, pricing, tool use, caching |
| **frontend-design** / **canvas-design** / **theme-factory** | UI, visual composition, and theme generation |
| **doc-coauthoring** | Collaborative document writing and editing |

Claude Code also ships bundled skills you get for free (e.g., `/code-review`, `/debug`, `/verify`, `/loop`).

## Creating Skills with `skill-creator`

Writing skills by hand works, but [`skill-creator`](https://github.com/anthropics/skills/tree/main/skills/skill-creator) is the recommended path. It's a meta-skill that turns skill authoring into an evaluated, iterative process.

### What it does

1. **Captures intent** — asks what the skill should enable, when it should trigger, and what good output looks like.
2. **Drafts `SKILL.md`** — generates frontmatter and instructions, deliberately writing a "slightly pushy" description because Claude tends to under-trigger skills.
3. **Generates evals** — produces test prompts (should-trigger and near-miss should-NOT-trigger cases) saved to `evals/evals.json`.
4. **Runs A/B tests** — spawns parallel subagents with and without the skill, captures output and timing.
5. **Grades results** — uses grader/comparator/analyzer subagents to score against assertions.
6. **Iterates** — surfaces patterns from failures, refines the skill, and reruns the benchmark.
7. **Optimizes the description** — runs a description-tuning loop so the skill triggers on the right queries and ignores the wrong ones.

### Why it beats hand-writing

- **Measurable instead of vibes-based.** You get a benchmark score, not a guess.
- **Catches under- and over-triggering.** The hardest part of skill authoring is the `description`; skill-creator tunes it against real near-miss queries.
- **Surfaces extraction opportunities.** When the same logic shows up in multiple test runs, it suggests promoting it into a bundled script.
- **Enforces best practices automatically.** Progressive disclosure, lean prompts, environment-aware variants.
- **Reproducible.** Anyone can re-run the evals to confirm the skill didn't regress.

## Security Considerations

Skills can ship executable scripts (`scripts/helper.sh`) and use shell injection (`` !`command` ``) in their bodies. They can also grant Claude tools without permission prompts via `allowed-tools` in frontmatter. Treat an untrusted skill the same as untrusted code:

- **Review before installing.** Read `SKILL.md`, every script, and the frontmatter — especially `allowed-tools` and any `!`…`` lines.
- **Prefer project skills you authored** over copy-pasted ones from the internet.
- **Plugin skills in `.claude/skills/` require accepting the workspace trust dialog** before they load with plugin capabilities.
- **Secrets:** skills run with your shell credentials. A malicious script can exfiltrate env vars or commit history just like any other code you run.

## Reference Material

- [The Complete Guide to Building Skills for Claude (PDF)](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)
- [Anthropic Skills repository](https://github.com/anthropics/skills/tree/main/skills) — official skill examples
- [Skills.sh Skills list](https://www.skills.sh/) - more skill examples
- [`skill-creator` skill](https://github.com/anthropics/skills/tree/main/skills/skill-creator) — meta-skill for building skills
- [Claude Code skills documentation](https://code.claude.com/docs/en/skills) — full reference for frontmatter, discovery, and lifecycle
- [Agent Skills open standard](https://agentskills.io)
