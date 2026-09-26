# Earlier ds-mode PR body format

ds-mode used this PR body format until 2026-09-26. Opening a PR now uses pstack's sections plus `Open decisions` and `Squash commit message`, on trial across a few dogfood runs. Restore this text in `skills/ds-mode/playbooks/opening-a-pr.md` if the trial goes back to it. Skills never load this file.

**Descriptions.** Describe the final change. Use [technical-writing](../../technical-writing/SKILL.md) and [unslop](../../unslop/SKILL.md) for the title and body. Use these sections in order:

- `## Why`. Explain the problem, its effect, and the resulting behavior. State a root cause only when the evidence supports it.
- `## Scope`. Add decisions, boundaries, or affected consumers that `Why` does not cover. When the change touches shared code, name who and what it touches and why the change is safe for them.
- `## Issues`. Link every relevant, verified ticket, even if it is absent from the title. Omit this section for untracked work.
- `## Validation`. Record checks completed against the change, their outcomes, what they prove, and any important gaps. Include only results that still apply to the current head. Summarize routine automated checks.
- `## Squash commit message`. Use a fenced `text` block for the commit body only. Explain the need or root cause, resulting behavior, and lasting constraints in two or three lines. Reuse sentences that already explain the change. Exclude validation results and reviewer instructions.

Add `Review focus` for specific review questions. Add `Risks and trade-offs` or `Rollout and rollback` for concerns such as migrations, security, schema changes, tenant impact, deployment, compatibility, or reversal. Keep each fact in one section, except where the squash message needs it. Omit file lists, abandoned approaches, boilerplate, and tool credits. Attach videos or screenshots when they prove a claim.
