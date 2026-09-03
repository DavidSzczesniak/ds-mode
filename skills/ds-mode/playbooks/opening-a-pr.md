### Opening a PR

Use only when the user requested a PR.

**Checkout.** One writer may use a clean or dedicated active checkout. Use separate worktrees for parallel writers, competing experiments, or tracked-file conflicts. Protect untracked files. The lead does not mutate a writer's checkout.

**Commits.** Commit verified local units when repository instructions allow. Rebase into small, ordered commits before opening the PR. Amend when a fix belongs in the last commit. Use a new commit when it stands alone.

**Review.** Run [**deslop**](../../deslop/SKILL.md) over the diff before commit. Run [**no-comments**](../../no-comments/SKILL.md) before review. Write every title, description, and commit body with [**technical-writing**](../../technical-writing/SKILL.md), then apply [**unslop**](../../unslop/SKILL.md).

**Titles.** Use Conventional Commits in the form `type(scope): subject`. Use `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, or `perf`. Keep the subject short, imperative, and without a trailing period.

**Descriptions.** Use these sections in order. Drop an empty section.

- `## Why`. State the intent and why the approach fits.
- `## Scope`. State facts from the diff. Name what is in and out when the boundary matters.
- `## Tradeoffs`. State real choices only.
- `## Blast Radius`. State who and what the change touches, and why it is safe or risky.
- `## Verification`. Name each real command or control path and its outcome.

Attach videos or screenshots when they prove a claim. Do not use `## Summary` or `## Test plan` boilerplate.

**Readiness.** Use ordinary Git branches and `gh pr create`. Open the PR ready unless the user requested a draft. Run `gh pr view <number>` before referring to PR status.

Opening a PR does not start PR Check and Triage. Post the URL. A later status request routes to `playbooks/pr-check-and-triage.md`.
