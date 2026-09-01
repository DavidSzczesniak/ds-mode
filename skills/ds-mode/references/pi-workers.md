# Pi workers

Codex is the lead. It owns design, the visible `update_plan`, worker briefs, diff review, and final proof. A Pi worker owns only the task and paths in its brief.

## Write the brief

Store each brief in a durable file. Include every field below.

- **Role.** Explore, Implement, Review, or Judgment.
- **Task contract.** The requested outcome and accepted decisions.
- **Scope.** Files, symbols, questions, and exclusions.
- **Writable paths.** Exact paths, or `none` for read-only work.
- **Checkout.** The checkout or worktree the worker may use.
- **Verification.** The commands and artifacts the worker must inspect.
- **Model profile.** A role from [`pi-profiles.md`](pi-profiles.md), plus any override.
- **Edit permission.** Read-only or write.
- **Report shape.** Result, evidence, changed paths, checks, and open risks.

Workers report results. They do not mutate the lead's `update_plan`.

## Choose the checkout

One writer may use a clean or dedicated active checkout. The lead may inspect and plan while the writer runs, but it does not mutate that checkout.

Give parallel writers, competing experiments, and work with overlapping tracked files separate worktrees and disjoint ownership. Untracked files alone do not make a checkout dirty. Protect every untracked file from deletion, overwrite, and incidental adoption.

## Launch and identify the session

Launch a named persistent session. Do not pass `--no-session`.

Use absolute paths for the checkout, brief, output, and PID file. Start Pi from the checkout named in the brief.

```bash
checkout="<absolute-checkout>"
brief_path="<absolute-brief-path>"
result_jsonl="<absolute-result-jsonl>"
stderr_path="<absolute-stderr-path>"
pid_path="<absolute-pid-path>"
(
  cd "$checkout"
  exec pi --mode json \
    --name "<worker-name>" \
    --model openai-codex/gpt-5.6-sol \
    --thinking <medium|high|xhigh> \
    @"$brief_path"
) >"$result_jsonl" 2>"$stderr_path" &
worker_pid=$!
printf '%s\n' "$worker_pid" >"$pid_path"
```

The first JSON line is the session header. Read its `id` and add that session ID to the lead's `update_plan` item. Persist the brief path, result path, PID path, checkout, and worker name beside it. The PID owns current process control. The Pi session ID owns conversation recovery.

Inside Pi, `PI_SESSION_ID` identifies the session and `PI_SESSION_FILE` identifies its JSONL transcript. Decision trails remain separate from this process metadata.

## Inspect and recover

Read the result JSONL for progress and terminal output. Before stopping a background process, read its PID file and verify its current command and checkout with `ps`. Send `TERM` only to that verified PID. A missing or reused PID means the process state is unknown, not stopped. Do not use a Pi session ID as a process handle.

Resume an exact session from its assigned checkout:

```bash
(
  cd "<absolute-checkout>"
  exec pi --session <session-id>
)
```

Pi scopes normal session lookup to the working directory. Resuming from another checkout can offer a fork instead of continuing the same session. Use `pi -r` from the assigned checkout for manual selection. Recovery uses the checkout, session ID, durable brief, result JSONL, and checkout state. Agent prose is not a liveness monitor.

## Accept the result

Inspect the worker's diff and evidence yourself. Run the proof that owns the accepted outcome. Treat a worker summary as a pointer, not proof.
