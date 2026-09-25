# Workers

Workers run through the `pi-herdr-agents` tools in a Pi TUI inside Herdr. The tool descriptions define parameters and results. These are ds-mode's conventions on top.

**Briefs.** Every brief stands alone and opens as **Workers** in `../SKILL.md` directs. A brief you write carries three fields. A routed skill's worker keeps the brief that skill prescribes. A field you cannot fill means the task is not scoped yet, so do not spawn.

- **SCOPE.** The task's scope, and its non-goals when stated, quoted verbatim from the ticket or request. Then this worker's unit and the files it may change, which is none for review, exploration, and judgment unless the routed skill grants edits. Never widen the quote. Record further work as a follow-up. A review worker checks the diff against it.
- **FORBIDDEN.** Changes outside SCOPE, including adjacent fixes and cleanups, plus task-specific bans. The worker reports out-of-scope findings instead of acting on them.
- **VERIFY.** The exact commands that prove the task, including the repository's documented test command before a code-writing worker reports done. Repository instructions that name the gate win. For review, exploration, and judgment, the evidence the report must cite.

Also give the named data shape for code and any session override, such as local only. Size the brief to the task. A small task collapses the fields to a paragraph. File pointers, not inlined context, both ways. A code-writing worker builds, verifies, and commits each small unit in order ([sequence-verifiable-units](../../principle-sequence-verifiable-units/SKILL.md)). Reviews need fresh workers.

**Dispatch.** `spawn_agent` with the brief, the assigned `cwd`, `fork_turns: "none"`, and `role`, `runtime`, `model`, and `thinking` from [worker-profiles.md](worker-profiles.md). Save `workerId` and `submissionId`, the **canonical child target**, in your plan's `explanation`. A nested owner reports its descendants' targets to its parent.

**Waiting.** `wait_agent` in multi-minute windows. Before each further window, note the size of the worker's session file (`piSessionPath`, or `transcriptPath` for Claude). Two full windows without growth are a stall. Record it and treat the work as stale. `ambiguous` and `unavailable` are not completion. Never replay them.

**Claude workers.** Give them leaf work only. Claude trusts folders per repository, so run them in the repository or a git worktree of it, never a copied or extracted directory. For a past commit, create a worktree at that commit. Claude unavailable or out of quota blocks the step. Report it and never substitute another family.

**Continuing.** `followup_task` only for a new task on a settled Pi worker. Resume interrupted or stale work in a fresh worker with consolidated scope. Interrupt a stale worker and confirm it settled before its replacement starts. Unconfirmed death or cleanup goes to the operator, not to a replacement writer.

**Retiring.** Before the final handoff, retire each owned worker you no longer need, leaves before parents. Settlement alone leaves the tab open. Report an `incomplete` retirement with its evidence path.

**Tools.** Every worker gets normal tools. A read-only brief limits changes, not tools. Workers do not inherit the lead's other extensions or environment-only credentials. Claude workers get no MCP servers, so their lookups go through CLIs in Bash. Upstream `Read`, `Grep`, `Glob`, and `Shell` map to `read`, `grep`, `find`, and `bash`, and `Task` maps to Dispatch. There is no `AskQuestion`. A worker stops and reports a genuine human question, and the lead asks the user. Keep explicit skips and saved targets on every `update_plan` update.

**Evidence.** Read a worker's transcript by its exact identity (`piSessionPath` or `transcriptPath`), never by searching unrelated sessions. `artifactPath` holds the full final text, not the transcript. A receipt's `selection` records task-start settings. Check the transcript when settings changed mid-task. When a skill allows a lead-session digest instead of a transcript, disclose that the digest cannot prove tool history. Wait for delegated exploration before touching the same files, then spot-check its claims with targeted searches instead of repeating it.

**Other runtimes.** First confirm equivalent controls for fresh contexts, exact worker and task IDs, bounded waits, continuation, interruption, retirement, separate plans, and transcripts. Report a missing control rather than skipping a phase.
