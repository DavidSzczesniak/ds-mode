# ds-mode agent guide

`Last reviewed: 2026-08`

This repository develops the `$ds-mode` workflow. Keep it small and evidence-led.

## Current bootstrap boundary

- The `principle-*` bodies are unchanged review candidates. Do not rewrite, remove, or activate one until the user has reviewed it individually.
- Do not run `scripts/install.sh` until the principle review and routing are complete.
- Leave `/Users/david/Documents/workspaces/dforge` unchanged as a reference.
- Keep work on `main`. Create no branch or worktree without explicit approval.
- Stage, commit, publish, or create a remote only when the user asks.

## Change the workflow

- Start with the current repository behavior and the dogfooding evidence that motivates the change.
- Check the target codebase before attributing a repeated agent failure to ds-mode.
- Prefer the smallest direct correction. Do not turn one observation into general runtime policy.
- Use `writing-for-agents` for skills and agent instructions. Use `unslop` for prose.
- Update the README or dogfooding guide only when their documented behavior changes.

## Verify changes

Run the smallest checks that prove the changed contract. Validate changed skills with the Codex skill validator. Test installer changes against an isolated temporary destination before touching `~/.agents/skills`.

After a completed code or workflow change, give one fresh reviewer agent the task contract, repository rules, exact diff, and completed verification. Withhold the implementer's rationale until the independent review is complete.
