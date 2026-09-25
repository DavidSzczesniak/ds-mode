#!/bin/sh
# Check branch commits against Opening a PR's "Titles and commit messages" before a push.
# Usage: check-commit-titles.sh <base-ref>. Prints each non-conforming commit and exits 1; exits 0 only when all conform.
# Merge commits and Pause safely's wip: commits are exempt. Git's own trailer parsing decides what is not a why body.
set -eu
base=${1:?usage: check-commit-titles.sh <base-ref>}
types='feat|fix|docs|style|refactor|test|perf|build|chore'
ticket=' \((#[0-9]+|[A-Z][A-Z0-9]*-[0-9]+)\)$'
# A separate assignment so an unknown base fails the check instead of checking nothing.
revs=$(git rev-list --no-merges "$base..HEAD")
status=0
for sha in $revs; do
	title=$(git log -1 --format=%s "$sha")
	case "$title" in wip:*) continue ;; esac
	problem=""
	outcome=$(printf '%s\n' "$title" | sed -E "s/$ticket//")
	printf '%s\n' "$outcome" | grep -Eq "^($types)\([^()[:space:]]+\): [^ ].*[^. ]$" || problem="title is not type(scope): outcome"
	lines=$(git log -1 --format=%b "$sha" | grep -c '[^[:space:]]' || true)
	trailers=$(git log -1 --format='%(trailers:only,unfold=false)' "$sha" | grep -c '[^[:space:]]' || true)
	[ "$lines" -gt "$trailers" ] || problem="${problem:+$problem; }no why body"
	if [ -n "$problem" ]; then
		echo "$(git log -1 --format=%h "$sha") $title -- $problem"
		status=1
	fi
done
exit "$status"
