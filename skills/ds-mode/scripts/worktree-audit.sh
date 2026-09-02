#!/bin/sh

set -eu

repo=${1:-.}
root=$(git -C "$repo" rev-parse --show-toplevel)
now=$(date +%s)
base=$(git -C "$root" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
if [ -z "$base" ]; then
  if git -C "$root" show-ref --verify --quiet refs/heads/main; then
    base=main
  elif git -C "$root" show-ref --verify --quiet refs/heads/master; then
    base=master
  else
    base=HEAD
  fi
fi

printf 'path\tbranch\thead\tsize_kb\tage_days\treachable_refs\tbase\tmerged_base\ttracked\tuntracked\tpr\n'
git -C "$root" worktree list --porcelain | awk '/^worktree / {print substr($0, 10)}' |
while IFS= read -r path; do
  head=$(git -C "$path" rev-parse --short HEAD)
  branch=$(git -C "$path" symbolic-ref --quiet --short HEAD || printf detached)
  size_kb=$(du -sk "$path" | awk '{print $1}')
  commit_ts=$(git -C "$path" log -1 --format=%ct)
  age_days=$(( (now - commit_ts) / 86400 ))
  reachable_refs=$(git -C "$path" for-each-ref --format='%(refname)' --contains HEAD refs/heads refs/remotes | wc -l | tr -d ' ')
  tracked=$(git -C "$path" status --porcelain --untracked-files=no | wc -l | tr -d ' ')
  untracked=$(git -C "$path" ls-files --others --exclude-standard | wc -l | tr -d ' ')
  if git -C "$path" merge-base --is-ancestor HEAD "$base" 2>/dev/null; then
    merged=yes
  else
    merged=no
  fi
  if command -v gh >/dev/null 2>&1 && [ "$branch" != detached ]; then
    pr=$(cd "$path" && gh pr list --head "$branch" --state all --json number,state --jq 'if length == 0 then "none" else map("#\(.number):\(.state)") | join(",") end' 2>/dev/null || printf unknown)
  else
    pr=unavailable
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$path" "$branch" "$head" "$size_kb" "$age_days" "$reachable_refs" "$base" "$merged" "$tracked" "$untracked" "$pr"
done

printf '\nAge is days since the head commit. Reachable refs count local and remote branch refs that contain the head.\n'
printf 'Every tracked edit and untracked file is protected. Supply active Codex child associations before deletion.\n'
