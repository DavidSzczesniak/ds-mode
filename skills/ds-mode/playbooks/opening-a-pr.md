### Opening a PR

Use when the user asks for a PR proposal, a new PR, or a title or body repair to an existing PR.

**Checkout.** Follow the repository instructions. Use the current checkout and protect unrelated work. Ask the user before creating a worktree.

**Change.** Identify the repository and head branch, then check for an open PR. If one exists, report it and stop unless the user requested a title or body repair. For a repair, inspect the PR's base and head. For a new PR, use the requested base or repository default. Fetch the target branch and check the worktree and remote state. Change an existing PR's base only when the user explicitly asks.

**Evidence.** Inspect the final base-to-head diff, commits, changed files, and validation results. Reuse inspection, cleanup, review, and validation from this task when their inputs have not changed. Before publishing, finish any checks the repository requires. Run [deslop](../../deslop/SKILL.md) over the diff before commit. Run [no-comments](../../no-comments/SKILL.md) before review.

**Issues.** Start with ticket references in the task, branch, commits, and repository guidance. Fetch those tickets and follow links needed to confirm how they relate to the change. Stop when you have checked those references. Keep every relevant, verified ticket across trackers, including Jira, GitHub Issues, and Linear.

**Titles.** Use a Conventional Commit title, `type(scope): outcome [issue reference]`, for the PR and squash commit. Choose the type from the problem solved or capability added. Use a short product or module name for the scope. Keep the outcome specific, imperative, and without a trailing period. If the work has a linked ticket, use the repository's issue-reference format in the title.

Choose the narrowest accurate type:

- `feat` adds a user-facing capability.
- `fix` corrects faulty user or maintainer behavior.
- `docs` changes documentation only.
- `style` changes formatting without changing runtime behavior.
- `refactor` changes code structure without an intended behavior change.
- `test` changes tests only.
- `perf` improves performance.
- `build` changes dependencies, the build system, or the toolchain.
- `chore` covers repository maintenance that does not fit another type.

**Descriptions.** Describe the final change. Use [technical-writing](../../technical-writing/SKILL.md) and [unslop](../../unslop/SKILL.md) for the title and body. Use these sections in order:

- `## Why`. Explain the problem, its effect, and the resulting behavior. State a root cause only when the evidence supports it.
- `## Scope`. Add decisions, boundaries, or affected consumers that `Why` does not cover.
- `## Issues`. Link every relevant, verified ticket, even if it is absent from the title. Omit this section for untracked work.
- `## Validation`. Record checks completed against the change, their outcomes, what they prove, and any important gaps. Include only results that still apply to the current head. Summarize routine automated checks.
- `## Squash commit message`. Use a fenced `text` block for the commit body only. Explain the need or root cause, resulting behavior, and lasting constraints in two or three lines. Reuse sentences that already explain the change. Exclude validation results and reviewer instructions.

Add `Review focus` for specific review questions. Add `Risks and trade-offs` or `Rollout and rollback` for concerns such as migrations, security, schema changes, tenant impact, deployment, compatibility, or reversal. Keep each fact in one section, except where the squash message needs it. Omit file lists, abandoned approaches, boilerplate, and tool credits. Attach videos or screenshots when they prove a claim.

**Proposals.** When the user asks only for a title and body, return or save them. You may read remote state. Stop before pushing or changing GitHub.

**Creation.** Push the branch normally if needed, then use `gh pr create` with the verified base, head, title, and body. Open the PR ready unless the user requested a draft. Rewrite an existing remote branch only with the user's explicit approval.

**Repair.** When the user explicitly asks, read the existing PR's title, body, base, head, and draft state. Update its title or body in place. Keep its draft state, useful human content, issue context, and validation results that still apply.

**Verify.** After creating or repairing the PR, read it back with `gh pr view`. Check the rendered title, body, base, head, draft state, and URL. Correct any mismatch before reporting completion.

Opening a PR does not start PR Check and Triage. Post the URL. A later status request routes to `playbooks/pr-check-and-triage.md`.
