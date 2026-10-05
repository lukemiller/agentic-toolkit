#!/usr/bin/env bash
# Gather everything change-description needs, in one call, with no network
# access. Prints labelled sections; read them and follow any `hint:` line.
#
# Usage: change-context.sh [base-ref]
#   base-ref  optional; otherwise resolved from local refs only.

set -u

BASE=${1:-${CHANGE_BASE:-}}

if [ -z "$BASE" ]; then
  BASE=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
fi
if [ -z "$BASE" ]; then
  for candidate in origin/main origin/master main master; do
    if git rev-parse --verify --quiet "$candidate" >/dev/null 2>&1; then
      BASE=$candidate
      break
    fi
  done
fi

echo "=== BASE ==="
if [ -z "$BASE" ]; then
  echo "base: (none found)"
  echo "hint: no base branch resolved. Ask the operator which ref to compare against."
  exit 0
fi
echo "base: $BASE"
echo "branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null)"

AHEAD=$(git rev-list --count "$BASE"..HEAD 2>/dev/null || echo 0)
DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

echo "=== STATE ==="
echo "commits_ahead: $AHEAD"
echo "dirty_paths: $DIRTY"
if [ "$AHEAD" -gt 0 ] && [ "$DIRTY" -eq 0 ]; then
  echo "describe: commits"
elif [ "$AHEAD" -gt 0 ]; then
  echo "describe: commits"
  echo "hint: uncommitted work exists and is NOT described. Say so in the output."
elif [ "$DIRTY" -gt 0 ]; then
  echo "describe: working-tree"
  echo "hint: nothing is committed yet. Describe the working tree, including"
  echo "hint: untracked files, and tell the operator to recheck after committing."
else
  echo "describe: nothing"
  echo "hint: no commits ahead and a clean tree. Say so and stop; invent nothing."
  exit 0
fi

echo "=== DIFFSTAT ==="
if [ "$AHEAD" -gt 0 ]; then
  git diff "$BASE"...HEAD --stat
else
  git status --short
  git diff HEAD --stat
fi

# Bulk that should not drive the prose budget: planning narrative, lock
# files, vendored and generated trees. A plan and log are verbose by
# design and would push every change into "large"; a lock file can be
# thousands of lines behind a two-line manifest edit. Override with
# CHANGE_SIZE_EXCLUDE, a colon-separated list of globs.
DEFAULT_EXCLUDE='docs/workstreams/**:**/*.lock:**/package-lock.json:**/pnpm-lock.yaml:**/vendor/**:**/node_modules/**:**/dist/**:**/*.min.*'
# No colon in the expansion: setting CHANGE_SIZE_EXCLUDE= (empty) disables
# exclusions entirely, rather than silently falling back to the default.
EXCLUDE_GLOBS=${CHANGE_SIZE_EXCLUDE-$DEFAULT_EXCLUDE}

EXCLUDE_SPEC=()
OLD_IFS=$IFS
IFS=:
for g in $EXCLUDE_GLOBS; do
  [ -n "$g" ] && EXCLUDE_SPEC+=(":(exclude)$g")
done
IFS=$OLD_IFS

count_changed() {
  if [ "$AHEAD" -gt 0 ]; then
    git diff "$BASE"...HEAD --numstat -- "$@" 2>/dev/null |
      awk '{a+=$1; d+=$2} END {print a+d+0}'
  else
    n=$(git diff HEAD --numstat -- "$@" 2>/dev/null |
      awk '{a+=$1; d+=$2} END {print a+d+0}')
    while IFS= read -r f; do
      [ -n "$f" ] && n=$((n + $(wc -l < "$f" 2>/dev/null || echo 0)))
    done < <(git ls-files --others --exclude-standard -- "$@" 2>/dev/null)
    echo "$n"
  fi
}

list_paths() {
  if [ "$AHEAD" -gt 0 ]; then
    git diff "$BASE"...HEAD --name-only -- "$@" 2>/dev/null
  else
    { git diff HEAD --name-only -- "$@" 2>/dev/null
      git ls-files --others --exclude-standard -- "$@" 2>/dev/null; }
  fi
}

echo "=== SIZE ==="
TOTAL=$(count_changed .)
SUBSTANTIVE=$(count_changed . "${EXCLUDE_SPEC[@]}")

echo "lines_changed: $TOTAL"
if [ "$SUBSTANTIVE" -ne "$TOTAL" ]; then
  echo "lines_substantive: $SUBSTANTIVE"
  list_paths . | sort -u > /tmp/.cd_all.$$
  list_paths . "${EXCLUDE_SPEC[@]}" | sort -u > /tmp/.cd_kept.$$
  comm -23 /tmp/.cd_all.$$ /tmp/.cd_kept.$$ | sed 's/^/excluded: /'
  rm -f /tmp/.cd_all.$$ /tmp/.cd_kept.$$
fi

# A change that is *only* excluded paths is still a real change; size it
# on the total rather than reporting zero.
SIZE_ON=$SUBSTANTIVE
if [ "$SUBSTANTIVE" -eq 0 ] && [ "$TOTAL" -gt 0 ]; then
  SIZE_ON=$TOTAL
  echo "hint: every changed path is excluded bulk; sizing on the total instead."
fi

if [ "$SIZE_ON" -lt 50 ]; then
  echo "size: small"
elif [ "$SIZE_ON" -le 200 ]; then
  echo "size: medium"
else
  echo "size: large"
fi
echo "hint: size comes from substantive lines, not the raw total. It is a"
echo "hint: floor, not a verdict — several unrelated concerns raise it."

echo "=== COMMITS ==="
if [ "$AHEAD" -gt 0 ]; then
  git log --oneline "$BASE"..HEAD
fi

echo "=== CONVENTION ==="
echo "hint: match these subjects. Do not introduce a prefix style absent here."
git log --oneline -20

echo "=== TEMPLATE ==="
FOUND=0
for t in \
  .gitlab/merge_request_templates/*.md \
  .forgejo/PULL_REQUEST_TEMPLATE.md .forgejo/pull_request_template.md \
  .gitea/PULL_REQUEST_TEMPLATE.md .gitea/pull_request_template.md \
  .github/PULL_REQUEST_TEMPLATE.md .github/pull_request_template.md \
  .github/PULL_REQUEST_TEMPLATE/*.md \
  docs/PULL_REQUEST_TEMPLATE.md docs/pull_request_template.md
do
  if [ -f "$t" ]; then echo "template: $t"; FOUND=1; fi
done
if [ "$FOUND" -eq 0 ]; then
  echo "hint: no project template. Use references/TEMPLATE.md."
fi

echo "=== CONTRIBUTING ==="
for c in CONTRIBUTING.md .github/CONTRIBUTING.md docs/CONTRIBUTING.md; do
  if [ -f "$c" ]; then echo "contributing: $c"; fi
done

# Explicit: a trailing test that finds nothing must not become the exit status.
exit 0
