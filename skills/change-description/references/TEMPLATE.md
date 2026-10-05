# Fallback Skeleton

Use this only when the project has no template of its own. It is
deliberately thin — an over-specified skeleton reintroduces exactly the
section bloat the size gate exists to prevent.

Every section below is optional except Summary. Omit what you have no
evidence for; do not leave the heading behind.

## Small change — under ~50 lines, one concern

```markdown
## Summary

<One to three sentences: what changed and why. Fold any non-obvious
reviewer note in as a trailing sentence rather than adding a section for
it.>
```

Plus `## Related` if there are links worth carrying. Nothing else. No
files table — the diff is the map.

## Medium change — ~50–200 lines

```markdown
## Summary

<One short paragraph, or two to four bullets of material impact.>

## Approach            (only if the how is non-obvious)

<The design, not the steps you took. If this reads like the diffstat with
more words, cut it.>

## Testing             (only if verification is non-obvious)

<How to verify. Skip it when "the tests pass" is the whole story.>
```

At most two sections beyond Summary, and each has to earn its place.

## Large change — 200+ lines, or several concerns

```markdown
## Summary

<What changed and why, in a short paragraph.>

## Approach

### <Concern>

<Design and reasoning. Subsections only when the change genuinely spans
distinct concerns.>

## Tradeoffs and alternatives    (only if choices were made and rejected)

<What else was tried or considered, and why it lost. Prevents reviewers
re-raising options already ruled out.>

## Compatibility                 (only if behavior or interfaces change)

<Breaking changes, migration notes, deprecations.>

## Testing

<What was verified and how. Wrap long output in <details>.>

## Related

- <Full URLs. Never bare !123 or #123.>
```

## Notes

- No H1. Every forge renders the title separately.
- Wrap anything long in `<details><summary>…</summary>`.
- A table of touched surfaces is worth adding only when the change spans
  enough files that the diffstat is hard to read. It is never worth it on
  a small change.
