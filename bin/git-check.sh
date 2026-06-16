#!/bin/bash
#
# git-check.sh
#
# Verify local git state after Xcode commits/pushes. Use this as the source
# of truth when Xcode's Source Control UI feels unreliable.
#
# Usage:
#   ./bin/git-check.sh           # check sync state (fetches from origin first)
#   ./bin/git-check.sh --no-fetch  # skip network fetch; use last-known remote refs
#
# Exit codes:
#   0 = clean and in sync with upstream
#   1 = action needed (uncommitted changes, unpushed/unpulled commits, or divergence)
#   2 = error (not a git repo, no upstream branch, fetch failed with --no-fetch off)
#

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"
FETCH=1

for arg in "$@"; do
    case "$arg" in
        --no-fetch)
            FETCH=0
            ;;
        -h|--help)
            sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown option: $arg (try --help)" >&2
            exit 2
            ;;
    esac
done

if ! command -v git &>/dev/null; then
    echo "Error: git is not installed or not on PATH." >&2
    exit 2
fi

if ! git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Error: $PROJECT_ROOT is not a git repository." >&2
    exit 2
fi

cd "$PROJECT_ROOT"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
UPSTREAM=""
if UPSTREAM="$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)"; then
    :
elif git show-ref --verify --quiet "refs/remotes/origin/$BRANCH"; then
    UPSTREAM="origin/$BRANCH"
else
    echo "Error: branch '$BRANCH' has no upstream and origin/$BRANCH was not found." >&2
    echo "Set upstream with: git branch --set-upstream-to=origin/$BRANCH" >&2
    exit 2
fi

REMOTE="${UPSTREAM%%/*}"

echo "========================================"
echo "  Git Sync Check"
echo "  Project: $PROJECT_NAME"
echo "  Branch:  $BRANCH"
echo "  Track:   $UPSTREAM"
echo "========================================"
echo

if [[ "$FETCH" -eq 1 ]]; then
    echo "→ Fetching from $REMOTE..."
    if ! git fetch "$REMOTE" --prune 2>&1; then
        echo
        echo "Warning: fetch failed. Showing state using last-known remote refs." >&2
        echo "         Re-run without network issues, or use --no-fetch to skip." >&2
        echo
    fi
else
    echo "→ Skipping fetch (--no-fetch)."
    echo
fi

# Working tree
STATUS_PORCELAIN="$(git status --porcelain)"
DIRTY=0
if [[ -n "$STATUS_PORCELAIN" ]]; then
    DIRTY=1
fi

UNPUSHED="$(git log --oneline "$UPSTREAM..HEAD" 2>/dev/null || true)"
UNPULLED="$(git log --oneline "HEAD..$UPSTREAM" 2>/dev/null || true)"
AHEAD="$(git rev-list --count "$UPSTREAM..HEAD" 2>/dev/null || echo 0)"
BEHIND="$(git rev-list --count "HEAD..$UPSTREAM" 2>/dev/null || echo 0)"

echo "Working tree:"
if [[ "$DIRTY" -eq 0 ]]; then
    echo "  ✓ Clean (nothing to commit)"
else
    echo "  ✗ Uncommitted changes present:"
    git status --short | sed 's/^/    /'
fi
echo

echo "Sync with $UPSTREAM:"
git status -sb | sed 's/^/  /'
echo

if [[ -n "$UNPUSHED" ]]; then
    echo "Unpushed commits (local only, run: git push):"
    echo "$UNPUSHED" | sed 's/^/  /'
    echo
fi

if [[ -n "$UNPULLED" ]]; then
    echo "Unpulled commits (on remote only, run: git pull):"
    echo "$UNPULLED" | sed 's/^/  /'
    echo
fi

# Summary
NEEDS_ACTION=0
SUMMARY="OK — clean and in sync with $UPSTREAM."

if [[ "$DIRTY" -ne 0 ]]; then
    NEEDS_ACTION=1
    SUMMARY="UNCOMMITTED — commit or stash changes before pushing."
elif [[ "$AHEAD" -gt 0 && "$BEHIND" -gt 0 ]]; then
    NEEDS_ACTION=1
    SUMMARY="DIVERGED — $AHEAD commit(s) to push, $BEHIND to pull. Pull/rebase, then push."
elif [[ "$AHEAD" -gt 0 ]]; then
    NEEDS_ACTION=1
    SUMMARY="NEEDS PUSH — $AHEAD commit(s) not on $UPSTREAM."
elif [[ "$BEHIND" -gt 0 ]]; then
    NEEDS_ACTION=1
    SUMMARY="NEEDS PULL — $BEHIND commit(s) on $UPSTREAM not in local $BRANCH."
fi

echo "========================================"
echo "  Summary: $SUMMARY"
echo "========================================"

if [[ "$NEEDS_ACTION" -eq 0 ]]; then
    exit 0
fi
exit 1