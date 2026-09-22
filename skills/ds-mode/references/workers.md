# Workers

The lead owns design, the visible `update_plan`, worker briefs, diff review, and final proof. Workers own only the task and paths in their briefs. Workers may keep their own task plans, but never share or mutate the lead's checklist.

## Write the brief

Include the role, task contract, scope, exclusions, writable paths, checkout, verification, model profile, and edit permission. Every fresh worker receives a complete brief without parent conversation history. Review independence requires a fresh context, whatever model is selected.

End every brief with this report contract:

- Use 800 words or fewer.
- State the result, evidence pointers, changed paths, checks, and open risks.
- Cite paths and line ranges instead of quoting source.
- Keep command output and bulk findings out of the report. Write them to an allowed artifact and return its path when the task needs them.

## Choose the checkout

One writer may use a clean active checkout. The lead may inspect it while the worker runs but does not edit it concurrently. Give parallel writers or competing implementations separate worktrees with disjoint ownership. Protect untracked files from deletion, overwrite, and incidental adoption.

## Pi-Herdr binding

This binding uses the `pi-herdr-agents` extension, targeting Pi 0.87.0 and Herdr 0.8.0 protocol 19 on Linux. It activates in an ordinary persistent Pi TUI session inside Herdr. Stock Pi without the adapter, non-TUI modes, and ephemeral sessions do not supply this binding. Inspect the available tool schemas before dispatch. Model selection and role thinking settings belong to [worker-profiles.md](worker-profiles.md).

1. Call `spawn_agent` with the complete brief in `task`, `role` set to `explore`, `implement`, `review`, or `judgment`, and `fork_turns: "none"`. Set `cwd` to the assigned checkout when needed. The adapter starts a fresh native Pi conversation in a separate tab, with no parent history.
2. Record the returned `workerId` and `submissionId` in the spawning agent's own plan explanation, without changing verbatim step text. Include descendant targets in reports to the lead. Together they identify the exact worker task, called the canonical child target in the playbooks. Use `workerId` as `agent_id` and `submissionId` as `submission_id` in tool calls. A native Pi session UUID, runtime generation, pane ID, and worker ID are distinct identities.
3. For each expected settlement, call `wait_agent` with both IDs and `timeout_ms` from 120000 to 600000. It may return early. A timeout leaves the task running. On timeout, call `list_agents` once to diagnose, then make one final multi-minute wait on that submission. If it still does not settle, record the anomaly and stop waiting. `accepted` means a correlated start, not completion. `ambiguous` is unresolved submission evidence, not permission to replay the task. Inspect its receipt and report it. Only `settled` supplies an outcome, which may be `completed`, `interrupted`, or `error`; `unavailable` is not success.
4. Continue the original conversation with `followup_task`, supplying `agent_id` and a new `task`. Record the new `submissionId`. It refuses a live busy or unreachable writer. Cold continuation requires proof that the original process and endpoint are dead, preserves the worker and native conversation, and starts a new runtime generation. It never replays the old task.
5. Use `interrupt_agent` with both IDs for a verified stuck or obsolete task, or an explicit pause. It waits up to 120 seconds for settlement. For ambiguous preflight, it requests shutdown and checks process death instead. Unconfirmed death requires operator inspection, not a replacement writer.

`update_plan` replaces only the caller's own session checklist. Supply a `plan` array of `{step, status}` entries and an optional top-level `explanation`. Status values are `pending`, `in_progress`, or `completed`. Preserve verbatim playbook text, explicit skips, and recorded targets when replacing the plan. A worker's plan cannot target the root lead's checklist.

For the lead, `/new` starts a separate plan and ownership tree. Old workers may remain alive, but the new conversation does not own them. Resume the owning lead conversation before continuing its workers. `/reload` and resuming that conversation retain its plan and descendants. Plans and descendants are session-wide, so `/tree` does not rewind them. Assigned workers cannot navigate away from their conversation, but can reload it.

All worker roles have normal tools, including Bash, Git through Bash, edits, writes, and nested delegation. A no-edit or read-only brief is an assignment constraint, not a locked-down tool profile. Respect the brief's permissions. Children load only this adapter extension and use normal Pi discovery for skills, context files, settings, and file-based authentication. Do not assume they inherit other lead extensions, external tools, or environment-only credentials.

Use the adapter tools, not manual pane or process control, for ordinary worker operations. The adapter retains completed conversations and their records. A failed or uncertain launch needs its exact operation receipt inspected; do not guess a target from the focused pane.

## Tool labels and transcripts

Pinned principles and supporting skills retain upstream tool labels. In this binding, `Read`, `Grep`, `Glob`, and `Shell` mean `read`, `grep`, `find`, and `bash`. `Task` means delegation through the worker contract above. Tool labels do not bypass assignment permissions. `AskQuestion` has no adapter implementation. Ask the real user through the conversation, or stop and report a genuine human question from a worker. Never invent the answer.

Resolve transcripts from exact runtime identity, not a session search. `list_agents` exposes descendant identities with `piSessionId` and `piSessionPath`. The adapter's state directory contains `workers/<workerId>.json`, `tasks/<workerId>/<submissionId>.json`, and the native child conversation at the recorded `piSessionPath`. Use the task record to delimit the submission within a continued conversation. `/herdr-agents` shows the current session identity and state directory.

Native Pi JSONL is the conversation evidence. Settled results point to `artifactPath` for full assistant text when tool output is capped, but that artifact is not the transcript. Verify file reads and tool calls against the native records. Do not assume another host's JSONL parser understands Pi records. When a skill permits a digest because the exact lead transcript is unavailable, disclose that limit; a digest cannot prove a candidate's tool history.

## Other runtimes

Generic lead and worker wording does not establish runtime compatibility. Before using another host, verify its documented controls for fresh contexts, exact worker and task identity, bounded waits, continuation, interruption, session-owned plans, and transcript evidence. Map the retained tool labels to real available tools. Do not assume these Pi adapter tool names or parameters are stock APIs elsewhere. Report a missing required control rather than silently skipping a workflow phase.

## Accept the result

Wait for delegated exploration before inspecting the same ownership slice. Verify claims with symbol or path searches and bounded excerpts. Do not concatenate full files or reproduce the worker's exploration.

Inspect the worker's diff and evidence yourself. Run the proof that owns the accepted outcome. Treat the worker report as a pointer, not proof.
