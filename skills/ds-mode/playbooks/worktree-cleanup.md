### Worktree and simulator cleanup

**You own the disk and the safety gate.** Deletion is irreversible. Audit first and ask before deleting protected state.

1. Record `df -h /`, then run `scripts/worktree-audit.sh`. It reads paths from `git worktree list` and reports size, age, branch reachability, merge state, PR state, tracked edits, and untracked files.
2. Supply known active Pi session and worktree associations. The audit has no liveness oracle. A reported bucket is advice, not permission.
3. Inspect every candidate. Any tracked edit or untracked file is protected. Name each protected path. Never delete, overwrite, or adopt an untracked file incidentally.
4. Ask before deleting a worktree or file that holds protected state. A clean, merged, unreachable-from-active-session worktree may proceed only under the user's deletion request.
5. Remove each confirmed worktree with `git worktree remove <path>`, using `--force` only after inspecting all remaining paths. If a directory survives, inspect every path before any direct removal. Run `git worktree prune`, record `df -h /`, and re-list worktrees.
6. For requested simulator cleanup, inspect the target set before running `xcrun simctl` deletion commands. Treat build directories and package caches as separate targets that need the same explicit scope.

**Reply:** disk use before and after, space reclaimed, worktrees pruned, every protected untracked path, and one reason for each worktree held back.
