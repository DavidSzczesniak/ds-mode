# Codex persistent agents and Pi workers

## Scope and conclusion

This report checks installed `codex-cli 0.152.0` and `pi 0.84.4`, the official Codex tag `rust-v0.152.0`, current OpenAI documentation, and the official Pi tag `v0.84.4`.

**Conclusion:** Codex 0.152.0 has durable conversation threads and durable metadata around them. It does not have a documented persistent-job API that checkpoints and restores an operating-system process or an in-flight model/tool turn. `codex agents` can keep Codex work running after one TUI exits only because it uses a shared app-server daemon that still owns the live threads. It cannot make an external Pi process restartable.

For Pi workers, the smallest reliable design is a plain launcher/supervisor executable. It should write worker identity and lifecycle state itself, save Pi's session ID before launching, and restart Pi with that ID after a process or Codex restart. A Codex plugin is optional packaging, not the persistence mechanism.

## 1. What `codex agents` persists

`codex agents` itself persists nothing. Installed help describes it as "Browse all agent sessions on the shared local app-server daemon." The command starts that daemon when no remote endpoint is supplied, then its overview calls `thread/loaded/list`, not `thread/list`, so it displays threads currently loaded in that daemon process ([CLI dispatch, lines 2586-2600](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/cli/src/main.rs#L2586-L2600), [overview query, lines 102-145](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/tui/src/app/agents_overview.rs#L102-L145)). It sends new work with `turn/start` and stops work with `turn/interrupt` ([overview actions, lines 634-713](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/tui/src/app/agents_overview.rs#L634-L713)).

Two kinds of state sit behind that view:

- Durable state: thread rollout/history, thread settings snapshots, names, spawn edges, queued submissions, and goals. Stored threads appear as `notLoaded` when no process has loaded them ([app-server protocol, lines 174-200](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/app-server/README.md#L174-L200)).
- Process-local state: loaded thread objects, active turns, subagent runtimes, background terminals, hook tasks, and MCP stdio children. The daemon must remain alive for these to keep running. Graceful thread shutdown aborts tasks and terminates all unified-exec processes before flushing persistence ([session shutdown, lines 402-426](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/core/src/session/handlers.rs#L402-L426)).

A client disconnect does not immediately stop an idle loaded thread. After the last unsubscribe, app-server keeps it loaded until it has had no subscribers and no activity for 30 minutes. It then unloads it and reports `notLoaded` ([app-server protocol, lines 607-617](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/app-server/README.md#L607-L617)). Active work therefore survives a TUI exit only while the shared daemon remains alive. Crash recovery of a live turn is not documented and must be treated as unsupported.

The daemon is experimental. `start` creates a detached pidfile-managed app-server; `bootstrap` also creates an updater loop. The updater itself is not reboot-persistent ([daemon README, lines 1-15](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/app-server-daemon/README.md#L1-L15), [lines 43-70](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/app-server-daemon/README.md#L43-L70)).

## 2. Resume and queue guarantees

The key distinction is whether a mechanism restores saved history or continues a live process/turn.

| Mechanism | Durable guarantee | Live process or active-turn guarantee |
| --- | --- | --- |
| `codex resume` | Selects a recorded thread and calls app-server `thread/resume`; reconstructed history becomes the context for later turns. Installed help says an optional prompt starts work after resume. | No checkpoint/reattach guarantee for an active turn or command. It opens a new TUI/app-server client. |
| `codex exec resume` | Resolves a recorded thread, calls the same `thread/resume`, then runs the supplied non-interactive prompt ([exec path, lines 818-850](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/exec/src/lib.rs#L818-L850)). | No. It creates an in-process app-server for that invocation and exits after the new run. |
| App-server `thread/resume` | Reopens a thread ID, reconstructs persisted turn/model context, and subscribes the client. It does **not** start a turn ([protocol, lines 405-417](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/app-server/README.md#L405-L417)). A later `turn/start` appends new work. | No. `resume` loads state. It does not restore a model stream, tool future, terminal, or prior `turn/start` execution. |
| `codex queue` / `thread/queue/add` | Persists a FIFO follow-up submission with stable submission and client-message IDs. Installed `codex queue --help` exposes only thread, text, and connection/config options. The CLI sends `thread/queue/add` ([queue client, lines 28-76](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/tui/src/session_queue_commands.rs#L28-L76)). | Automatic dispatch requires a loaded thread in a running app-server. Completed or failed turns start the next item; interrupted turns pause the queue, including after resume, until `thread/queue/start` ([queue contract, lines 858-880](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/app-server/README.md#L858-L880)). |
| Multi-agent `resume_agent` | V1 reopens a previously closed agent ID from its rollout so it can accept `send_input` and `wait_agent` ([tool schema, lines 242-260](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L242-L260), [handler, lines 191-211](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/core/src/tools/handlers/multi_agents/resume_agent.rs#L191-L211)). V1 also reloads descendants whose persisted spawn edges remain open; deliberately closed descendants stay closed ([reload loop, lines 1081-1155](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/core/src/agent/control/spawn.rs#L1081-L1155)). | No automatic continuation of the old active turn. It restores model context and registers a new in-memory agent runtime. A follow-up input is still needed. |
| Parent-owned Multi-Agent V2 child reload | `thread/resume` reattaches to an already loaded child or asks its actual loaded parent to reconstruct the child from persisted history and parent-derived configuration. Direct overrides are ignored. If the parent is unavailable, the request fails and the parent must be resumed first ([protocol, lines 405-409](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/app-server/README.md#L405-L409), [owner checks, lines 295-373](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/core/src/agent/control/spawn.rs#L295-L373)). | No restored active turn. V2 root resume does not eagerly reopen its descendants; children reload through the live owner as needed ([V2 test, lines 983-1075](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/core/src/agent/control_tests.rs#L983-L1075)). |

A resumed history is also not a byte-for-byte process snapshot. The app-server schema says projected resumed `ThreadItem`s are lossy because not every interaction, including command execution detail, is persisted ([schema description, lines 22814-22822](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/app-server-protocol/schema/json/codex_app_server_protocol.schemas.json#L22814-L22822)).

## 3. Other Codex mechanisms

None of the following is a supported persistent-job mechanism:

- **Background terminals.** They are entries in an in-memory process store. Listing filters live child processes; shutdown drains the store and terminates every process ([process manager, lines 1647-1682](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/core/src/unified_exec/process_manager.rs#L1647-L1682)). There is no persisted process ID or reconnect protocol.
- **Queues.** The submission is durable, not its execution. A live app-server and loaded thread perform automatic dequeue. An interrupted queue remains paused after resume.
- **Goals.** `thread/goal/set` stores one objective, status, and accounting record ([goal protocol, lines 792-824](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/app-server/README.md#L792-L824)). Current Goal mode guidance says to continue the same CLI session and to pause before expected connectivity loss; it does not promise restart of a running turn ([OpenAI long-running work docs](https://developers.openai.com/codex/long-running-work)). Whether daemon restart automatically recreates an active goal loop is undocumented and therefore unknown.
- **Hooks.** Async hooks are tasks owned by the hook runtime. Runtime shutdown aborts them and discards late output ([shutdown test, lines 483-531](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/hooks/src/engine/command_runner_tests.rs#L483-L531)). A successful command hook may intentionally leave a detached helper, but there is no hook supervisor, durable job registry, or reconnect contract ([command runner, lines 285-331](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/hooks/src/engine/command_runner.rs#L285-L331)).
- **Plugins.** A plugin is a bundle of skills, MCP servers, apps, and hooks. It is not invoked as an independent runtime ([plugin guidance, lines 10-23](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/core/src/plugins/render_tests.rs#L10-L23)). The tagged manifest type has no process supervisor or durable-job component ([manifest, lines 8-38](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/plugin/src/manifest.rs#L8-L38)). Current docs mention scheduled-task templates only "where scheduled tasks are available" ([OpenAI plugin docs](https://developers.openai.com/codex/plugins)); at this tag app-server merely returns remote catalog summaries and has no plugin scheduling method ([protocol, lines 267-275](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/app-server/README.md#L267-L275)).
- **Scheduled tasks.** These are a supported ChatGPT web/desktop scheduler, but not a Codex CLI 0.152.0 command or plugin runtime. Official docs say the CLI has no Scheduled management interface and that local-project runs require the computer on and desktop app running. Each standalone run starts from its saved prompt; a chat task returns to saved chat context. Neither form reconnects an external Pi process or resumes its active tool call ([OpenAI scheduled-task docs](https://developers.openai.com/codex/automations)).
- **MCP servers.** An MCP service can expose deterministic launch/status/stop tools and keep its own durable database. That is the nearest official integration mechanism. Codex-managed stdio MCP children are not persistent jobs: dropping the transport terminates the child ([stdio handle, lines 475-525](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/rmcp-client/src/stdio_server_launcher.rs#L475-L525)). A separately deployed HTTP MCP service can outlive Codex, but its persistence and supervision belong to that service, not Codex.
- **Agent-role configuration.** Roles select instructions, model/reasoning defaults, nicknames, limits, and other inherited session configuration. They do not define lifecycle recovery ([config schema, lines 9-63](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/core/config.schema.json#L9-L63)). Current official subagent docs describe orchestration and custom agent configuration, not process restoration ([OpenAI subagent docs](https://developers.openai.com/codex/multi-agent)).

## 4. Is there an official Pi-supervisor extension point?

No documented Codex 0.152.0 plugin or extension point provides all of these operations as a host guarantee:

1. launch and supervise arbitrary external Pi processes;
2. durably save a Pi session ID;
3. detect Codex/app-server restart;
4. relaunch or reconnect the Pi process at its last safe boundary.

The nearest official mechanism is an MCP server whose tools implement those operations and whose own service owns durable state. A plugin can package that MCP declaration plus a skill. This does not make Codex the supervisor. A local stdio MCP process dies with its Codex transport; a durable HTTP MCP service needs an external service manager.

For this use case, a plugin is unnecessary unless discoverability or distribution matters. Codex can invoke a plain executable through its shell tool. That executable can implement the same deterministic interface without adding MCP or plugin lifecycle complexity.

The app-server protocol is useful only if the launcher also needs to drive Codex threads. It is an official client integration API for starting/resuming threads and receiving events ([official app-server docs](https://developers.openai.com/codex/app-server), [tagged protocol overview, lines 171-235](https://github.com/openai/codex/blob/rust-v0.152.0/codex-rs/app-server/README.md#L171-L235)). It is not an external-process checkpoint API.

## 5. Pi 0.84.4 resume semantics

Pi saves each session as a JSONL tree under the session directory. `pi --session <path|id>` opens a specific file or partial ID, `pi --continue` opens the most recent session for the working directory, and `pi --resume` opens a picker ([Pi session docs, lines 1-20](https://github.com/earendil-works/pi/blob/v0.84.4/packages/coding-agent/docs/sessions.md#L1-L20)). Installed help also exposes `--session-id <id>`, which opens the exact matching project session or creates it if missing; it cannot be combined with `--session`, `--continue`, or `--resume` ([CLI source, lines 309-320](https://github.com/earendil-works/pi/blob/v0.84.4/packages/coding-agent/src/main.ts#L309-L320), [lines 426-442](https://github.com/earendil-works/pi/blob/v0.84.4/packages/coding-agent/src/main.ts#L426-L442)).

On restart, Pi opens the JSONL and rebuilds the model context by walking the active branch, applying compaction, and projecting stored messages/settings ([session manager, lines 410-470](https://github.com/earendil-works/pi/blob/v0.84.4/packages/coding-agent/src/core/session-manager.ts#L410-L470), [open/continue methods, lines 1526-1567](https://github.com/earendil-works/pi/blob/v0.84.4/packages/coding-agent/src/core/session-manager.ts#L1526-L1567)). A launcher can therefore restart a worker with, for example:

```sh
pi --session-dir "$session_dir" --session-id "$session_id" -p \
  "Continue the assigned task. Reconcile the current repository state before acting."
```

The launcher should save `cwd`, `session_dir`, and `session_id` before spawning. `--session-id` is preferable when the launcher owns a unique exact ID and project directory. `--session` is suitable when it owns the resolved file path or ID and wants failure rather than creation.

Pi cannot resume in the middle of a tool call. It persists user, assistant, and tool-result messages on each `message_end` ([agent session, lines 667-723](https://github.com/earendil-works/pi/blob/v0.84.4/packages/coding-agent/src/core/agent-session.ts#L667-L723)). Tool execution is an awaited in-process function; only after it returns does Pi create and emit the `toolResult` message ([agent loop, lines 668-705](https://github.com/earendil-works/pi/blob/v0.84.4/packages/agent/src/agent-loop.ts#L668-L705), [lines 765-794](https://github.com/earendil-works/pi/blob/v0.84.4/packages/agent/src/agent-loop.ts#L765-L794)). If the process dies after the assistant tool call is saved but before its result is saved, Pi has conversation evidence of the requested call, not a resumable call stack or child-process handle. Pi's continuation API explicitly rejects context ending in an assistant message ([agent loop, lines 57-77](https://github.com/earendil-works/pi/blob/v0.84.4/packages/agent/src/agent-loop.ts#L57-L77)). Whether a particular provider/startup path repairs every orphaned tool call is undocumented here, so treat it as unknown. The supervisor must restart at a safe application-level boundary and reconcile effects idempotently.

## 6. Smallest recommended implementation

Use one dumb executable, invoked by Codex, as the durable owner. Do not ask either model to maintain an operational log.

Persist one atomic state record per worker, preferably JSON or SQLite:

```json
{
  "worker_id": "review-01",
  "cwd": "/absolute/project/path",
  "session_dir": "/absolute/supervisor/sessions",
  "pi_session_id": "launcher-generated-uuid",
  "desired_state": "running",
  "generation": 3,
  "pid": 12345,
  "pid_start_time": "os-specific-identity",
  "last_exit": { "code": 1, "at": "..." }
}
```

The lifecycle should be mechanical:

1. Under a per-worker lock, write the generated Pi session ID and desired state before spawn.
2. Spawn Pi in its own process group. Record PID plus process start time so PID reuse cannot impersonate the worker.
3. On `status` or supervisor startup, inspect the OS process. If `desired_state` is `running` and no matching process exists, run Pi again with the saved session ID and a fixed continuation prompt.
4. Write exit status from the wait/reap path. Never infer liveness from the Pi transcript.
5. Make worker operations idempotent: `start` converges to one process, `stop` converges to none, and `reconcile` is safe after crashes.
6. Require worker tasks and tools to leave rerunnable checkpoints in their real artifacts. A resumed Pi process must inspect repository/output state before repeating work because a killed tool may have produced side effects without a saved `toolResult`.

Run this executable under the operating system's service manager only if workers must survive logout or reboot. Add an HTTP MCP wrapper later only if Codex needs typed `start`, `status`, `logs`, and `stop` tools. A Codex plugin can then package that MCP endpoint and usage skill, but it should not own the worker state.

## Evidence limits

- Installed commands checked: `codex --version`, `codex --help`, `codex agents --help`, `codex resume --help`, `codex exec resume --help`, `codex queue --help`, `codex plugin --help`, `codex app-server --help`, `codex app-server daemon --help`, `codex features list`, `pi --version`, and `pi --help`.
- Installed versions reported `codex-cli 0.152.0` and Pi `0.84.4`.
- No live app-server daemon was present during inspection; `codex app-server daemon version` failed to connect to `~/.codex/app-server-control/app-server-control.sock`. No claims above depend on observing an untagged daemon.
- Abrupt-crash handling, automatic goal continuation after daemon restart, orphan Pi tool-call repair, and reconnection to an already running external Pi TUI/RPC process have no cited supported contract. They remain unknown.
