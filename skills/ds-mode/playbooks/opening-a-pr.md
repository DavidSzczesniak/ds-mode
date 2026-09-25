### Opening a PR

Invoked at the end of every other playbook. Also use when the user asks for a PR proposal or a title or body repair to an existing PR. A "local only" or "no PR" session override skips it.

**Checkout.** Follow the repository instructions and protect unrelated work. Use the current checkout when it is clean or dedicated to this task. Otherwise create a worktree off the base branch without asking and carry only this task's changes into it.

**Commits.** Commit liberally. Rebase into small, ordered commits before opening PRs. Each commit is a future PR: landable, ordered to tell the story. Amend when the fix belongs in a just-made commit. New commit when separable.

**Change.** Identify the repository and head branch, then check for an open PR. If one exists and this task added commits to its branch, push them and update its body to describe the final change. Otherwise report it and stop unless the user requested a title or body repair. For a repair, inspect the PR's base and head. For a new PR, use the requested base or repository default. When the commits sit on the default branch, create a topic branch at the current commit first; never push the default branch. Fetch the target branch and check the worktree and remote state. Change an existing PR's base only when the user explicitly asks.

**Evidence.** Inspect the final base-to-head diff, commits, changed files, and validation results. Reuse inspection, cleanup, review, and validation from this task when their inputs have not changed. Before publishing, finish any checks the repository requires. Run [deslop](../../deslop/SKILL.md) over the diff before each commit. Run [no-comments](../../no-comments/SKILL.md) before review when the diff adds comment or lint-suppression lines. Whoever opens the PR, lead or worker, first runs [interrogate](../../interrogate/SKILL.md) when the design was contested and the task has not run it yet, and confirms deslop covered the final diff, and no-comments when it applies.

**Issues.** Start with ticket references in the task, branch, commits, and repository guidance. Fetch those tickets and follow links needed to confirm how they relate to the change. Stop when you have checked those references. Keep every relevant, verified ticket across trackers, including Jira, GitHub Issues, and Linear.

**Titles and commit messages.** Use a Conventional Commit title, `type(scope): outcome`, for every commit except Pause safely's `wip:` commit, and for the PR and the squash commit. Choose the type from the problem solved or capability added. Use a short product or module name for the scope. Keep the outcome specific, imperative, and without a trailing period. If the commit or PR resolves a linked ticket, append that ticket's reference in parentheses: `(#123)` for a GitHub issue, `(ABC-123)` for other trackers. Give each branch commit a body of two or three lines that says why: the need or the root cause. Merge commits are exempt too. Before every push, run `<this skill's directory>/scripts/check-commit-titles.sh <base-branch>` by its absolute path from the checkout being pushed. Reword every commit it prints, and push only when it exits 0.

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
- `## Scope`. Add decisions, boundaries, or affected consumers that `Why` does not cover. When the change touches shared code, name who and what it touches and why the change is safe for them.
- `## Issues`. Link every relevant, verified ticket, even if it is absent from the title. Omit this section for untracked work.
- `## Validation`. Record checks completed against the change, their outcomes, what they prove, and any important gaps. Include only results that still apply to the current head. Summarize routine automated checks.
- `## Squash commit message`. Use a fenced `text` block for the commit body only. Explain the need or root cause, resulting behavior, and lasting constraints in two or three lines. Reuse sentences that already explain the change. Exclude validation results and reviewer instructions.

Add `Review focus` for specific review questions. Add `Risks and trade-offs` or `Rollout and rollback` for concerns such as migrations, security, schema changes, tenant impact, deployment, compatibility, or reversal. Keep each fact in one section, except where the squash message needs it. Omit file lists, abandoned approaches, boilerplate, and tool credits. Attach videos or screenshots when they prove a claim.

**Size and stacks.** Prefer five narrow PRs to one large PR. Stack follow-ups: open each PR with its base set to the branch below it. After Verify on the top PR, join the stack with `gh stack link <PR number>...` (the `github/gh-stack` extension), bottom to top, adding `--base <branch>` when the bottom PR does not target the default branch. Pass PR numbers only; a branch without a PR, or `gh stack submit`, makes gh-stack open PRs with generated titles. If linking fails, report it and keep the base-chained PRs. Branch from the default branch only for independent work. Rebase on the default branch before substantial stack work.

**Proposals.** When the user asks only for a title and body, return or save them. You may read remote state. Stop before pushing or changing GitHub.

**Creation.** Push the branch normally if needed, then use `gh pr create` with the verified base, head, title, and body. Open the PR ready unless the user requested a draft. Rewrite an existing remote branch only with the user's explicit approval.

**Repair.** When the user explicitly asks, read the existing PR's title, body, base, head, and draft state. Update its title or body in place. Keep its draft state, useful human content, issue context, and validation results that still apply.

**Verify.** After creating or repairing the PR, read it back with `gh pr view`. Check the rendered title, body, base, head, draft state, and URL. Correct any mismatch before reporting completion.

**Verdict.** After creating the PR or pushing new commits to it, the PR opener gets an independent verdict for the head, unless a verdict with a matching `git patch-id` already covers it. Inside a multi-phase plan, skip this step; the plan's swarm verdict replaces it.

- A PR that changes no behavior says so in its body and needs no verdict.
- Launch one fresh Review worker per `../references/workers.md`. Brief it with the PR URL, the head SHA, and the checkout path. Leave that checkout unchanged until the verdict returns.
- The worker exercises the real surface ([control-ui](../../control-ui/SKILL.md) or [control-cli](../../control-cli/SKILL.md) as the change demands) against base versus head and returns `PASS`, `PASS+NOTES` or `FAIL`. It posts the verdict on the PR with the head SHA and the screenshots that prove it (`gh pr comment <number> --body-file <file> --attach <path>`).
- When the PR changes an interaction, the worker also records a 30 to 60 second video of the change and attaches it.
- On `FAIL`, fix the findings, push, repeat Change and Verify, and get a new verdict from a fresh worker.
- Independent means a verdict from an agent that did not write the code. CI green is not a verdict, and an approving bot review is not a verdict.

Opening a PR does not start PR Check and Triage. Post the URL and the verdict, and keep building. A later status request routes to `playbooks/pr-check-and-triage.md`.
