# Workers

The lead owns design, the main checklist, worker briefs, diff review, and final proof. Each worker owns its assigned task and paths. Workers may keep their own plans; they cannot change the lead's plan.

## Brief and checkout

Give every fresh worker a brief that stands on its own; it has no parent conversation history. Open it as **Workers** in `../SKILL.md` directs. Every brief you write carries three fields. A routed skill's worker keeps the brief that skill prescribes. A field you cannot fill is a task you have not scoped yet, so do not spawn until you can.

- **SCOPE.** The task's scope, and its non-goals when it states them, quoted verbatim from the ticket or user request, then this worker's unit and the files the worker may change (none for review, exploration, and judgment). Never widen the quoted scope. Record further work as a follow-up. A review worker checks the diff against it.
- **FORBIDDEN.** Changes outside SCOPE, including adjacent fixes and cleanups, plus task-specific bans. The worker reports out-of-scope findings instead of acting on them.
- **VERIFY.** The exact commands that prove the task, including the repository's documented test command, not only targeted tests, before a code-writing worker reports done. Follow repository instructions where they name the gate. For review, exploration, and judgment, VERIFY names the evidence the report must cite.

Also give the named data shape for code and any session override, such as local only. Size the brief to the task. A small task collapses the fields to a paragraph that still names all three. Give file pointers, not inlined context, and ask for the same in the report. A code-writing worker builds, verifies, and commits each small unit in order ([sequence-verifiable-units](../../principle-sequence-verifiable-units/SKILL.md)). The lead reviews those commits; Opening a PR can still reshape them. Reviews require fresh contexts.

Use one writer per checkout. The lead may inspect the checkout while the worker runs, but must not edit it. Give parallel writers or competing implementations separate worktrees with disjoint ownership. Protect untracked files from deletion, overwrite, and incidental adoption.

## Start and wait

These instructions use `pi-herdr-agents` in a persistent Pi TUI inside Herdr. Check the available tool schemas before dispatch. Stock Pi, non-TUI modes, and ephemeral sessions do not provide these controls.

1. Call `spawn_agent` with the brief in `task`, the assigned `cwd`, and `fork_turns: "none"`. Pass the `role`, `model`, and `thinking` from [worker-profiles.md](worker-profiles.md). Each worker starts a fresh Pi conversation in its own tab.
2. Save the returned `workerId` and `submissionId` in your plan's `explanation`. Keep playbook step text unchanged. Report descendant targets to the lead. This pair is the **canonical child target** used in the playbooks. Pass the values as `agent_id` and `submission_id`; pane IDs, Pi session UUIDs, and runtime generations are different identifiers.
3. Call `wait_agent` with both IDs and `timeout_ms` between 120000 and 600000. It returns early if the task settles. A timeout leaves the task running. On timeout, call `list_agents` to diagnose. Note the size of the worker's session file (`piSessionPath`) before each further wait. While the task is active and the file keeps growing, keep waiting in multi-minute windows. Two consecutive full windows without growth are a stall: record the anomaly and treat the work as stale.

Read the result before proceeding:

| Result | Meaning and action |
|---|---|
| `accepted` | The task started. Wait for settlement. |
| `settled` | Inspect the outcome: `completed`, `interrupted`, or `error`. |
| `ambiguous` | The task may still start. Inspect the receipt and report the uncertainty. Never replay it. |
| `unavailable` | Read the reason. This is not a completed outcome. |

## Continue or interrupt

For a new task on a settled worker, such as a question about its result or a small follow-up, call `followup_task` with `agent_id` and the new `task`. Save its new `submissionId`. Resume interrupted or stale work in a fresh worker with consolidated scope instead; see **Workers** in `../SKILL.md`. Interrupt a stale worker first and confirm it settled before the replacement starts, so one writer still owns the checkout. The adapter refuses a live busy or unreachable worker. To restart a dead worker, it first proves the old process and endpoint are dead. It preserves the worker ID and Pi conversation, starts a new runtime generation, and submits only the new task.

Use `interrupt_agent` with both IDs for a verified stuck or obsolete task, or an explicit pause. It waits up to 120 seconds for settlement. If submission is ambiguous before the task starts, it requests shutdown and checks process death instead. If death remains unconfirmed, get operator inspection rather than starting a replacement writer.

Use these tools for ordinary worker operations, not manual pane or process control. The adapter retains completed conversations and records. For a failed or uncertain launch, inspect its exact operation receipt instead of guessing from the focused pane.

## Retire idle workers

Before the final handoff, call `retire_agent` with `agent_id` for each owned worker you no longer need. Accept its result and finish any follow-up first. Retire descendants before their parents. Task settlement alone does not close a worker's process or tab.

Retirement refuses active or uncertain work and workers with live or unresolved descendants. Only a result with `kind: "retirement"` and `state: "retired"` confirms process death and pane cleanup. For `incomplete`, keep the evidence path and report the unresolved cleanup. Retry retirement only for that same worker's cleanup; never replay its task or close a guessed pane.

Retirement preserves the conversation, results, artifacts, and model settings. A later `followup_task` resumes that conversation in a new process and tab. It is still a continuation, not an independent review.

## Tools and permissions

Every role has normal tools, including Bash, Git through Bash, edit, write, and nested delegation. A read-only brief limits what the worker may change, not which tools it receives.

Children load only the adapter extension. Pi discovers their skills, context files, settings, and file-based authentication. Do not assume they inherit the lead's other extensions, external tools, or environment-only credentials.

In retained upstream instructions, `Read`, `Grep`, `Glob`, and `Shell` map to `read`, `grep`, `find`, and `bash`. Use the worker steps above for `Task`.

There is no adapter `AskQuestion` tool. The lead asks the real user in the conversation. A worker stops and reports a genuine human question to the lead. Neither invents the user's answer.

## Plans and sessions

`update_plan` replaces the caller's checklist. Pass a `plan` array of `{step, status}` entries and an optional top-level `explanation`. Status is `pending`, `in_progress`, or `completed`. Preserve verbatim playbook text, explicit skips, and saved targets on every update.

For the lead, `/new` starts a new plan and worker ownership tree. Old workers may remain alive; resume their owning lead conversation to continue them. `/reload` and resuming a conversation retain its plan and descendants. `/tree` does not rewind that state. Assigned workers may reload their conversation but cannot navigate away from it.

## Evidence and acceptance

Resolve transcripts from the exact worker identity, not a search through unrelated sessions. `list_agents` exposes `piSessionId` and `piSessionPath`. `/herdr-agents` shows the current identity and state directory. That directory holds:

- `workers/<workerId>.json`: worker identity.
- `tasks/<workerId>/<submissionId>.json`: the task record, used to delimit one submission within a continued conversation.

Read the native Pi JSONL at `piSessionPath` to verify file reads and tool calls. A settled result's `artifactPath` contains full assistant text when output is capped, not the transcript. Check that any parser understands Pi records. Where a skill allows a lead-session digest, disclose the missing transcript; the digest cannot prove tool history.

Wait for delegated exploration before inspecting the same ownership slice. Check claims with symbol or path searches and bounded excerpts. Do not concatenate full files or repeat the worker's exploration.

Inspect the diff and evidence yourself. Run the checks that prove the accepted outcome. A worker report points to evidence; it is not proof.

## Other runtimes

Verify equivalent controls before using another runtime: fresh contexts, exact worker and task IDs, bounded waits, continuation, interruption, explicit idle-worker retirement, separate session plans, and transcript evidence. Map tool labels to its documented APIs. If a required control is missing, report it rather than skipping the workflow phase.
