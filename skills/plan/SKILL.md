---
name: plan
description: >
  Create a high-level plan for implementing a feature, fixing a bug, or making
  a significant change. Use proactively when the user asks to implement, add,
  build, create, fix, refactor, or change something in the codebase.
argument-hint: <description of what to implement or fix>
---

## Instructions

**DO NOT** enter built-in "Plan mode". Generate plan artifacts that the user
can review and edit directly.

### Step 1 — Create the plan file

Create `_plans/YYYY-MM-DD-HHmm-<slug>-high-level.md` using the current
UTC date and time (24-hour format).

Write the user's original prompt verbatim into a `## Starting Prompt` section.

### Step 2 — Deep research (parallel)

Spawn the following Explore agents **in parallel** using the Agent tool to
research the codebase concurrently:

1. **Code agent** — Explore the modules, functions, types, and relationships
   in the areas of the codebase affected by the change. Understand how data
   flows through them.
2. **Test agent** — Find existing test files and patterns covering the
   affected modules. Note the test framework, fixture conventions, and
   inheritance chains (base class + subclass test suites).
3. **Docs agent** — Identify which documentation files exist (README,
   ARCHITECTURE, DESIGN, CHANGELOG, about pages, etc.) and which sections
   would need updates to reflect the planned changes.

Wait for all agents to complete, then synthesize their findings before
proceeding to Step 3.

### Step 3 — Write the high-level plan

Append a **§ High-level plan** section containing:
- Which modules change
- Mermaid diagrams of how data or UX will flow differently
- ASCII diagrams of any UI layout changes
- Code snippets for core domain objects (models, key function signatures,
  DB schema changes, etc.)
- Type aliases: use existing project type aliases and define new ones for
  domain concepts and non-trivial compound types — signatures should read
  in terms of the domain, not raw primitives or inline unions/generics
- Which documentation files need updates and what sections are affected
- **Inheritance impact**: when a change targets a base class method,
  identify all subclasses that inherit it and enumerate their test suites
  alongside the base class tests. Tests for subclasses will also need
  updating even if the subclass doesn't override the changed method.

#### Correctness, data integrity & performance

Every high-level plan must explicitly address these three concerns. If a
concern does not apply, state why — do not silently skip it.

- **Correctness** — What failure modes and edge cases exist? How does the
  system behave when dependencies fail, connections drop, or inputs are
  unexpected? Are there library or API behaviours that silently succeed
  when they should fail (e.g. a refresh call returning success with TTL=0
  on a revoked lease)? Identify assumptions that need to be validated.
- **Data integrity** — Are writes idempotent? Can state become
  inconsistent (stale caches, orphaned records, partial writes)? What
  happens during concurrent access or across restarts? If the change
  touches shared state (database rows, distributed keys, caches), describe
  the consistency guarantees and how invariants are maintained. When adding
  data to a shared structure (e.g. a dict, event, or message that flows
  through a pipeline), trace all downstream consumers and document the
  impact of the new data on each.
- **Performance** — Both at the code level (unnecessary writes, missing
  deduplication, O(n²) where O(n) would do) and at the architectural
  level (is the mechanism appropriate for the access pattern? does it
  scale with the number of instances/hosts/records?). Quantify
  steady-state and peak load where possible (e.g. "N writes/min with
  M hosts"). Consider whether the platform or infrastructure provides a
  native mechanism that avoids the work entirely (e.g. lease-based
  liveness vs. timestamp polling).

### Step 4 — Stop and wait

**STOP.** Tell the user the high-level plan is ready for review. Do NOT proceed
to implementation detail until the user gives an unambiguous go-ahead
(e.g. "go ahead", "looks good", "go").
