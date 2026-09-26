#!/bin/sh
# Check branch commits against Opening a PR's "Titles" before a push.
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
	[ "${#title}" -le 72 ] || problem="${problem:+$problem; }title over 72 characters"
	# A backslash-n typed inside a quoted -m touches the next word or ends the line. Code in backticks is exempt.
	git log -1 --format=%B "$sha" | sed 's/`[^`]*`//g' | grep -Eq '\\n([^[:space:],.;:)'"'"'"]|$)' && problem="${problem:+$problem; }literal \\n in message"
	if [ -n "$problem" ]; then
		# printf, not echo: macOS sh and dash expand a backslash-n in echo, hiding the defect being reported.
		printf '%s %s -- %s\n' "$(git log -1 --format=%h "$sha")" "$title" "$problem"
		status=1
	fi
done
if [ "$status" -ne 0 ]; then
	cat <<EOF

Rule: title "type(scope): outcome", at most 72 characters, imperative, no trailing period,
optionally ending " (#123)" or " (ABC-123)" for the ticket it resolves.
Types: $(printf '%s' "$types" | sed 's/|/, /g').
Body: two or three lines of why, written through a quoted heredoc: git commit -F - <<'MSG'
Reword each listed commit, then rerun this check.
EOF
fi
exit "$status"
