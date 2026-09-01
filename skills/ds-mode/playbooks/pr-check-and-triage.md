### PR Check and Triage

**You own one current-state inspection.** Use when the user asks to check a PR, inspect CI or conflicts, or triage current review comments.

1. Identify the PR or the explicit list of PRs. Inspect each once with `gh pr view <number> --json url,state,isDraft,mergeable,mergeStateStatus,headRefOid,reviewDecision,statusCheckRollup` and `gh pr checks <number>`.
2. Query review threads once. Report unresolved comments with their path, author, and URL. Triage requested Bugbot and security-review comments per `../references/bugbot-triage.md` as fix, dismiss, or ask.
3. Compare every claim to the current head SHA. State CI failures, pending checks, draft state, mergeability, conflicts, review state, and unresolved comments.
4. Make a requested local fix as a normal ds-mode unit. Push or respond on GitHub only when the user requested that remote action.
5. Return the snapshot. A later check is a new invocation.

This playbook performs no polling, sleeping, automatic retry, queue maintenance, automatic response, merge, or landing action.

**Reply:** the PR URL and head SHA, current CI and merge state, unresolved comments and triage, actions taken, and what remains.
