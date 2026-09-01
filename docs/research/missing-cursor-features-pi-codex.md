# Missing Cursor mechanisms in a Pi/Codex adaptation

Research date: 2026-09-01. Versions examined: Pi 0.84.4 and Codex CLI 0.152.0.

## Executive summary

pstack assumes two different systems and often talks about them as one:

1. Ordinary delegation: start a focused agent, optionally choose a model and tools, run several at once, and return summaries to the parent.
2. Durable project orchestration: keep a multi-day queue, wake on events, survive UI and process restarts, recover worker state, isolate writers, and deliver completions through an inbox.

Pi 0.84.4 can replace the first system with its official subagent example. That example is a synchronous tool implemented by spawning `pi --mode json -p --no-session`. It can run one task, a bounded parallel group, or a sequential chain. It cannot detach a task from the tool call, assign a resumable child ID, persist a child session, recover a child after a process crash, accept nested delegation, or maintain a completion inbox. Its use of `--no-session`, an awaited child process, and abort-to-kill behavior make those omissions explicit, not edge cases. [Pi subagent README, lines 1-12 and 93-117](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/README.md#L1-L12) [Pi subagent source, lines 278-347 and 483-684](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/index.ts#L278-L347)

Pi's extension, SDK, RPC, and session APIs are enough to build missing machinery. They provide custom tools, lifecycle events, persistent session entries, persisted sessions, model/tool selection, process control, event streaming, and session resume. They do not provide a durable job queue or supervisor. A credible durable queue therefore needs new infrastructure outside an agent session. [Pi extensions, lines 1-28 and 1430-1468](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/extensions.md#L1-L28) [Pi SDK, lines 1-25, 53-165, and 780-858](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/sdk.md#L1-L25) [Pi RPC, lines 1-40 and 603-671](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/rpc.md#L1-L40)

Codex CLI 0.152.0 is the better base for ordinary pstack delegation. Current official Codex has built-in subagents, custom roles, per-agent model/reasoning/sandbox configuration, parallel agent threads, steering, waiting, closing, and thread inspection. The installed source also has persisted parent/child thread edges and app-server APIs for starting, listing, reading, resuming, and forking threads. [OpenAI subagent docs, lines 1-30, 192-271, and 275-380](https://learn.chatgpt.com/docs/agent-configuration/subagents) [installed Codex `multi_agents_spec.rs`, lines 65-178 and 242-310](file:///tmp/openai-codex/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L65-L178) [installed app-server README, lines 66-83 and 171-226](file:///tmp/openai-codex/codex-rs/app-server/README.md#L66-L83)

Codex is not a complete durable pstack runtime. Its persisted conversation threads and experimental per-thread FIFO queue are useful building blocks, but official sources do not promise that an active local turn or child agent continues through an app-server/process/host crash. The internal inter-agent mailbox is in memory. The daemon is detached but explicitly experimental and its updater is not reboot-persistent. The app-server's `thread/queue/*` methods queue user turns on one thread, not independent project units with leases, retries, worktree ownership, verification state, or a result inbox. [installed app-server README, lines 200-219 and 860-884](file:///tmp/openai-codex/codex-rs/app-server/README.md#L200-L219) [installed input queue, lines 78-95](file:///tmp/openai-codex/codex-rs/core/src/session/input_queue.rs#L78-L95) [installed daemon README, lines 1-15, 34-70, and 84-113](file:///tmp/openai-codex/codex-rs/app-server-daemon/README.md#L1-L15)

The smallest sound adaptation is deliberately split:

- Use Pi's example or Codex's built-in agents for bounded delegation inside one task.
- Omit Cursor-specific cloud handoff, `/loop`, agent-resume, and implicit durable-background claims unless the chosen host really supplies them.
- Do not port pstack's `Orchestrate` or autopilot playbooks as prompt-only behavior. Either omit them or back them with an external durable queue and supervisor.
- If a small adapter may depend on Codex 0.152.0, choose Codex over Pi. If portability and inspectable code matter more than built-in agent UX, use a dumb Pi worker queue with files and OS processes.

## Scope and terminology

“Product contract” below means behavior stated by Cursor, Pi, or OpenAI documentation or implemented in the examined version's first-party source. “pstack convention” means a workflow instruction in `/tmp/cursor-plugins-pstack/pstack`; it may rely on a product feature but is not itself a Cursor guarantee.

“Durable” has three levels:

- Turn-durable: work continues while the parent agent takes later turns.
- Process-durable: work and queue state survive parent/client or agent-process restart.
- Host-durable: a supervisor restarts work after logout, reboot, or machine failure.

A saved transcript is not a durable running job. A resumable conversation is not a queue. This distinction is the main adaptation risk.

## Feature matrix

| Mechanism | Cursor product contract | pstack use | Pi 0.84.4 replacement | Codex CLI 0.152.0 replacement | Adaptation verdict |
|---|---|---|---|---|---|
| Foreground subagent | Separate context, parent blocks and receives result. [Cursor subagents, lines 23-37](https://cursor.com/docs/subagents) | Focused explorer, implementer, reviewer | Official subagent example, one awaited subprocess | Built-in subagent thread | Substitute |
| Background subagent | Returns immediately; background state is written under `~/.cursor/subagents/`. [Cursor subagents, lines 29-37 and 447-453](https://cursor.com/docs/subagents) | Default `run_in_background: true` | Not supplied by example | Built-in background-agent UX and live child threads; no documented local crash continuation | Substitute only for live-session background work |
| Local/cloud choice | Local worktree or dedicated cloud VM/clone; `/in-cloud` hands the next task to cloud. [Cursor subagents, lines 246-272](https://cursor.com/docs/subagents) | `environment: "cloud"` by default for workers, local for machine-only resources. [pstack `swarm`, lines 27-34](file:///tmp/cursor-plugins-pstack/pstack/skills/swarm/SKILL.md#L27-L34) | Local process only unless adapter adds remote execution | Local agents plus separate Codex Cloud task API; no first-party bridge from a local child spawn to Cloud documented | Omit seamless handoff; expose separate local/cloud commands if needed |
| Parallel calls | Multiple Task calls in one message run simultaneously. [Cursor subagents, lines 236-245](https://cursor.com/docs/subagents) | Swarms, panels, arenas | Parallel array, max 8 tasks and 4 concurrent | Built-in parallel agents; configurable cap | Substitute |
| Nested agents | Main and direct children can spawn; grandchildren cannot spawn further. [Cursor subagents, lines 442-445](https://cursor.com/docs/subagents) | Orchestrate says nesting works to depth 3. [pstack `orchestrate`, lines 15-21](file:///tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/orchestrate.md#L15-L21) | Example children do not receive the subagent extension and run with `--no-session`; no nesting feature | Supported with a configurable depth; installed default is one spawned level | Substitute only after reconciling depth wording; do not claim pstack's depth 3 by default |
| Child model/tool selection | Custom agent fields select model, read-only mode, and background mode; child otherwise inherits. [Cursor subagents, lines 121-154](https://cursor.com/docs/subagents) | Role-specific models and agent modes | Agent frontmatter selects model/tools; omission inherits model/thinking | Custom TOML roles can set model, effort, sandbox, MCP, and skills | Substitute |
| Child resume/poll | Execution returns agent ID; resume keeps context. Parent can read background output files. [Cursor subagents, lines 274-284 and 447-453](https://cursor.com/docs/subagents) | Resume with standing orders; read-only liveness probes | No ID, session, resume, or poll operation in example | Agent IDs, thread inspection, steering, waiting and close; persisted threads can be resumed through app-server/CLI | Substitute conversation resume; do not equate it with crash-safe execution |
| Result delivery | Child final message returns to parent; failures return status. [Cursor subagents, lines 23-27 and 451-453](https://cursor.com/docs/subagents) | Completion pointers enter an orchestration inbox | Awaited tool result returns final text/details | Parent receives completion notifications and consolidated response | Substitute for one live parent; new inbox needed for durable project queues |
| Worktree/branch isolation | Shared checkout by default; requested isolation creates per-child branch/worktree or VM clone. [Cursor subagents, lines 246-256](https://cursor.com/docs/subagents) | One writer per worktree/branch | `cwd` only; adapter must create worktrees | Subagents share the parent workspace unless the caller supplies separate cwd/environment; desktop worktrees are a separate product flow | New wrapper around `git worktree` for CLI adapters |
| Todo list | Official pages examined do not specify the model-facing todo tool contract | Mandatory visible checklist; skipped steps remain listed | Official todo example persists snapshots in tool-result details and reconstructs current-branch state | `update_plan` is a TODO/checklist tool; plan-mode is separate | Substitute presentation, not orchestration |
| Plan mode/approval gate | Plan mode researches, asks questions, saves a reviewable plan, and waits for “build”. [Cursor plan mode, lines 1-15](https://cursor.com/docs/agent/plan-mode) | “state then wait” before autopilots; explicit approval for selected changes | Official plan extension disables write tools, filters bash, prompts to execute, and persists mode state | Plan collaboration mode plus sandbox/approval policies; `update_plan` is forbidden in Plan mode | Substitute with host-native mode and explicit gate |
| AskQuestion | Official Cursor pages examined do not specify its schema or persistence | Structured choice tool and parked human gates | `ctx.ui.select/confirm/input/editor`; RPC extension UI protocol | `request_user_input`, root thread only; approval requests through app-server | Substitute questions; persist unanswered gates separately |
| `/loop` / wakeups | Cloud subscriptions support repo/CI/Slack/timer events; timers include recurring `/loop`. [Cursor cloud capabilities, lines 117-134](https://cursor.com/docs/cloud-agent/capabilities) | Event wake plus heartbeat and 30-minute audit ticks | No scheduler primitive; timers/file watchers in an extension live only with the process | Sleep tool and long-running goals exist; desktop scheduled tasks and app-server queues are separate features | New scheduler/supervisor for unattended local work |
| Cloud persistence | Cloud agents run in independent VMs, do not need the local machine online, use separate branches, and support many parallel runs. [Cursor cloud agents, lines 3-13 and 43-59](https://cursor.com/docs/cloud-agent) | Workers survive Cursor restart; local workers do not. [pstack `orchestrate`, lines 95-104](file:///tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/orchestrate.md#L95-L104) | None | Codex Cloud tasks have submit/status/list/apply CLI operations, but are a separate experimental surface | Separate product integration, not a local subagent emulation |
| Durable project queue | Not specified as a generic Cursor Task contract | `units.tsv`, inbox, ledger, frontier, retries, gates, status | None built in | Experimental thread FIFO queue only | New infrastructure |

## Cursor contracts versus pstack conventions

### Cursor Task and subagents

Cursor documents foreground and background subagents, isolated context, custom agent prompts/tools/models, explicit or automatic delegation, parallel calls, resumable agent IDs, and result/error return to the parent. Local children share the checkout unless isolation is requested. Isolated children get a branch and either a local worktree or a cloud VM clone. Cloud children continue while the parent remains usable. [Cursor subagents, lines 1-37, 121-174, and 206-284](https://cursor.com/docs/subagents)

Cursor's current nesting contract permits two spawned levels after the root: root to child, child to grandchild, then stop. The pstack text says “nesting works to depth 3.” That phrase is a pstack convention and is ambiguous about whether the root counts as a level. An adaptation should state the actual host limit rather than copy the phrase. [Cursor subagents, lines 442-445](https://cursor.com/docs/subagents) [pstack `orchestrate`, lines 17-20](file:///tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/orchestrate.md#L17-L20)

The current Cursor page defines frontmatter `is_background`; the pstack skills spell a Task-call argument `run_in_background: true`. The official page examined does not publish the complete Task tool JSON schema, so exact compatibility between those spellings is not an official contract established by these sources. pstack nevertheless requires background Task calls in `poteto-mode`, Arena, and Swarm. [Cursor subagents, lines 121-130](https://cursor.com/docs/subagents) [pstack `poteto-mode`, lines 87-93](file:///tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/SKILL.md#L87-L93) [pstack `arena`, lines 27-41](file:///tmp/cursor-plugins-pstack/pstack/skills/arena/SKILL.md#L27-L41)

Cursor says background subagents write state while they run and that the parent can read `~/.cursor/subagents/`. It does not say in the examined official page that local background execution survives a Cursor process restart or host reboot. pstack itself explicitly assumes the opposite: after Cursor restart local agents are dead and cloud work is not. [Cursor subagents, lines 274-284 and 447-449](https://cursor.com/docs/subagents) [pstack `orchestrate`, lines 95-104](file:///tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/orchestrate.md#L95-L104)

### Cloud agents, wakeups, and persistence

Cloud Agents are the durable execution service in Cursor's product, not a property of every Task call. Cursor says they run in isolated cloud VMs, can run in parallel without the laptop connected, clone and push a separate branch, and are managed by Cursor. Cloud subscriptions can wait for PR activity, CI, Slack replies, webhooks, or timers. Recurring timers include `/loop`. Automations create background cloud-agent runs from schedules or events and can keep memories outside the run filesystem. [Cursor cloud agents, lines 3-13, 43-59](https://cursor.com/docs/cloud-agent) [Cursor cloud capabilities, lines 117-144](https://cursor.com/docs/cloud-agent/capabilities) [Cursor automations, lines 1-17, 45-49, and 181-187](https://cursor.com/docs/cloud-agent/automations)

pstack adds policy on top: completion notifications become queue pointers rather than interrupts; the coordinator drains in batches; one writer owns each durable file; every resume repeats standing orders; a verifier ledger is keyed by PR and head SHA; and retries are classified and bounded. None of those is a generic Cursor Task guarantee. They are pstack's own orchestration protocol. [pstack `orchestrate`, lines 7-13, 23-34, 70-82, and 89-104](file:///tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/orchestrate.md#L7-L13)

### Todo, plan, questions, and approval

Cursor Plan Mode is an approval workflow: research, clarification, a reviewable/editable plan, then an explicit build action. Plans save to the home directory by default and can be moved into the workspace. [Cursor plan mode, lines 1-15](https://cursor.com/docs/agent/plan-mode)

pstack's mandatory todo lists are different. They expose playbook progress and preserve skipped steps. The official Cursor pages examined do not define the todo tool's data model, persistence, or relation to Plan Mode. Treat “open a todolist” as a pstack convention that needs a host-specific checklist, not as a portable Cursor API contract. [pstack `poteto-mode`, lines 108-116](file:///tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/SKILL.md#L108-L116)

Likewise, pstack's use of `AskQuestion` and its rule to park unanswered gates in `gates.md` is workflow policy. The examined Cursor docs do not specify an `AskQuestion` schema or guarantee that an open question survives unrelated completion notifications. The durable `gates.md` entry is therefore the meaningful portable behavior. [pstack `poteto-mode`, lines 15-24](file:///tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/SKILL.md#L15-L24) [pstack `orchestrate`, lines 25-33](file:///tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/orchestrate.md#L25-L33)

## Pi 0.84.4

### What the official subagent example actually provides

The example registers one `subagent` tool with three mutually exclusive modes:

- single: one agent and task;
- parallel: up to eight tasks, with four running concurrently;
- chain: sequential tasks with `{previous}` text substitution.

Each child is a separate `pi` process. Agent files can choose model and tools; otherwise the child inherits the dispatching model and thinking level. The tool streams child messages and tool results, aggregates usage, propagates abort by terminating the child, and returns final output in the parent tool result. [Pi subagent README, lines 1-12, 93-117, and 128-176](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/README.md#L1-L12) [Pi subagent source, lines 278-431 and 445-468](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/index.ts#L278-L431)

The `cwd` field points a child at a directory. The example does not create a branch or worktree. Giving parallel writers the same cwd therefore creates the same shared-checkout hazard Cursor warns about. [Pi subagent source, lines 445-468 and 640-662](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/index.ts#L445-L468)

### What it does not provide

The omissions are exact:

- No durability. Every child command includes `--no-session`, so there is no persisted child conversation to reopen. [Pi subagent source, lines 278-307](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/index.ts#L278-L307)
- No detached execution. `runSingleAgent` awaits the child `close` event, and parallel mode awaits all bounded workers before returning the tool result. [Pi subagent source, lines 346-431 and 620-684](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/index.ts#L346-L431)
- No resume ID. The result contains agent name, messages, exit status, usage, and model, but no persistent child-session handle. [Pi subagent source, lines 150-178 and 312-330](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/index.ts#L150-L178)
- No polling API. Progress exists only through the active tool call's `onUpdate` callback.
- No process-crash recovery. Parent abort sends `SIGTERM`, then `SIGKILL`; there is no reattachment or supervisor. A parent crash also loses the in-memory process handle. [Pi subagent source, lines 404-426](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/subagent/index.ts#L404-L426)
- No persistent queue or result inbox. Results live in the parent tool result details after completion.
- No nested-agent contract. Child invocations load normal resources, but the sample agent frontmatter controls tools and does not explicitly enable a subagent tool. The example documents no child-to-grandchild behavior.
- No automatic worktree or branch isolation. `cwd` is caller-supplied.

These are not “probably unsupported.” They follow directly from this implementation. Pi's broader APIs can be used to build them, but the example does not.

### Todo example

The todo example keeps an in-memory list, writes a complete snapshot into each `todo` tool result's `details`, and reconstructs state by replaying matching tool results on the current session branch. It replays on `session_start` and tree navigation. That gives branch-correct checklist persistence. It is not a scheduler and it never starts work. [Pi todo example, lines 1-11 and 106-143](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/todo.ts#L1-L11)

This is a good replacement for pstack's visible playbook checklist. It is a bad place for a project queue because session branching deliberately changes the reconstructed state, queue operations are coupled to model tool results, and no worker lease or external completion can update it safely.

### Plan-mode example

The plan-mode example is a TUI workflow, not a hardened security boundary. It snapshots active tools, disables built-in `edit` and `write`, adds read tools and `questionnaire`, blocks bash commands outside a regex allowlist, extracts numbered items from a `Plan:` section, prompts the user to execute/refine/stay, restores tools for execution, tracks `[DONE:n]`, and appends custom session entries to restore mode and progress on resume. [Pi plan README, lines 1-58](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/plan-mode/README.md#L1-L58) [Pi plan source, lines 20-138, 164-239, and 248-383](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/plan-mode/index.ts#L20-L138)

The regex filter is illustrative. For example, it checks whole command strings against destructive and safe patterns; shell composition and alternate interpreters make regex command allowlists unsuitable as the only safety boundary. Pi's own extension documentation says extensions run with full system permissions. A Pi adaptation should use OS/container sandboxing for untrusted autonomous work and use the plan extension only for UX and accidental-write prevention. [Pi plan utils, lines 6-100](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions/plan-mode/utils.ts#L6-L100) [Pi extensions, lines 78-90](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/extensions.md#L78-L90)

### Official building blocks for an adapter

Pi supplies these useful parts:

- Extensions can register tools and commands, intercept lifecycle/tool events, ask through `ctx.ui`, append session-persistent custom entries, and start resources on `session_start` with cleanup on `session_shutdown`. [Pi extensions, lines 1-28, 174-195, and 295-374](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/extensions.md#L1-L28)
- `pi.appendEntry()` persists extension data outside model context. Labels and session files survive restart. [Pi extensions, lines 1430-1490](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/extensions.md#L1430-L1490)
- SDK `AgentSession` supports prompt, steer, follow-up, events, abort, model changes, and persisted `SessionManager` instances. `AgentSessionRuntime` supports new, resume/switch, fork, and import flows. [Pi SDK, lines 53-165 and 780-858](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/sdk.md#L53-L165)
- RPC provides correlated JSONL commands, asynchronous events, accepted/queued prompt responses, state/message reads, model changes, and session switching. Its steering and follow-up queues are in-session message queues, not persistent job queues. [Pi RPC, lines 14-95, 134-214, and 603-671](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/rpc.md#L14-L95)
- Extension UI maps select/confirm/input/editor into RPC request-response messages. That can replace `AskQuestion` in an interactive client. [Pi RPC, lines 1056-1193](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/rpc.md#L1056-L1193)

None of those APIs claims to supervise detached workers after the Pi process dies. `session_shutdown` is graceful cleanup, not crash recovery. A timer or child process started by an extension remains process-scoped. [Pi extensions, lines 174-195 and 398-411](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/extensions.md#L174-L195)

## Codex CLI 0.152.0

### Current official multi-agent contract

Official OpenAI docs say current local Codex releases enable subagent workflows by default. Direct requests or project/skill instructions can spawn agents. The CLI exposes `/agent` to inspect and switch among active threads. Codex orchestrates spawning, follow-up routing, waits, closes, and final consolidation. [OpenAI subagent docs, lines 17-68 and 192-271](https://learn.chatgpt.com/docs/agent-configuration/subagents)

Built-in roles are `default`, `worker`, and `explorer`. User and project roles are standalone TOML files under `~/.codex/agents/` and `.codex/agents/`. They can override model, reasoning effort, sandbox, MCP servers, and skill configuration. Missing settings inherit from the parent. [OpenAI subagent docs, lines 328-380](https://learn.chatgpt.com/docs/agent-configuration/subagents)

Subagents inherit the parent sandbox policy. Interactive CLI approval requests can surface from an inactive child thread. In non-interactive execution, a new approval that cannot be shown fails and is reported to the parent. [OpenAI subagent docs, lines 275-326](https://learn.chatgpt.com/docs/agent-configuration/subagents)

The docs intentionally leave the default parallel limit unspecified. The installed 0.152.0 source sets the legacy default spawned-agent cap to six, the V2 per-session total to four including the primary, and default nesting depth to one. V2 therefore has three child slots by default. Configuration exposes `agents.max_concurrent_threads_per_session`; the official docs advise treating an unset value as implementation-chosen. [installed config, lines 228-242 and 1558-1571](file:///tmp/openai-codex/codex-rs/core/src/config/mod.rs#L228-L242) [OpenAI subagent docs, lines 365-380](https://learn.chatgpt.com/docs/agent-configuration/subagents)

The installed tool protocol includes:

- `spawn_agent`, returning an agent ID and optional nickname;
- `send_input`, with queue or interrupt behavior;
- `resume_agent` for a previously closed child;
- `wait_agent`, returning final status/notification behavior;
- `list_agents` and `close_agent`;
- model and reasoning overrides where the active multi-agent version exposes them.

[installed multi-agent specification, lines 65-178, 242-318](file:///tmp/openai-codex/codex-rs/core/src/tools/handlers/multi_agents_spec.rs#L65-L178)

The source persists spawned-thread parent/child edges after creating a child and emits child-created notifications. That is stronger than Pi's sample process wrapper. [installed spawn implementation, lines 584-622 and 735-780](file:///tmp/openai-codex/codex-rs/core/src/agent/control/spawn.rs#L584-L622)

### Persistence, resume, and result delivery

Codex app-server models durable conversations as threads containing turns and items. It can start, resume, fork, list, read, page, archive, and delete threads. Subagent entries expose parent IDs, and experimental descendant filters use persisted spawn-edge state. [installed app-server README, lines 66-83, 171-190, and 405-540](file:///tmp/openai-codex/codex-rs/app-server/README.md#L66-L83)

This gives an adapter stable thread IDs and durable history. It does not establish active-turn crash recovery. Official docs explain how to resume stored history, not how an interrupted process continues executing the same turn after restart. The app-server daemon's `restart` explicitly stops and starts the server. Its lifecycle contract is experimental, and its updater loop does not survive reboot. [installed app-server README, lines 405-417](file:///tmp/openai-codex/codex-rs/app-server/README.md#L405-L417) [installed daemon README, lines 1-15 and 58-70](file:///tmp/openai-codex/codex-rs/app-server-daemon/README.md#L1-L15)

Result delivery is good while the live session tree exists. Legacy completion watchers notify the parent, V2 has mailbox/final-status notifications, and app-server emits durable collab tool items and subagent activity. But the input mailbox is an in-memory `VecDeque`, so it is not a durable result inbox. [installed agent control, lines 570-589](file:///tmp/openai-codex/codex-rs/core/src/agent/control.rs#L570-L589) [installed input queue, lines 78-95 and 122-152](file:///tmp/openai-codex/codex-rs/core/src/session/input_queue.rs#L78-L95) [installed app-server README, lines 1789-1800](file:///tmp/openai-codex/codex-rs/app-server/README.md#L1789-L1800)

### Background and long-running work

OpenAI's long-running-work contract centers on persisted goals, pause/resume controls, and worktrees for parallel chats. It warns against concurrent writers to the same source. It is a user workflow, not a promise that every local process survives failure. [OpenAI long-running work, lines 1-24, 59-108, and 155-170](https://learn.chatgpt.com/docs/long-running-work)

Codex desktop worktrees provide one checkout per chat, detached HEAD by default, handoff between local and worktree, background use, persistent association between chat and worktree, and snapshots before managed worktree deletion. These are desktop-app behaviors. The CLI's ordinary `spawn_agent` contract does not say it creates a worktree per child. A CLI adapter must create and assign worktrees itself. [OpenAI worktree docs, lines 1-16, 32-59, 114-144, and 184-225](https://learn.chatgpt.com/docs/environments/git-worktrees)

Codex Cloud exposes long-running remote tasks through separate cloud APIs and the installed CLI has `cloud exec`, `status`, `list`, `diff`, and `apply`. The official sources examined do not expose Codex Cloud as an `environment` option on local `spawn_agent`. A pstack adapter should not pretend local and cloud children are interchangeable.

### Plan, todo, questions, approvals, SDK, and app-server

Codex's `update_plan` tool is explicitly a TODO/checklist tool and is rejected in Plan mode. The installed plan tool accepts steps with status; Plan mode is represented separately through collaboration mode and plan items. [installed plan handler, lines 50-108](file:///tmp/openai-codex/codex-rs/core/src/tools/handlers/plan.rs#L50-L108) [installed plan schema, lines 7-53](file:///tmp/openai-codex/codex-rs/core/src/tools/handlers/plan_spec.rs#L7-L53)

`request_user_input` is available only to the root thread in 0.152.0. This matches pstack's desire to centralize human gates, but unanswered gates still need external persistence for project orchestration. [installed request-user-input handler, lines 62-91](file:///tmp/openai-codex/codex-rs/core/src/tools/handlers/request_user_input.rs#L62-L91)

Codex separates sandbox policy from approval policy. Common local modes are read-only, workspace-write, and full access; `on-request` pauses at a boundary while `never` does not ask. Auto-review can review eligible requests without removing the sandbox boundary. [OpenAI sandbox docs, lines 1-40 and 212-267](https://learn.chatgpt.com/docs/sandboxing)

The TypeScript SDK starts, continues, and resumes local threads. The Python SDK controls app-server and exposes the same sandbox presets. For a custom coordinator, app-server is more capable than the high-level SDK because it exposes thread status/history, child relationships, approvals, event streams, and experimental queues. [OpenAI Codex SDK, lines 1-69 and 73-147](https://learn.chatgpt.com/docs/codex-sdk) [installed app-server README, lines 20-83 and 171-226](file:///tmp/openai-codex/codex-rs/app-server/README.md#L20-L83)

App-server 0.152.0 has an experimental persistent FIFO per thread. `thread/queue/add` stores a user turn, up to 100 messages, and starts the next when the thread becomes idle. This is useful for queued follow-ups. It is not pstack's unit queue because it has no unit dependency graph, worker lease, assigned branch/worktree, verification ledger, retry class, or durable completion inbox. [installed app-server README, lines 200-206 and 860-884](file:///tmp/openai-codex/codex-rs/app-server/README.md#L200-L206)

### Is Codex the better base?

Yes, for a small adapter that implements ordinary pstack delegation. Codex already owns agent identity, roles, parallelism limits, child steering/waiting, parent-child history, session resume, approvals, and thread inspection. Recreating those on Pi is most of the adapter.

No, if “small adapter” includes pstack's multi-day `Orchestrate` semantics. Codex reduces the worker-control work, but an external coordinator still needs durable units, leases, inbox entries, retries, gates, and worktree ownership. Depending on experimental `thread/queue/*`, Multi-Agent V2 details, or daemon lifecycle also pins the adapter tightly to 0.152.0.

## Durable queue design analysis

### Required invariants

A project-scale queue needs contracts that neither Pi's example nor Codex's child mailbox supplies:

1. A stable unit ID and immutable brief revision.
2. Durable state transitions such as `queued`, `leased`, `running`, `reported`, `verified`, `landed`, `failed`, and `abandoned`.
3. One active lease per unit with owner, attempt, heartbeat, and expiry.
4. A dedicated checkout/branch per writing attempt.
5. Atomic result publication before a worker is considered complete.
6. At-least-once dispatch with idempotent reconciliation. Exactly-once execution is not credible across process crashes.
7. Durable human gates independent of chat UI.
8. A completion inbox keyed by event ID so draining is repeatable and deduplicated.
9. Recovery that distinguishes a dead process, a live remote task, a finished branch with a missing report, and a stale late result.
10. A supervisor outside the parent agent process.

These requirements mirror pstack's own store, inbox, ledger, frontier, and restart rules. [pstack `orchestrate`, lines 23-34, 70-104](file:///tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/orchestrate.md#L23-L34)

### Why session persistence is insufficient

Pi custom entries and Codex rollout items are appendable durable history. Both are useful audit logs. Neither alone coordinates concurrent workers:

- A chat branch can reinterpret Pi todo state.
- A parent can be compacted, switched, or deleted while work remains.
- Child completion may happen when no parent turn is active.
- A process can die between committing code and recording completion.
- An approval prompt can remain unanswered while other completions arrive.

The queue must be authoritative outside conversational history. Chat entries may mirror it for UI, but workers and recovery logic must read the queue store directly.

### Deliberately dumb local implementation

The smallest credible local design needs no database server:

```text
.ds-orch/<project>/
  units/<unit-id>.json
  leases/<unit-id>.json
  inbox/<event-id>.json
  results/<unit-id>/<attempt>.json
  logs/<unit-id>/<attempt>.jsonl
  gates/<gate-id>.json
  worktrees/<unit-id>-<attempt>/
```

A single supervisor process owns mutations. It writes a temporary file, `fsync`s it, renames it atomically, then `fsync`s the directory. A lock file prevents two supervisors. Workers never update unit records. They write logs and one final result file, then notify the supervisor through a pipe/socket or let the supervisor discover the result on its next scan.

Dispatch steps:

1. Supervisor claims a queued unit by writing a lease.
2. It creates a fresh branch/worktree.
3. It starts `pi --mode rpc` with a persistent session or `codex exec`/app-server thread in that cwd.
4. It records PID, process start time, host, thread/session ID, and attempt.
5. Worker writes a final structured report and exits.
6. Supervisor checks the process, report, git head, and requested verification receipts.
7. Supervisor atomically appends an inbox event and transitions the unit.
8. On restart, supervisor scans every lease. Live matching PIDs remain running. Dead leases with a final report reconcile. Dead leases without one expire and retry according to policy.

For host-durability, run the supervisor under systemd/launchd. Without that, call the design process-durable only. For remote tasks, store provider task IDs and poll the provider; never use a local PID as remote liveness.

This implementation is intentionally dumb. It omits nested coordinators, automatic merging, dynamic dependency graphs, web dashboards, and exactly-once claims. It is enough to run independent units safely and to prove whether more machinery is warranted.

### Pi-backed worker details

Use Pi SDK or RPC with `SessionManager.create(cwd)` rather than the sample's `--no-session`. Store the session file/ID in the lease. The supervisor, not an extension timer, owns the process. On process failure, reopen the session and send a consolidated recovery prompt, or start a fresh attempt if the prior turn ended mid-side-effect. [Pi SDK, lines 780-858](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/sdk.md#L780-L858) [Pi RPC, lines 603-671](file:///home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent/docs/rpc.md#L603-L671)

Pi's RPC steer/follow-up queue should only steer a live worker. Do not use it as the durable unit queue. After a worker process dies, reconstruct intent from the external unit record, not from an assumed pending message.

### Codex-backed worker details

Use app-server thread IDs as worker conversation IDs and persist the mapping in the queue store. Use `thread/list`/`thread/read` for observation, `thread/resume` for a stopped stored conversation, and `turn/start` for a new attempt or continuation. Use a separate cwd/worktree per writer. Use app-server notifications as hints, then reconcile against durable thread history and git state.

Codex's experimental `thread/queue/*` can sequence follow-up turns within one worker. It should not own project dispatch. Parent-owned V2 subagents reject direct turns and settings, so a custom external coordinator should either coordinate through the root thread or create first-class worker threads itself instead of assuming it can directly drive every internal child. [installed app-server README, lines 185-226 and 860-884](file:///tmp/openai-codex/codex-rs/app-server/README.md#L185-L226)

## Minimal recommendation options

### Option A: prompt-only, bounded delegation

Use for ordinary ds-mode tasks.

- Pi: install/adapt the official subagent example; add a small `git worktree` helper for writing parallel tasks.
- Codex: rely on built-in roles and agent tools; define pstack-like reviewer/explorer/worker TOML roles.
- Replace todos with Pi's todo example or Codex `update_plan`.
- Replace AskQuestion with Pi extension UI or Codex `request_user_input`.
- Omit local background durability, cloud handoff, `/loop`, inbox draining, and project orchestration claims.

This is the smallest honest adaptation.

### Option B: dumb local durable queue

Use when independent tasks must survive a parent/client restart.

- Add the file-backed supervisor described above.
- Give every writing unit a worktree.
- Run one persistent Pi RPC process or one Codex app-server thread per unit.
- Poll process/thread/git/report state.
- Deliver completion through durable inbox files.
- Require explicit user approval only for predeclared irreversible boundaries; keep gates in queue state.

Choose Pi if the goal is a small, inspectable, provider-neutral implementation. Choose Codex if less agent-control code matters more than version coupling.

### Option C: Codex app-server adapter

Use when Codex 0.152.0 is an accepted dependency.

- Let Codex handle roles, child threads, steering, waits, approvals, and saved histories.
- Let the adapter handle worktrees, durable project units, leases, retries, gates, and result reconciliation.
- Treat Multi-Agent V2 and `thread/queue/*` as version-pinned experimental APIs.
- Run app-server under its daemon or another service manager, but still recover active work by reconciliation rather than assuming turns resume themselves.

This is probably the smallest capable implementation for a pstack-like local product.

### Option D: real remote orchestration

Use only for project-scale, unattended, multi-day work.

- Integrate Cursor Cloud or Codex Cloud as a separate provider with durable remote task IDs, status polling, branch/PR outputs, budgets, and cancellation.
- Keep the provider-neutral queue authoritative.
- Do not expose a single `environment` flag unless both providers meet the same lifecycle contract.

This is new infrastructure, not a skill port.

## Semantics to substitute, omit, or build

### Substitute directly

- focused delegation;
- isolated context;
- model and tool/permission selection;
- bounded parallel fan-out;
- chain/synthesis workflows;
- visible todo/checklist state;
- plan review and explicit execution gate;
- structured user questions;
- read-only reviewers;
- session/thread resume after completed or stopped work.

### Omit from a minimal adaptation

- automatic cloud fallback;
- identical local/cloud Task schema;
- claims that background local work survives restart;
- nested coordinator fleets;
- `/loop` syntax itself;
- automatic PR merging and Graphite stack ownership;
- “resume to poll” behavior;
- delivery guarantees based only on chat notifications.

### Requires new infrastructure

- durable unit queue and leases;
- process/host supervisor;
- completion inbox;
- restart reconciliation;
- worktree allocator and cleanup;
- remote task provider abstraction;
- event subscriptions and scheduled wakeups;
- durable human gates;
- verification ledger and current-head invalidation;
- retry budgets and zombie handling.

## Uncertainties and limits of the evidence

1. Cursor's current subagent documentation describes foreground/background behavior and resume IDs but does not publish the complete Task tool JSON schema. It does not establish whether pstack's `run_in_background` argument remains the canonical field or how long local background files are retained. [Cursor subagents](https://cursor.com/docs/subagents)
2. Cursor official sources examined do not specify local subagent behavior across an application crash, OS logout, or reboot. pstack explicitly treats local agents as dead after restart.
3. Cursor official sources examined do not specify the model-facing todo tool contract or the `AskQuestion` schema. The report therefore treats those names as pstack conventions and maps their user-visible behavior.
4. Codex official docs deliberately do not promise a default concurrency number. The numbers in this report are version-specific source facts for tag `rust-v0.152.0`, not stable product limits.
5. Codex docs establish durable thread history and resume, but not continuation of an active local turn through app-server or host failure. No such guarantee should be inferred.
6. Codex app-server's queue, descendant filters, project APIs, websocket transport, background terminal APIs, and several multi-agent details are experimental in 0.152.0. Generated schemas should be pinned and compatibility-tested for every upgrade. [installed app-server README, lines 20-63 and 171-226](file:///tmp/openai-codex/codex-rs/app-server/README.md#L20-L63)
7. The installed Codex CLI is a standalone stripped binary. Source analysis used the matching official GitHub tag `rust-v0.152.0`; installed help confirmed `codex-cli 0.152.0`, `multi_agent` enabled, and commands including `agents`, `queue`, `resume`, `fork`, `cloud`, and `app-server`. CLI help is a version observation, not a forward-compatible promise.
8. Pi's official example source and docs are examples, not a commitment that their schemas remain stable. An adapter should vendor or test the chosen example rather than import it as an unversioned contract.

## Source list

### Cursor

- [Subagents](https://cursor.com/docs/subagents), downloaded Markdown: `/tmp/cursor-docs/subagents.md`, especially lines 1-37, 121-174, 236-284, 442-457.
- [Plan Mode](https://cursor.com/docs/agent/plan-mode), `/tmp/cursor-docs/agent_plan-mode.md`, lines 1-34.
- [Agents Window](https://cursor.com/docs/agent/agents-window), `/tmp/cursor-docs/agent_agents-window.md`, lines 1-36.
- [Worktrees](https://cursor.com/docs/configuration/worktrees), `/tmp/cursor-docs/configuration_worktrees.md`, lines 1-19 and 189-233.
- [Cloud Agents](https://cursor.com/docs/cloud-agent), `/tmp/cursor-docs/cloud-agent.md`, lines 1-15, 43-59, 63-100, 153.
- [Cloud Agent capabilities](https://cursor.com/docs/cloud-agent/capabilities), `/tmp/cursor-docs/cloud-agent_capabilities.md`, lines 1-15, 52-134.
- [Cloud Agent automations](https://cursor.com/docs/cloud-agent/automations), `/tmp/cursor-docs/cloud-agent_automations.md`, lines 1-49, 139-223.

### Pi 0.84.4

Installed package root: `/home/david/.local/share/mise/installs/node/24.18.0/lib/node_modules/@earendil-works/pi-coding-agent`.

- `docs/extensions.md`, especially lines 1-28, 174-195, 295-411, 1332-1490.
- `docs/sdk.md`, especially lines 1-165, 780-858, 1094-1186.
- `docs/rpc.md`, especially lines 1-214, 603-671, 1056-1193.
- `examples/extensions/subagent/README.md`, lines 1-176.
- `examples/extensions/subagent/index.ts`, especially lines 220-235, 278-468, 483-684.
- `examples/extensions/todo.ts`, lines 1-297.
- `examples/extensions/plan-mode/README.md`, lines 1-66.
- `examples/extensions/plan-mode/index.ts`, lines 1-390.
- `examples/extensions/plan-mode/utils.ts`, lines 1-168.
- Upstream repository links are embedded in the installed docs under [earendil-works/pi-mono](https://github.com/earendil-works/pi-mono).

### OpenAI Codex 0.152.0

- [Subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents), downloaded Markdown: `/tmp/openai-docs/agent-configuration_subagents.md`, lines 1-538.
- [Codex App Server](https://learn.chatgpt.com/docs/app-server), `/tmp/openai-docs/app-server.md`, lines 1-2313.
- [Codex SDK](https://learn.chatgpt.com/docs/codex-sdk), `/tmp/openai-docs/codex-sdk.md`, lines 1-146.
- [Long-running work](https://learn.chatgpt.com/docs/long-running-work), `/tmp/openai-docs/long-running-work.md`, lines 1-190.
- [Worktrees](https://learn.chatgpt.com/docs/environments/git-worktrees), `/tmp/openai-docs/environments_git-worktrees.md`, lines 1-227.
- [Sandbox](https://learn.chatgpt.com/docs/sandboxing), `/tmp/openai-docs/sandboxing.md`, lines 1-273.
- [Agent approvals and security](https://learn.chatgpt.com/docs/agent-approvals-security), `/tmp/openai-docs/agent-approvals-security.md`, lines 1-511.
- Official source: [openai/codex tag `rust-v0.152.0`](https://github.com/openai/codex/tree/rust-v0.152.0), checked out at `/tmp/openai-codex`.
- `/tmp/openai-codex/codex-rs/core/src/tools/handlers/multi_agents_spec.rs`, lines 1-318.
- `/tmp/openai-codex/codex-rs/core/src/agent/control/spawn.rs`, lines 584-780.
- `/tmp/openai-codex/codex-rs/core/src/config/mod.rs`, lines 228-242, 1261-1305, 1558-1571, 2682-2695, 3770-3797.
- `/tmp/openai-codex/codex-rs/core/src/agent/registry.rs`, lines 18-103.
- `/tmp/openai-codex/codex-rs/core/src/session/input_queue.rs`, lines 78-152.
- `/tmp/openai-codex/codex-rs/app-server/README.md`, especially lines 20-83, 171-226, 405-540, 860-884, 1789-1883.
- `/tmp/openai-codex/codex-rs/app-server-daemon/README.md`, lines 1-113.
- Installed executable: `/home/david/.codex/packages/standalone/releases/0.152.0-x86_64-unknown-linux-musl/bin/codex`; commands inspected: `--help`, `features list`, `agents --help`, `queue --help`, `resume --help`, `fork --help`, `cloud --help`, and `app-server --help`.

### pstack

- `/tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/SKILL.md`, especially lines 15-35, 81-116, 132-139.
- `/tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/orchestrate.md`, lines 1-113.
- `/tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/autonomous-run.md`, lines 1-13.
- `/tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/autopilot-full.md`, lines 1-13.
- `/tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/autopilot-stack.md`, lines 1-16.
- `/tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/pause-safely.md`, lines 1-10.
- `/tmp/cursor-plugins-pstack/pstack/skills/poteto-mode/playbooks/session-pickup.md`, lines 1-13.
- `/tmp/cursor-plugins-pstack/pstack/skills/arena/SKILL.md`, lines 13-41.
- `/tmp/cursor-plugins-pstack/pstack/skills/swarm/SKILL.md`, lines 13-34.
