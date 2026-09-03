# Workers

Codex is the lead. It owns design, the visible `update_plan`, worker briefs, diff review, and final proof. Workers own only the task and paths in their briefs.

## Write the brief

Include the role, task contract, scope, exclusions, writable paths, checkout, verification, model profile, and edit permission. Workers report results. They do not mutate the lead's plan.

End every brief with this report contract:

- Use 800 words or fewer.
- State the result, evidence pointers, changed paths, checks, and open risks.
- Cite paths and line ranges instead of quoting source.
- Keep command output and bulk findings out of the report. Write them to an allowed artifact and return its path when the task needs them.

## Choose the checkout

One writer may use a clean active checkout. The lead may inspect it while the worker runs but does not edit it concurrently. Give parallel writers or competing implementations separate worktrees with disjoint ownership. Protect untracked files from deletion, overwrite, and incidental adoption.

## Run the worker

Use Codex's native collaboration tools.

1. Start one fresh child with `spawn_agent`. Set `fork_turns` to `none` and put the complete brief in its task.
2. Record the returned canonical child target in `update_plan`.
3. For each expected child settlement, call `wait_agent` with `timeout_ms` from 120000 to 600000. It may return early. If it times out or returns only an intermediate mailbox update, call `list_agents` once to diagnose, then make one final multi-minute wait. If the child still does not settle, record the anomaly and stop waiting.
4. Continue the same child with `followup_task` when the task needs another turn.
5. Use `interrupt_agent` only for a verified stuck or obsolete task.

Native children need no pane, PID, transport selection, or external cleanup. Use medium reasoning for Explore and Implement. Use high reasoning for Review and Judgment.

## Accept the result

Wait for delegated exploration before inspecting the same ownership slice. Verify claims with symbol or path searches and bounded excerpts. Do not concatenate full files or reproduce the worker's exploration.

Inspect the worker's diff and evidence yourself. Run the proof that owns the accepted outcome. Treat the worker report as a pointer, not proof.
