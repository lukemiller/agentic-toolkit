# Writing Rules

## The title

Match the project's existing convention first — read the recent log. If the
history uses Conventional Commits or gitmoji prefixes, use them; if it does
not, which is the common case, do not introduce them. `commit-messages`
governs subject-line format generally; what follows is what a change title
needs on top of it.

Default form: imperative, capitalized, no trailing period, 72 characters or
fewer. Pattern: `<Verb> <what> [in/for/to <context>]`. Common verbs: Add,
Fix, Update, Remove, Refactor, Replace, Enable, Use, Make.

Derive it from the branch name when that name is semantic
(`workstream/change-description` is; `jeremy/wip-2` is not), otherwise from
the commits.

### Cap consecutive nouns at two

Three or more stacked nouns make a garden-path title: the reader parses it
one way, fails, and backtracks.

| Rewrite this | To this |
|---|---|
| Fix converter cache routing threshold validation | Fix the boundary check in converter cache routing |
| Add plugin manifest generation script test coverage | Test the script that generates plugin manifests |
| Update model config diff summary error handling | Handle errors when summarizing model config diffs |

**Read-aloud test:** if you would not say it in conversation, rewrite it.

### Titles that describe the change, not the files

| Weak | Strong |
|---|---|
| Update sync.rb | Prune stale plugin symlinks during sync |
| Fix bug | Fix lost notifications after a pipeline retry |
| Various improvements | Accept CRLF line endings in the parser |

## The description

The description's job is to explain what the diff *cannot* show. The diff is
right there; it does not need a prose translation.

## The test

For every sentence, ask: **could a reviewer learn this by reading the diff or
the CI output?** If yes, cut it — unless it is the central point of the
change. The description is the complement of the diff, not a summary of it.

## Cut these every time

- **File-by-file narration.** "In `sync.rb`, changed X. In `install.sh`,
  changed Y." The diff covers this.
- **Implementation play-by-play.** "First I added a helper, then called it
  from…" Describe the design, not the order you worked in.
- **Commit archaeology.** "In the first commit I did X, then in the
  second…" Describe the final state.
- **Metrics as achievement.** "Added 15 tests", "Modified 8 files",
  "Coverage to 85%". Unless the change is *about* the metric, it reads as
  padding.
- **Diff-visible detail.** "Created a new `Foo` class", "Refactored into
  smaller functions", "Added error handling". Say why, or say nothing.
- **Restating a signature change.** "Changed `foo(x: Integer)` to
  `foo(x: Float)`" — the reviewer can see that. Why did it change?
- **Motivation the reviewer already has.** If the linked issue explains the
  problem in full, link it and write one sentence.
- **Defensive disclaimers.** "This is a first pass", "open to suggestions".
  If there is a specific thing you want scrutinized, name it specifically.
- **Assumed virtue.** "Follows best practices", "clean and maintainable",
  "easy to extend". The last one is also faintly condescending.
- **An H1 heading.** Every forge renders the title separately.

## Avoiding AI tells

One pattern is not damning. Several stacked together are what make a reader
decide the text was generated and stop reading it.

### Openers

Never begin a sentence with "This PR", "This MR", "This change", "This
commit", or "In this pull request". Start with the subject of the action,
the problem, or a concrete fact.

| Generated-sounding | Human |
|---|---|
| This PR adds retry logic to the fetcher. | The fetcher now retries on 5xx, up to three times. |
| This change fixes a bug where… | `parse_header` returned nil for empty trailers. |
| In this MR, we update the sync script. | `sync.rb` now prunes stale plugin symlinks. |

### Concrete over vague

Specifics are the strongest signal that a human looked at the thing.

| Vague | Concrete |
|---|---|
| improved performance significantly | p50 dropped from 45 ms to 3 ms |
| fixed an edge case in validation | fixed the boundary: 49 kB routes to cache, 51 kB to disk |
| updated error handling | catch `Errno::ENOENT` instead of bare `StandardError` |
| various improvements to the parser | the parser now accepts CRLF line endings |

### Variety

Vary sentence length and structure. If every bullet is a bold phrase, a
period, then one explanatory clause, that regularity is itself the tell. Let
some bullets lead with a question a reviewer would ask, some with a
constraint, some with an example.

### Self-contained context

A change description is permanent project documentation. Issue trackers get
migrated and shut down; git history persists. A description that says only
"see JIRA-4471" forces a context switch today and may be unresolvable in two
years. Link for depth, inline for essentials.

### The six-month test

Before finishing: if a stranger finds this through `git log` in six months,
will they understand why the change was made? If not, the missing piece is
what the description is for.

## What to keep

- **Why, not what.** The motivating problem, in the author's words.
- **Non-obvious decisions.** Reusing an existing table instead of adding
  one; a specific enum ordering; a deliberate performance tradeoff. Say why
  here and reviewers will not re-raise it.
- **Rejected alternatives**, with the reason they lost. This is the single
  highest-value thing a description can carry, and the most often omitted.
- **Verification that is not obvious** from the test files.
- **Anything a reader needs that lives outside the repository.**

## Formatting

- Wrap long material — query plans, terminal output, wide tables — in
  `<details><summary>…</summary>` so reviewers can skip it.
- Full URLs for every cross-reference. Bare `!123` and `#123` render as
  plain text anywhere outside the forge that minted them, which includes
  commit messages, mirrors, and any other forge the project is also hosted
  on.
- Code identifiers in backticks, so they do not become accidental user
  mentions.
